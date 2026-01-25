import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/routenames.dart';
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

    debugPrint('🔔 FCM Service → Basic initialization');

    await _initializeLocalNotifications();

    // Register handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleAppOpenedFromNotification);

    // Check if app was launched from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 App launched from notification');
      _handleAppOpenedFromNotification(initialMessage);
    }

    // Token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    _isInitialized = true;
    debugPrint('✅ FCM basic setup completed');
  }

  // ────────────────────────────────────────────────
  // 2. Request permission & register token (call when user is logged in / onboarding)
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
  // Local Notifications Setup
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

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
    );

    await _createAndroidNotificationChannels();
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
        'transfer_news_channel',
        'Transfer News',
        description: 'Player transfer updates',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'podcast_new_channel',
        'New Podcasts',
        description: 'New podcast episodes',
        importance: Importance.high,
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
  final type = data['type'] as String? ?? '';

  debugPrint('📬 Processing notification type: $type');

  if (!await _isNotificationTypeEnabled(type)) {
    debugPrint('⚠️ Notification type $type is disabled');
    return;
  }

  // Download image BEFORE showing notification
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

  await _localNotifications.show(
    message.hashCode,
    notification?.title,
    notification?.body,
    platformDetails,
    payload: jsonEncode(data),
  );
  
  debugPrint('✅ Notification shown');
}

  void _handleAppOpenedFromNotification(RemoteMessage message) {
    debugPrint('👆 App opened via notification');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Data: ${message.data}');
    _navigateBasedOnData(message.data);
  }

  void _handleLocalNotificationResponse(NotificationResponse response) {
    debugPrint('👆 Local notification tapped');
    debugPrint('   Payload: ${response.payload}');
    
    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateBasedOnData(data);
    } catch (e) {
      debugPrint('❌ Invalid notification payload: $e');
    }
  }

  // ────────────────────────────────────────────────
  // Navigation Logic
  // ────────────────────────────────────────────────
  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    debugPrint('🧭 Navigating for type: $type');
    debugPrint('   Full data: $data');

    switch (type) {
      case 'breakingNews':
        final newsId = data['newsId'] as String? ?? '';
        if (newsId.isNotEmpty) {
          globalRouter.push('/news/$newsId');
        }
        break;

      case 'breakingTransfer':
        globalRouter.pushNamed(RouteNames.transfer);
        break;

      case 'podcastNew':
        globalRouter.pushNamed(RouteNames.podcastFav);
        break;

      case 'podcastLive':
        final podcastId = data['id'] ?? '';
        debugPrint('📻 Opening podcast: $podcastId');
        
        // Parse rssLink properly
        List<String> rssLinks = [];
        if (data['rssLink'] != null) {
          try {
            if (data['rssLink'] is String) {
              final decoded = jsonDecode(data['rssLink']);
              rssLinks = List<String>.from(decoded);
            } else if (data['rssLink'] is List) {
              rssLinks = List<String>.from(data['rssLink']);
            }
          } catch (e) {
            debugPrint('❌ Error parsing rssLink: $e');
          }
        }
        
        globalRouter.push(
          '/podcast/$podcastId',
          extra: {
            'id': data['id'] ?? '',
            'programId': data['programId'] ?? '',
            'name': data['name'] ?? '',
            'program': data['program'] ?? '',
            'station': data['station'] ?? '',
            'description': data['description'] ?? '',
            'avatar': data['avatar'] ?? '',
            'liveLink': data['liveLink'] ?? '',
            'rssLink': rssLinks,
            'isLive': true,
            'language': data['language'] ?? 'en', // Pass language from notification
          },
        );
        break;

      case 'manynotifications':
        globalRouter.pushNamed(RouteNames.home);
        break;

      default:
        debugPrint('⚠️ Unknown notification type: $type');
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
      'breakingNews': 'breaking_news_channel',
      'breakingTransfer': 'transfer_news_channel',
      'podcastNew': 'podcast_new_channel',
      'podcastLive': 'podcast_live_channel',
      'manynotifications': 'general_notifications_channel',
    };
    return map[type] ?? 'general_notifications_channel';
  }

  String _getChannelName(String type) {
    const map = {
      'breakingNews': 'Breaking News',
      'breakingTransfer': 'Transfer News',
      'podcastNew': 'New Podcasts',
      'podcastLive': 'Live Podcasts',
      'manynotifications': 'General Notifications',
    };
    return map[type] ?? 'General Notifications';
  }

  String _getChannelDescription(String type) {
    const map = {
      'breakingNews': 'Breaking news notifications',
      'breakingTransfer': 'Transfer news notifications',
      'podcastNew': 'New podcast notifications',
      'podcastLive': 'Live podcast notifications',
      'manynotifications': 'General app notifications',
    };
    return map[type] ?? 'General app notifications';
  }

  Future<bool> _isNotificationTypeEnabled(String type) async {
    final prefs = await SharedPreferences.getInstance();

    const settingMap = {
      'breakingNews': 'Breaking News',
      'breakingTransfer': 'Transfer News',
      'podcastNew': 'Podcasts',
      'podcastLive': 'Podcasts',
      'manynotifications': 'News',
    };

    final key = settingMap[type];
    if (key == null) return true;

    return prefs.getBool(key) ?? true;
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

// ────────────────────────────────────────────────
/// Manages topic subscriptions (mainly for podcasts)
// ────────────────────────────────────────────────
class FCMTopicManager {
  static final _messaging = FirebaseMessaging.instance;

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
}