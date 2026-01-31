import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../util/auth/tokens.dart';
import '../util/baseUrl.dart';

// ────────────────────────────────────────────────
// BACKGROUND MESSAGE HANDLER (must be top-level)
// ────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received → ${message.messageId}');
  await FCMService().showLocalNotification(message);
}

// ────────────────────────────────────────────────
/// Central service for Firebase Cloud Messaging + local notifications
// ────────────────────────────────────────────────
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;

  // ────────────────────────────────────────────────
  // 1. Basic initialization (called early – no permission request)
  // ────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background → foreground (app was in background, user tapped notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleAppOpenedFromNotification);

    // Token refresh listener
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    _isInitialized = true;

    debugPrint('✅ FCM Service initialized with deep linking');
  }

  // ────────────────────────────────────────────────
  // 2. Request permission & register token
  // ────────────────────────────────────────────────
  Future<void> requestPermissionAndRegisterToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('📱 Notification permission: ${settings.authorizationStatus.name}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _fetchAndRegisterToken();
    }
  }

  // ────────────────────────────────────────────────
  // Local Notifications Setup - FIXED VERSION
  // ────────────────────────────────────────────────
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('testaapp');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ✅ CRITICAL FIX: Make sure the handler is properly registered
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('👆 NOTIFICATION TAPPED - RESPONSE RECEIVED');
        debugPrint('   ID: ${response.id}');
        debugPrint('   Action ID: ${response.actionId}');
        debugPrint('   Input: ${response.input}');
        debugPrint('   Payload: ${response.payload}');
        debugPrint('═══════════════════════════════════════════════════════════');
        
        // Call the handler
        _handleLocalNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createAndroidNotificationChannels();
    
    debugPrint('✅ Local notifications initialized with tap handlers');
  }

  Future<void> _createAndroidNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        'breaking_news_channel',
        'Breaking News',
        description: 'Important breaking news',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'match_events_channel',
        'Match Events',
        description: 'Live match updates and events',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'podcast_live_channel',
        'Live Podcasts',
        description: 'Live podcast broadcasts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'general_notifications_channel',
        'General Notifications',
        description: 'Other important updates',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  // ────────────────────────────────────────────────
  // Token Management
  // ────────────────────────────────────────────────
  Future<void> _fetchAndRegisterToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken == null) return;

      debugPrint('📱 FCM Token: $_fcmToken');
      await _registerTokenWithBackend(_fcmToken!);
    } catch (e) {
      debugPrint('❌ Failed to get/register FCM token: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('⚠️ No access token → skipping FCM registration');
      return;
    }

    try {
      final uri = Uri.parse('${BaseUrl().url}/api/fcm/register');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,
          'fcmToken': token,
          'deviceId': await _getOrCreateDeviceId(),
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token registered with server');
      } else {
        debugPrint('❌ FCM registration failed → ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ FCM backend registration error: $e');
    }
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint('🔄 Token refreshed → $newToken');
    _fcmToken = newToken;
    await _registerTokenWithBackend(newToken);
  }

  // ────────────────────────────────────────────────
  // Message Handlers
  // ────────────────────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Foreground message → ${message.messageId}');
    debugPrint('   Type: ${message.data['type']}');
    debugPrint('   Data: ${message.data}');
    showLocalNotification(message);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('setup_done') ?? false)) {
      debugPrint('⚠️ Setup not done, skipping notification');
      return;
    }

    final notification = message.notification;
    final data = message.data;

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📬 PROCESSING NOTIFICATION');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Has notification: ${notification != null}');
    debugPrint('   Has data: ${data.isNotEmpty}');
    debugPrint('   Data keys: ${data.keys.toList()}');
    debugPrint('   Raw data: $data');
    debugPrint('═══════════════════════════════════════════════════════════');

    // CRITICAL: Always include essential data fields
    if (data.isEmpty || data['type'] == null) {
      debugPrint('❌ Missing required data fields, cannot process notification');
      return;
    }

    // Normalize type to lowercase for consistent checking
    final type = (data['type'] as String? ?? '').toLowerCase();
    final subtype = (data['subtype'] as String? ?? '').toLowerCase();

    debugPrint('   Original type: ${data['type']}');
    debugPrint('   Normalized type: $type');
    debugPrint('   Subtype: $subtype');

    // Check if notification type is enabled
    if (type == 'matchevent' && subtype.isNotEmpty) {
      if (!await _isMatchEventSubtypeEnabled(subtype)) {
        debugPrint('⚠️ Match event subtype $subtype is disabled, filtering out');
        return;
      }
      debugPrint('✅ Match event subtype $subtype is enabled');
    } else if (!await _isNotificationTypeEnabled(type)) {
      debugPrint('⚠️ Notification type $type is disabled');
      return;
    } else {
      debugPrint('✅ Notification type $type is enabled');
    }

    // Get image URL
    String? imageUrl = notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        data['image'] ??
        data['avatar'];

    debugPrint('🖼️ Image URL: $imageUrl');

    String? bigPicturePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      bigPicturePath = await _downloadImageIfPossible(imageUrl);
      debugPrint('📸 Image downloaded: ${bigPicturePath != null ? "✅ $bigPicturePath" : "❌"}');
    }

    // ✅ GENERATE DEEP LINK
    final deepLink = _generateDeepLink(type, data);
    debugPrint('🔗 Generated deep link: $deepLink');

    final channelId = _getChannelId(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.max,
      priority: Priority.high,
      icon: 'testaapp',
      styleInformation: bigPicturePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              largeIcon: FilePathAndroidBitmap(bigPicturePath),
              contentTitle: notification?.title,
              summaryText: notification?.body,
              htmlFormatContentTitle: true,
              htmlFormatSummaryText: true,
            )
          : BigTextStyleInformation(
              notification?.body ?? '',
              contentTitle: notification?.title,
              htmlFormatContentTitle: true,
              htmlFormatContent: true,
            ),
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: bigPicturePath != null
            ? [DarwinNotificationAttachment(bigPicturePath)]
            : null,
      ),
    );

    debugPrint('📦 Deep link payload being set: $deepLink');

    try {
      await _localNotifications.show(
        message.hashCode,
        notification?.title ?? 'Notification',
        notification?.body ?? '',
        platformDetails,
        payload: deepLink, // ✅ Use deep link as payload
      );

      debugPrint('✅ Notification shown successfully with deep link');
      debugPrint('   Notification ID: ${message.hashCode}');
      debugPrint('   Payload attached: $deepLink');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to show notification: $e');
      debugPrint('   Stack trace: $stackTrace');
    }
  }

  void _handleAppOpenedFromNotification(RemoteMessage message) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('👆 APP OPENED VIA FCM NOTIFICATION (background state)');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Data: ${message.data}');
    debugPrint('═══════════════════════════════════════════════════════════');

    if (message.data.isEmpty) {
      debugPrint('❌ No data in message, navigating to home');
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          globalRouter.go('/home');
        } catch (e) {
          debugPrint('❌ Navigation failed: $e');
        }
      });
      return;
    }

    // Generate and navigate to deep link
    final type = (message.data['type'] as String? ?? '').toLowerCase();
    final deepLink = _generateDeepLink(type, message.data);
    debugPrint('🔗 Navigating to deep link from FCM: $deepLink');
    _navigateToDeepLink(deepLink);
  }

  void _handleLocalNotificationResponse(NotificationResponse response) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('👆👆👆 LOCAL NOTIFICATION TAPPED 👆👆👆');
    debugPrint('   Notification ID: ${response.id}');
    debugPrint('   Payload: ${response.payload}');
    debugPrint('   Payload length: ${response.payload?.length ?? 0}');
    debugPrint('   Payload is null: ${response.payload == null}');
    debugPrint('   Payload is empty: ${response.payload?.isEmpty}');
    debugPrint('═══════════════════════════════════════════════════════════');

    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint("❌ No payload found → fallback to /home");
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          debugPrint('🏠 Navigating to home (no payload)');
          globalRouter.go('/home');
        } catch (e) {
          debugPrint('❌ Navigation to home failed: $e');
        }
      });
      return;
    }

    debugPrint("✅ Payload exists! Content: ${response.payload}");
    
    // The payload is a deep link URI
    _navigateToDeepLink(response.payload!);
  }

  // ────────────────────────────────────────────────
  // ✅ DEEP LINK GENERATION
  // ────────────────────────────────────────────────
  String _generateDeepLink(String type, Map<String, dynamic> data) {
    debugPrint('🔧 Generating deep link for type: $type');
    debugPrint('   Data: $data');
    
    String link;
    
    switch (type) {
      case 'breakingnews':
        final newsId = data['newsId'] ?? '';
        final lang = data['lang'] ?? localLanguageNotifier.value;
        link = 'testaapp://newsDetail/$newsId?lang=$lang';
        break;

      case 'matchevent':
        final fixtureId = data['fixtureId'] ?? data['matchId'] ?? '';
        link = 'testaapp://matchDetail?fixtureId=$fixtureId';
        break;

      case 'podcastlive':
        final id = data['id'] ?? '';
        final programId = Uri.encodeComponent(data['programId']?.toString() ?? '');
        final name = Uri.encodeComponent(data['name']?.toString() ?? '');
        final program = Uri.encodeComponent(data['program']?.toString() ?? '');
        final station = Uri.encodeComponent(data['station']?.toString() ?? '');
        final description = Uri.encodeComponent(data['description']?.toString() ?? '');
        final avatar = Uri.encodeComponent(data['avatar']?.toString() ?? '');
        final liveLink = Uri.encodeComponent(data['liveLink']?.toString() ?? '');
        final rssLink = Uri.encodeComponent(data['rssLink']?.toString() ?? '');
        final isLive = data['isLive']?.toString() ?? 'false';
        final language = data['language']?.toString() ?? localLanguageNotifier.value;

        link = 'testaapp://podcast/$id?programId=$programId&name=$name&program=$program&station=$station&description=$description&avatar=$avatar&liveLink=$liveLink&rssLink=$rssLink&isLive=$isLive&language=$language';
        break;

      case 'manynotifications':
        link = 'testaapp://home';
        break;

      default:
        debugPrint('⚠️ Unknown type for deep link: $type');
        link = 'testaapp://home';
    }
    
    debugPrint('✅ Generated deep link: $link');
    return link;
  }

  // ────────────────────────────────────────────────
  // ✅ DEEP LINK NAVIGATION
  // ────────────────────────────────────────────────
