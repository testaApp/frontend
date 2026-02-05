import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  // awesome_notifications will handle the display
  await _showAwesomeNotification(message);
}

// ────────────────────────────────────────────────
// Helper function to show notification (used by both foreground and background)
// ────────────────────────────────────────────────
Future<void> _showAwesomeNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  final title = notification?.title ?? data['title'] ?? 'Testa';
  final body = notification?.body ?? data['body'] ?? '';
  final imageUrl = notification?.android?.imageUrl ?? 
                   notification?.apple?.imageUrl ?? 
                   data['image'];

  final type = (data['type'] as String? ?? '').toLowerCase();
  final subtype = (data['subtype'] as String? ?? '').toLowerCase(); // Add this
  
  String channelKey;
  Color color;
  NotificationCategory category;
  
  switch (type) {
    case 'breakingnews':
      channelKey = 'news_channel';
      color = Colors.red;
      category = NotificationCategory.Social;
      break;
    
    case 'matchevent':
      color = Colors.green;
      category = NotificationCategory.Event;
      // Logic to switch sounds based on subtype
      if (subtype == 'goals') {
        channelKey = 'match_goal_channel';
      } else if (subtype == 'started' || subtype == 'fulltime') {
        channelKey = 'match_start_channel';
      } else {
        channelKey = 'match_channel'; // Default soccer kick sound
      }
      break;

    case 'podcastlive':
      channelKey = 'podcast_channel';
      color = Colors.blue;
      category = NotificationCategory.Service;
      break;
    
    default:
      channelKey = 'default_channel';
      color = Colors.grey;
      category = NotificationCategory.Message;
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: channelKey, // Now uses the specific channel
      title: title,
      body: body,
      bigPicture: imageUrl,
      notificationLayout: imageUrl != null 
          ? NotificationLayout.BigPicture 
          : NotificationLayout.Default,
      payload: data.map((key, value) => MapEntry(key, value.toString())),
      category: category,
      color: color,
      largeIcon: 'resource://drawable/testaapp',
    ),
  );
}
// ────────────────────────────────────────────────
/// Central service for Firebase Cloud Messaging
// ────────────────────────────────────────────────
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;

  // ────────────────────────────────────────────────
  // 1. Initialize Awesome Notifications
  // ────────────────────────────────────────────────