void _navigateToDeepLink(String deepLink) {
  debugPrint('🚀 STARTING NAVIGATION TO DEEP LINK: $deepLink');
  
  try {
    final uri = Uri.parse(deepLink);
    final String hostLower = uri.host.toLowerCase();
    final query = uri.queryParameters;

    debugPrint('Host: $hostLower');
    debugPrint('Path segments: ${uri.pathSegments}');
    debugPrint('Query: $query');

    if (hostLower == 'matchdetail' || hostLower == 'matchDetail') {
      final fixtureId = query['fixtureId']?.trim();
      if (fixtureId != null && fixtureId.isNotEmpty) {
        debugPrint('→ Match detail: fixtureId=$fixtureId');
        globalRouter.go('/matchDetail?fixtureId=$fixtureId');
        return;
      }
    } 
    
    else if (hostLower == 'newsdetail') {
      // News uses path segment after host
      final newsId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      final lang = query['lang']?.trim();

      debugPrint('→ News detail: newsId=$newsId, lang=$lang');

      if (newsId != null && newsId.isNotEmpty) {
        if (lang != null && lang.isNotEmpty) {
          localLanguageNotifier.value = lang;
          debugPrint('→ Language updated: $lang');
        }
        globalRouter.go('/newsDetail/$newsId');
        return;
      }
    } 
    
    else if (hostLower == 'podcast') {
      final podcastId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      if (podcastId != null && podcastId.isNotEmpty) {
        debugPrint('→ Podcast: id=$podcastId');
        globalRouter.go('/podcast/$podcastId', extra: query);
        return;
      }
    }

    // Fallback only if nothing matched
    debugPrint('→ Unknown / invalid deep link format → fallback to home');
    globalRouter.go('/home');
    
  } catch (e, st) {
    debugPrint('❌ Deep link error: $e');
    debugPrint(st as String?);
    globalRouter.go('/home');
  }
}
  // ────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────
  Future<String?> _downloadImageIfPossible(String url) async {
    try {
      debugPrint('📥 Downloading image: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ Image download timeout');
          return http.Response('', 408);
        },
      );

      if (response.statusCode != 200) {
        debugPrint('❌ Image download failed: ${response.statusCode}');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'notif_${url.hashCode}.jpg';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      debugPrint('✅ Image saved: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Image download error: $e');
      return null;
    }
  }

  String _getChannelId(String type) {
    const map = {
      'breakingnews': 'breaking_news_channel',
      'matchevent': 'match_events_channel',
      'podcastlive': 'podcast_live_channel',
      'manynotifications': 'general_notifications_channel',
    };
    return map[type] ?? 'general_notifications_channel';
  }

  String _getChannelName(String type) {
    const map = {
      'breakingnews': 'Breaking News',
      'matchevent': 'Match Events',
      'podcastlive': 'Live Podcasts',
      'manynotifications': 'General Notifications',
    };
    return map[type] ?? 'General Notifications';
  }

  String _getChannelDescription(String type) {
    const map = {
      'breakingnews': 'Breaking news notifications',
      'matchevent': 'Live match event notifications',
      'podcastlive': 'Live podcast notifications',
      'manynotifications': 'General app notifications',
    };
    return map[type] ?? 'General app notifications';
  }

  Future<bool> _isNotificationTypeEnabled(String type) async {
    final prefs = await SharedPreferences.getInstance();

    const settingMap = {
      'breakingnews': 'Breaking News',
      'podcastlive': 'Podcasts',
      'matchevent': null,
      'manynotifications': null,
    };

    final key = settingMap[type];
    if (key == null) return true;

    final isEnabled = prefs.getBool(key) ?? true;
    debugPrint('🎯 Notification type $type → $key: ${isEnabled ? "✅" : "❌"}');
    return isEnabled;
  }

  Future<bool> _isMatchEventSubtypeEnabled(String subtype) async {
    final prefs = await SharedPreferences.getInstance();

    const subtypeSettingMap = {
      'started': 'Started',
      'halftime': 'Half time',
      'fulltime': 'Full time',
      'goals': 'Goals',
      'redcards': 'Red cards',
      'missedpenalty': 'Missed penalty',
      'lineup': 'lineup',
      'matchreminder': 'Match reminder',
      'substitution': 'Substitution',
      'highlights': 'Official Highlights',
    };

    final settingKey = subtypeSettingMap[subtype.toLowerCase()];
    if (settingKey == null) {
      debugPrint('⚠️ Unknown match event subtype: $subtype');
      return true;
    }

    final isEnabled = prefs.getBool(settingKey) ?? true;
    debugPrint('🎯 Match event $subtype → $settingKey: ${isEnabled ? "✅" : "❌"}');
    return isEnabled;
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  Future<void> unregisterToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return;

    try {
      final uri = Uri.parse('${BaseUrl().url}/api/fcm/unregister');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,
          'deviceId': await _getOrCreateDeviceId(),
        }),
      );
      debugPrint('✅ FCM token unregistered');
    } catch (e) {
      debugPrint('❌ Unregister failed: $e');
    }
  }
}

// ✅ CRITICAL: Background notification tap handler
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('═══════════════════════════════════════════════════════════');
  debugPrint('🌙 BACKGROUND NOTIFICATION TAP');
  debugPrint('   Payload: ${notificationResponse.payload}');
  debugPrint('═══════════════════════════════════════════════════════════');
  // This will be handled when app comes to foreground
}
// ────────────────────────────────────────────────
// Auto-subscribe helper
// ────────────────────────────────────────────────
Future<void> ensureBreakingNewsSubscription() async {
  final prefs = await SharedPreferences.getInstance();
  final lang = localLanguageNotifier.value;
  final key = 'breaking_news_subscribed_$lang';

  if (prefs.getBool(key) == true) {
    debugPrint('Already subscribed to breaking_news_$lang');
    return;
  }

  debugPrint('Auto-subscribing to breaking_news_$lang on first valid setup');
  await FCMTopicManager.updateBreakingNewsSubscription(
    languageCode: lang,
    isEnabled: true,
  );

  await prefs.setBool(key, true);
}

/// Manages topic subscriptions
// ────────────────────────────────────────────────
class FCMTopicManager {
  static final _messaging = FirebaseMessaging.instance;
  static const String _lastLangKey = 'last_subscribed_language';

  // Podcast topics management
  static Future<void> subscribeToPodcast({
    required String programId,
    required String languageCode,
  }) async {
    final topic = 'program_${programId}_$languageCode'.toLowerCase();
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed → $topic');
    } catch (e) {
      debugPrint('❌ Subscribe failed → $topic : $e');
    }
  }

  static Future<bool> unsubscribeFromPodcastTopic({
    required String programId,
    required String languageCode,
  }) async {
    try {
      final program = programId.trim().toLowerCase();
      final lang = languageCode.trim().toLowerCase();

      if (program.isEmpty || lang.isEmpty || lang.length > 5) {
        debugPrint('⚠️ Invalid unsubscribe parameters: program=$program, lang=$lang');
        return false;
      }

      final topic = 'program_${program}_$lang';

      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed: $topic');
      return true;
    } catch (e, st) {
      debugPrint('❌ FCM unsubscribe failed → $e');
      debugPrint('   Topic attempted: program_${programId}_$languageCode');
      debugPrint('   $st');
      return false;
    }
  }

  // Breaking News topics management
  static Future<void> updateBreakingNewsSubscription({
    required String languageCode,
    required bool isEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastLanguage = prefs.getString(_lastLangKey);
    final fcm = FirebaseMessaging.instance;

    debugPrint('🔔 Breaking News Update: lang=$languageCode, enabled=$isEnabled, lastLang=$lastLanguage');

    if (!isEnabled) {
      if (lastLanguage != null && lastLanguage.isNotEmpty) {
        await fcm.unsubscribeFromTopic('breaking_news_$lastLanguage');
        debugPrint('✅ Unsubscribed from breaking_news_$lastLanguage');
      }
      if (languageCode.isNotEmpty) {
        await fcm.unsubscribeFromTopic('breaking_news_$languageCode');
        debugPrint('✅ Unsubscribed from breaking_news_$languageCode');
      }
      await prefs.remove(_lastLangKey);
      return;
    }

    if (lastLanguage != null && lastLanguage != languageCode) {
      await fcm.unsubscribeFromTopic('breaking_news_$lastLanguage');
      debugPrint('✅ Unsubscribed from old language: breaking_news_$lastLanguage');
    }

    await fcm.subscribeToTopic('breaking_news_$languageCode');
    debugPrint('✅ Subscribed to breaking_news_$languageCode');

    await prefs.setString(_lastLangKey, languageCode);
  }

  // Match subscriptions management
  static Future<void> subscribeToMatch({
    required String fixtureId,
    required String languageCode,
  }) async {
    final topic = 'testa_match_${fixtureId}_${languageCode.toLowerCase()}';

    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('⚽ Subscribed to Match: $topic');

      await _saveMatchSubscription(fixtureId, true);
    } catch (e) {
      debugPrint('❌ Match Subscribe Error: $e');
    }
  }

  static Future<void> unsubscribeFromMatch({
    required String fixtureId,
    required String languageCode,
  }) async {
    final topic = 'testa_match_${fixtureId}_${languageCode.toLowerCase()}';

    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('🔕 Unsubscribed from Match: $topic');

      await _saveMatchSubscription(fixtureId, false);
    } catch (e) {
      debugPrint('❌ Match Unsubscribe Error: $e');
    }
  }

  static Future<bool> isSubscribedToMatch(String fixtureId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptions = prefs.getStringList('match_subscriptions') ?? [];
    return subscriptions.contains(fixtureId);
  }

  static Future<List<String>> getSubscribedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('match_subscriptions') ?? [];
  }

  static Future<void> _saveMatchSubscription(String fixtureId, bool isSubscribed) async {
    final prefs = await SharedPreferences.getInstance();
    var subscriptions = prefs.getStringList('match_subscriptions') ?? [];

    if (isSubscribed) {
      if (!subscriptions.contains(fixtureId)) {
        subscriptions.add(fixtureId);
      }
    } else {
      subscriptions.remove(fixtureId);
    }

    await prefs.setStringList('match_subscriptions', subscriptions);
    debugPrint('💾 Match subscriptions updated: ${subscriptions.length} matches');
  }

  static Future<void> unsubscribeFromAllMatches(String languageCode) async {
    final subscribedMatches = await getSubscribedMatches();

    for (final fixtureId in subscribedMatches) {
      await unsubscribeFromMatch(fixtureId: fixtureId, languageCode: languageCode);
    }

    debugPrint('✅ Unsubscribed from all ${subscribedMatches.length} matches');
  }

  static Future<void> resubscribeMatchesForLanguage({
    required String oldLanguageCode,
    required String newLanguageCode,
  }) async {
    final subscribedMatches = await getSubscribedMatches();

    debugPrint('🔄 Resubscribing ${subscribedMatches.length} matches: $oldLanguageCode → $newLanguageCode');

    final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

    for (final fixtureId in subscribedMatches) {
      for (final lang in allPossibleLanguages) {
        if (lang != newLanguageCode) {
          try {
            final oldTopic = 'testa_match_${fixtureId}_${lang.toLowerCase()}';
            await _messaging.unsubscribeFromTopic(oldTopic);
            debugPrint('🔕 Unsubscribed: $oldTopic');
          } catch (e) {
            debugPrint('⚠️ Failed to unsubscribe from $lang match: $e');
          }
        }
      }

      final newTopic = 'testa_match_${fixtureId}_${newLanguageCode.toLowerCase()}';
      await _messaging.subscribeToTopic(newTopic);
      debugPrint('✅ Subscribed: $newTopic');
    }

    debugPrint('✅ Resubscribed ${subscribedMatches.length} matches complete');
  }

  // Language change handler
  static Future<void> updateLanguageSubscriptions({
    required String oldLanguageCode,
    required String newLanguageCode,
  }) async {
    debugPrint('🌍 Updating language subscriptions: $oldLanguageCode → $newLanguageCode');

    final prefs = await SharedPreferences.getInstance();
    final breakingNewsEnabled = prefs.getBool('Breaking News') ?? true;

    if (breakingNewsEnabled) {
      final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

      debugPrint('🧹 Cleaning up all possible old language subscriptions...');
      for (final lang in allPossibleLanguages) {
        if (lang != newLanguageCode) {
          try {
            await _messaging.unsubscribeFromTopic('breaking_news_$lang');
            debugPrint('🔕 Unsubscribed from breaking_news_$lang');
          } catch (e) {
            debugPrint('⚠️ Failed to unsubscribe from breaking_news_$lang: $e');
          }
        }
      }

      await _messaging.subscribeToTopic('breaking_news_$newLanguageCode');
      debugPrint('✅ Subscribed to breaking_news_$newLanguageCode');

      await prefs.setString(_lastLangKey, newLanguageCode);
    }

    await resubscribeMatchesForLanguage(
      oldLanguageCode: oldLanguageCode,
      newLanguageCode: newLanguageCode,
    );

    debugPrint('✅ Language subscriptions updated successfully');
  }

  static Future<void> cleanupAllLanguageSubscriptions() async {
    debugPrint('🧹 Performing complete cleanup of all language subscriptions...');

    final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

    for (final lang in allPossibleLanguages) {
      try {
        await _messaging.unsubscribeFromTopic('breaking_news_$lang');
        debugPrint('🔕 Unsubscribed from breaking_news_$lang');
      } catch (e) {
        debugPrint('⚠️ Failed to unsubscribe from breaking_news_$lang: $e');
      }
    }

    final subscribedMatches = await getSubscribedMatches();
    for (final fixtureId in subscribedMatches) {
      for (final lang in allPossibleLanguages) {
        try {
          await _messaging.unsubscribeFromTopic('testa_match_${fixtureId}_$lang');
          debugPrint('🔕 Unsubscribed from testa_match_${fixtureId}_$lang');
        } catch (e) {
          debugPrint('⚠️ Failed to unsubscribe: $e');
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLangKey);

    debugPrint('✅ Complete cleanup finished');
  }

  static Future<void> cleanupOnLogout(String currentLanguage) async {
    await updateBreakingNewsSubscription(
      languageCode: currentLanguage,
      isEnabled: false,
    );

    final prefs = await SharedPreferences.getInstance();
    final subscribedMatches = await getSubscribedMatches();
    for (final fixtureId in subscribedMatches) {
      await unsubscribeFromMatch(
        fixtureId: fixtureId,
        languageCode: currentLanguage,
      );
    }
    await prefs.remove('match_subscriptions');

    debugPrint('FCM cleanup on logout completed for language: $currentLanguage');
  }
}