static Future<void> initializeAwesomeNotifications() async {
  await AwesomeNotifications().initialize(
    'resource://drawable/testaapp',
    [
      // 1. Default Channel
      NotificationChannel(
        channelKey: 'default_channel',
        channelName: 'General Notifications',
        channelDescription: 'Default app notifications',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        playSound: false,
      ),
      // 2. Breaking News
      NotificationChannel(
        channelKey: 'news_channel',
        channelName: 'Breaking News',
        channelDescription: 'Urgent news alerts',
        defaultColor: Colors.red,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/breaking_news',
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      ),
      // 3. Match Events - GOALS (Specific Sound)
      NotificationChannel(
        channelKey: 'match_goal_channel',
        channelName: 'Match Goals',
        channelDescription: 'Alerts for when a goal is scored',
        defaultColor: Colors.green,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/goal', 
        vibrationPattern: Int64List.fromList([0, 1000, 200, 1000]),
        
      ),
      // 4. Match Events - Start/End (Specific Sound)
      NotificationChannel(
        channelKey: 'match_start_channel',
        channelName: 'Match Start & Finish',
        channelDescription: 'Whistle alerts for match start/end',
        defaultColor: Colors.green,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/gamestart',
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      ),
      // 5. Match Events - General (Substitutions, Cards, etc.)
      NotificationChannel(
        channelKey: 'match_channel',
        channelName: 'Other Match Events',
        channelDescription: 'Updates for cards and substitutions',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        playSound: true,
        soundSource: 'resource://raw/soccer_ball_kick_default',
      ),
      // 6. Podcasts
      NotificationChannel(
        channelKey: 'podcast_channel',
        channelName: 'Podcasts',
        channelDescription: 'Live podcast alerts',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        playSound: false,
        soundSource: 'resource://raw/podcast_live', // Matches your raw file
      ),
    ],
    debug: true,
  );

  await _setupNotificationListeners();
}
  // ────────────────────────────────────────────────
  // 2. Setup notification tap listeners
  // ────────────────────────────────────────────────
  static Future<void> _setupNotificationListeners() async {
    // Listen for notification taps
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification
  ) async {
    debugPrint('📬 Notification Created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification
  ) async {
    debugPrint('📱 Notification Displayed: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction
  ) async {
    debugPrint('🗑️ Notification Dismissed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction
  ) async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('👆 NOTIFICATION TAPPED (Awesome Notifications)');
    debugPrint('   Action ID: ${receivedAction.id}');
    debugPrint('   Button Pressed: ${receivedAction.buttonKeyPressed}');
    debugPrint('   Payload: ${receivedAction.payload}');
    debugPrint('   Action Lifecycle: ${receivedAction.actionLifeCycle}');
    debugPrint('═══════════════════════════════════════════════════════════');

    final payload = receivedAction.payload ?? {};
    
    if (payload.isEmpty) {
      debugPrint('❌ No payload in notification, navigating to home');
      
      // Add delay to ensure app is ready
      await Future.delayed(const Duration(milliseconds: 500));
      globalRouter.go('/home');
      return;
    }

    // Generate and navigate to deep link
    final type = (payload['type'] ?? '').toLowerCase();
    final deepLink = _generateDeepLink(type, payload);
    debugPrint('🔗 Navigating to deep link from notification tap: $deepLink');
    
    // Add delay to ensure app is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToDeepLink(deepLink);
  }

  // ────────────────────────────────────────────────
  // ✅ NEW: Check for initial notification action (app launched from terminated state)
  // ────────────────────────────────────────────────
  static Future<void> checkInitialNotificationAction() async {
    debugPrint('🔍 Checking for initial notification action...');
    
    // Get the initial notification action if app was opened from a notification
    final ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    
    if (receivedAction != null) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 APP LAUNCHED FROM NOTIFICATION (Terminated State)');
      debugPrint('   Action ID: ${receivedAction.id}');
      debugPrint('   Payload: ${receivedAction.payload}');
      debugPrint('═══════════════════════════════════════════════════════════');
      
      // Process the notification action
      await _onActionReceivedMethod(receivedAction);
    } else {
      debugPrint('ℹ️ No initial notification action found');
    }
  }

  // ────────────────────────────────────────────────
  // 3. Basic initialization (called early – no permission request)
  // ────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Handle foreground messages with awesome_notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    // (awesome_notifications will handle this via _onActionReceivedMethod)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Token refresh listener
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    _isInitialized = true;

    debugPrint('✅ FCM Service initialized');
  }

  // ────────────────────────────────────────────────
  // 4. Request permission & register token
  // ────────────────────────────────────────────────
  Future<void> requestPermissionAndRegisterToken() async {
    // Request FCM permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('📱 FCM permission: ${settings.authorizationStatus.name}');

    // Request Awesome Notifications permissions
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _fetchAndRegisterToken();
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
  void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Foreground message → ${message.messageId}');
    debugPrint('   Type: ${message.data['type']}');
    debugPrint('   Data: ${message.data}');

    // Check if notification should be filtered
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('setup_done') ?? false)) {
      debugPrint('⚠️ Setup not done, skipping notification');
      return;
    }

    final data = message.data;
    if (data.isEmpty || data['type'] == null) {
      debugPrint('❌ Missing required data fields');
      return;
    }

    final type = (data['type'] as String? ?? '').toLowerCase();
    final subtype = (data['subtype'] as String? ?? '').toLowerCase();

    // Check if notification type is enabled
    if (type == 'matchevent' && subtype.isNotEmpty) {
      if (!await _isMatchEventSubtypeEnabled(subtype)) {
        debugPrint('⚠️ Match event subtype $subtype is disabled, filtering out');
        return;
      }
    } else if (!await _isNotificationTypeEnabled(type)) {
      debugPrint('⚠️ Notification type $type is disabled');
      return;
    }

    // ✅ Show notification using awesome_notifications
    await _showAwesomeNotification(message);
    debugPrint('✅ Notification shown via Awesome Notifications');
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('👆 NOTIFICATION TAPPED (FCM)');
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
    debugPrint('🔗 Navigating to deep link from notification tap: $deepLink');
    _navigateToDeepLink(deepLink);
  }

  // ────────────────────────────────────────────────
  // ✅ DEEP LINK GENERATION
  // ────────────────────────────────────────────────
  static String _generateDeepLink(String type, Map<String, dynamic> data) {
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
  static void _navigateToDeepLink(String deepLink) {
    debugPrint('🚀 STARTING NAVIGATION TO DEEP LINK: $deepLink');
    
    try {
      final uri = Uri.parse(deepLink);
      final String hostLower = uri.host.toLowerCase();
      final query = uri.queryParameters;

      debugPrint('Host: $hostLower');
      debugPrint('Path segments: ${uri.pathSegments}');
      debugPrint('Query: $query');

      if (hostLower == 'matchdetail') {
        final fixtureId = query['fixtureId']?.trim();
        if (fixtureId != null && fixtureId.isNotEmpty) {
          debugPrint('→ Match detail: fixtureId=$fixtureId');
          globalRouter.go('/matchDetail?fixtureId=$fixtureId');
          return;
        }
      } 
      
      else if (hostLower == 'newsdetail') {
        final newsId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
        final lang = query['lang']?.trim();

        debugPrint('→ News detail: newsId=$newsId, lang=$lang');

        if (newsId != null && newsId.isNotEmpty) {
          if (lang != null && lang.isNotEmpty) {
            localLanguageNotifier.value = lang;
            debugPrint('→ Language updated: $lang');
          }
globalRouter.go('/newsDetail/$newsId?lang=$lang');
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

      debugPrint('→ Unknown / invalid deep link format → fallback to home');
      globalRouter.go('/home');
      
    } catch (e, st) {
      debugPrint('❌ Deep link error: $e');
      debugPrint(st.toString());
      globalRouter.go('/home');
    }
  }

  // ────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────
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

// Rest of the code (ensureBreakingNewsSubscription and FCMTopicManager) remains the same...
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