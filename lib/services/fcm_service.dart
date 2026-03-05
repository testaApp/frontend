import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/features/auth/services/getDeviceInfo.dart';
import 'package:blogapp/core/network/baseUrl.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// BACKGROUND MESSAGE HANDLER (must be top-level)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('ðŸ”” Background message received â†’ ${message.messageId}');
  // awesome_notifications will handle the display
  await _showAwesomeNotification(message);
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Helper function to show notification (used by both foreground and background)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
/// Central service for Firebase Cloud Messaging
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  static String? _pendingDeepLink;
  static Timer? _pendingDeepLinkTimer;
  static bool _didHandleLaunchFromNotification = false;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // 1. Initialize Awesome Notifications
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // 2. Setup notification tap listeners
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      ReceivedNotification receivedNotification) async {
    debugPrint('ðŸ“¬ Notification Created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('ðŸ“± Notification Displayed: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('ðŸ—‘ï¸ Notification Dismissed: ${receivedAction.id}');
  }

  static Future<String?> consumeInitialLaunchRoute() async {
    if (_didHandleLaunchFromNotification) {
      return null;
    }

    final ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction != null) {
      _didHandleLaunchFromNotification = true;
      final payload = Map<String, dynamic>.from(receivedAction.payload ?? {});
      final route = _buildAppRouteFromPayload(payload);
      debugPrint('Initial launch route resolved from Awesome: $route');
      return route;
    }

    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _didHandleLaunchFromNotification = true;
      final route = _buildAppRouteFromPayload(message.data);
      debugPrint('Initial launch route resolved from FCM: $route');
      return route;
    }

    return null;
  }

  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    _didHandleLaunchFromNotification = true;
    debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');
    debugPrint('ðŸ‘† NOTIFICATION TAPPED (Awesome Notifications)');
    debugPrint('   Action ID: ${receivedAction.id}');
    debugPrint('   Button Pressed: ${receivedAction.buttonKeyPressed}');
    debugPrint('   Payload: ${receivedAction.payload}');
    debugPrint('   Action Lifecycle: ${receivedAction.actionLifeCycle}');
    debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');

    final payload = receivedAction.payload ?? {};

    if (payload.isEmpty) {
      debugPrint('âŒ No payload in notification, navigating to home');

      // Add delay to ensure app is ready
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateWhenRouterReady('testaapp://home');
      return;
    }

    // Generate and navigate to deep link
    final type = _resolveNotificationType(payload);
    final deepLink = _generateDeepLink(type, payload);
    debugPrint('ðŸ”— Navigating to deep link from notification tap: $deepLink');

    // Add delay to ensure app is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateWhenRouterReady(deepLink);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // âœ… NEW: Check for initial notification action (app launched from terminated state)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> checkInitialNotificationAction() async {
    if (_didHandleLaunchFromNotification) {
      debugPrint('Launch notification already handled, skipping Awesome check');
      return;
    }
    debugPrint('ðŸ” Checking for initial notification action...');

    // Get the initial notification action if app was opened from a notification
    final ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);

    if (receivedAction != null) {
      _didHandleLaunchFromNotification = true;
      debugPrint(
          'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');
      debugPrint('ðŸš€ APP LAUNCHED FROM NOTIFICATION (Terminated State)');
      debugPrint('   Action ID: ${receivedAction.id}');
      debugPrint('   Payload: ${receivedAction.payload}');
      debugPrint(
          'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');

      // Process the notification action
      await _onActionReceivedMethod(receivedAction);
    } else {
      debugPrint('â„¹ï¸ No initial notification action found');
    }
  }

  Future<void> checkInitialFcmLaunchMessage() async {
    if (_didHandleLaunchFromNotification) {
      debugPrint('Launch notification already handled, skipping FCM check');
      return;
    }

    debugPrint('Checking for initial FCM notification message...');

    final RemoteMessage? message = await _messaging.getInitialMessage();
    if (message == null) {
      debugPrint('No initial FCM notification message found');
      return;
    }

    _didHandleLaunchFromNotification = true;
    debugPrint('APP LAUNCHED FROM FCM NOTIFICATION (Terminated State)');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Data: ${message.data}');
    _handleNotificationTap(message);
  }

  static bool _isGlobalRouterReady() {
    try {
      // ignore: unnecessary_statements
      globalRouter;
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _schedulePendingDeepLinkRetry() {
    _pendingDeepLinkTimer?.cancel();
    _pendingDeepLinkTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (timer) {
        if (!_isGlobalRouterReady()) {
          return;
        }

        timer.cancel();
        _pendingDeepLinkTimer = null;
        flushPendingDeepLinkNavigation();
      },
    );
  }

  static void _navigateWhenRouterReady(String deepLink) {
    if (_isGlobalRouterReady()) {
      _navigateToDeepLink(deepLink);
      return;
    }

    _pendingDeepLink = deepLink;
    debugPrint('Router not ready. Queued deep link: $deepLink');
    _schedulePendingDeepLinkRetry();
  }

  static void flushPendingDeepLinkNavigation() {
    if (!_isGlobalRouterReady()) {
      return;
    }

    final deepLink = _pendingDeepLink;
    if (deepLink == null) {
      return;
    }

    _pendingDeepLink = null;
    debugPrint('Flushing queued deep link: $deepLink');
    _navigateWhenRouterReady(deepLink);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // 3. Basic initialization (called early â€“ no permission request)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

    debugPrint('âœ… FCM Service initialized');
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // 4. Request permission & register token
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> requestPermissionAndRegisterToken() async {
    // Request FCM permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('ðŸ“± FCM permission: ${settings.authorizationStatus.name}');

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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Token Management
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _fetchAndRegisterToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken == null) return;

      debugPrint('ðŸ“± FCM Token: $_fcmToken');
      await _registerTokenWithBackend(_fcmToken!);
    } catch (e) {
      debugPrint('âŒ Failed to get/register FCM token: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    final headers = await buildAuthHeaders();
    if (!headers.containsKey('Authorization')) {
      debugPrint('?????? No auth token ??? skipping FCM registration');
      return;
    }

    try {
      final uri = Uri.parse('${BaseUrl().url}/api/fcm/register');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'fcmToken': token,
          'deviceId': await _getOrCreateDeviceId(),
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('??? FCM token registered with server');
      } else {
        debugPrint('??? FCM registration failed ??? ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('??? FCM backend registration error: $e');
    }
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint('ðŸ”„ Token refreshed â†’ $newToken');
    _fcmToken = newToken;
    await _registerTokenWithBackend(newToken);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Message Handlers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('ðŸ”” Foreground message â†’ ${message.messageId}');
    debugPrint('   Type: ${message.data['type']}');
    debugPrint('   Data: ${message.data}');

    // Check if notification should be filtered
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('setup_done') ?? false)) {
      debugPrint('âš ï¸ Setup not done, skipping notification');
      return;
    }

    final data = message.data;
    if (data.isEmpty || data['type'] == null) {
      debugPrint('âŒ Missing required data fields');
      return;
    }

    final type = (data['type'] as String? ?? '').toLowerCase();
    final subtype = (data['subtype'] as String? ?? '').toLowerCase();

    // Check if notification type is enabled
    if (type == 'matchevent' && subtype.isNotEmpty) {
      if (!await _isMatchEventSubtypeEnabled(subtype)) {
        debugPrint(
            'âš ï¸ Match event subtype $subtype is disabled, filtering out');
        return;
      }
    } else if (!await _isNotificationTypeEnabled(type)) {
      debugPrint('âš ï¸ Notification type $type is disabled');
      return;
    }

    // âœ… Show notification using awesome_notifications
    await _showAwesomeNotification(message);
    debugPrint('âœ… Notification shown via Awesome Notifications');
  }

  void _handleNotificationTap(RemoteMessage message) {
    _didHandleLaunchFromNotification = true;
    debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');
    debugPrint('ðŸ‘† NOTIFICATION TAPPED (FCM)');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Data: ${message.data}');
    debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');

    if (message.data.isEmpty) {
      debugPrint('âŒ No data in message, navigating to home');
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          _navigateWhenRouterReady('testaapp://home');
        } catch (e) {
          debugPrint('âŒ Navigation failed: $e');
        }
      });
      return;
    }

    // Generate and navigate to deep link
    final type = _resolveNotificationType(message.data);
    final deepLink = _generateDeepLink(type, message.data);
    debugPrint('ðŸ”— Navigating to deep link from notification tap: $deepLink');
    _navigateWhenRouterReady(deepLink);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // âœ… DEEP LINK GENERATION
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static String _buildAppRouteFromPayload(Map<String, dynamic> data) {
    final fixtureIdFromDeepLink = _extractFixtureIdFromDeepLinkFields(data);
    if (fixtureIdFromDeepLink.isNotEmpty) {
      return '/matchDetail?fixtureId=$fixtureIdFromDeepLink';
    }

    final type = _resolveNotificationType(data);

    switch (type) {
      case 'breakingnews':
        final newsId =
            _readStringValue(data, const ['newsId', 'news_id', 'id']);
        final lang = _readStringValue(data, const ['lang', 'language']);
        final resolvedLang = lang.isEmpty ? localLanguageNotifier.value : lang;
        return newsId.isEmpty
            ? '/home'
            : '/newsDetail/$newsId?lang=$resolvedLang';

      case 'matchevent':
      case 'match_event':
      case 'match':
        final fixtureId = _extractFixtureId(data);
        return fixtureId.isEmpty
            ? '/home'
            : '/matchDetail?fixtureId=$fixtureId';

      case 'podcastlive':
        final podcastId = _readStringValue(data, const ['id']);
        return podcastId.isEmpty ? '/home' : '/podcast/$podcastId';

      case 'manynotifications':
        return '/home';

      default:
        final inferredFixtureId = _extractFixtureId(data);
        if (inferredFixtureId.isNotEmpty) {
          return '/matchDetail?fixtureId=$inferredFixtureId';
        }
        return '/home';
    }
  }

  static String _generateDeepLink(String type, Map<String, dynamic> data) {
    debugPrint('ðŸ”§ Generating deep link for type: $type');
    debugPrint('   Data: $data');

    final fixtureIdFromDeepLink = _extractFixtureIdFromDeepLinkFields(data);
    if (fixtureIdFromDeepLink.isNotEmpty) {
      final resolvedDeepLink =
          'testaapp://matchDetail?fixtureId=$fixtureIdFromDeepLink';
      debugPrint('Using deep link fixture fallback: $resolvedDeepLink');
      return resolvedDeepLink;
    }

    String link;

    switch (type) {
      case 'breakingnews':
        final newsId =
            _readStringValue(data, const ['newsId', 'news_id', 'id']);
        final lang = _readStringValue(data, const ['lang', 'language']);
        final resolvedLang = lang.isEmpty ? localLanguageNotifier.value : lang;
        link = newsId.isEmpty
            ? 'testaapp://home'
            : 'testaapp://newsDetail/$newsId?lang=$resolvedLang';
        break;

      case 'matchevent':
      case 'match_event':
      case 'match':
        final fixtureId = _extractFixtureId(data);
        link = fixtureId.isEmpty
            ? 'testaapp://home'
            : 'testaapp://matchDetail?fixtureId=$fixtureId';
        break;

      case 'podcastlive':
        final id = data['id'] ?? '';
        final programId =
            Uri.encodeComponent(data['programId']?.toString() ?? '');
        final name = Uri.encodeComponent(data['name']?.toString() ?? '');
        final program = Uri.encodeComponent(data['program']?.toString() ?? '');
        final station = Uri.encodeComponent(data['station']?.toString() ?? '');
        final description =
            Uri.encodeComponent(data['description']?.toString() ?? '');
        final avatar = Uri.encodeComponent(data['avatar']?.toString() ?? '');
        final liveLink =
            Uri.encodeComponent(data['liveLink']?.toString() ?? '');
        final rssLink = Uri.encodeComponent(data['rssLink']?.toString() ?? '');
        final isLive = data['isLive']?.toString() ?? 'false';
        final language =
            data['language']?.toString() ?? localLanguageNotifier.value;

        link =
            'testaapp://podcast/$id?programId=$programId&name=$name&program=$program&station=$station&description=$description&avatar=$avatar&liveLink=$liveLink&rssLink=$rssLink&isLive=$isLive&language=$language';
        break;

      case 'manynotifications':
        link = 'testaapp://home';
        break;

      default:
        final inferredFixtureId = _extractFixtureId(data);
        if (inferredFixtureId.isNotEmpty) {
          link = 'testaapp://matchDetail?fixtureId=$inferredFixtureId';
          break;
        }
        debugPrint('Unknown type for deep link: $type');
        link = 'testaapp://home';
    }

    debugPrint('âœ… Generated deep link: $link');
    return link;
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // âœ… DEEP LINK NAVIGATION
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static void _navigateToDeepLink(String deepLink) {
    debugPrint('🚀 STARTING NAVIGATION TO DEEP LINK: $deepLink');

    if (!_isGlobalRouterReady()) {
      _pendingDeepLink = deepLink;
      debugPrint('Router not ready while navigating. Re-queued: $deepLink');
      _schedulePendingDeepLinkRetry();
      return;
    }

    try {
      final uri = Uri.parse(deepLink);
      final String hostLower = uri.host.toLowerCase();
      final query = uri.queryParameters;
      final queryValues = Map<String, dynamic>.from(query);

      debugPrint('Host: $hostLower');
      debugPrint('Path segments: ${uri.pathSegments}');
      debugPrint('Query: $query');

      if (hostLower == 'matchdetail') {
        var fixtureId = _extractFixtureId(queryValues);
        if (fixtureId.isEmpty && uri.pathSegments.isNotEmpty) {
          fixtureId = _coerceNumericId(uri.pathSegments.last);
        }
        if (fixtureId.isEmpty) {
          fixtureId = _coerceNumericId(deepLink);
        }

        if (fixtureId.isNotEmpty) {
          debugPrint('→ Match detail: fixtureId=$fixtureId');
          globalRouter.go('/matchDetail?fixtureId=$fixtureId');
          return;
        }
      } else if (hostLower == 'newsdetail') {
        final newsId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
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
      } else if (hostLower == 'podcast') {
        final podcastId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
        if (podcastId != null && podcastId.isNotEmpty) {
          debugPrint('→ Podcast: id=$podcastId');
          globalRouter.go('/podcast/$podcastId', extra: query);
          return;
        }
      } else if (hostLower == 'home') {
        globalRouter.go('/home');
        return;
      }

      debugPrint('→ Unknown / invalid deep link format → fallback to home');
      _navigateWhenRouterReady('testaapp://home');
    } catch (e, st) {
      debugPrint('❌ Deep link error: $e');
      debugPrint(st.toString());
      _navigateWhenRouterReady('testaapp://home');
    }
  }

  // Helpers
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
    debugPrint(
        'ðŸŽ¯ Notification type $type â†’ $key: ${isEnabled ? "âœ…" : "âŒ"}');
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
      debugPrint('âš ï¸ Unknown match event subtype: $subtype');
      return true;
    }

    final isEnabled = prefs.getBool(settingKey) ?? true;
    debugPrint(
        'ðŸŽ¯ Match event $subtype â†’ $settingKey: ${isEnabled ? "âœ…" : "âŒ"}');
    return isEnabled;
  }

  Future<String> _getOrCreateDeviceId() async {
    try {
      return await getDeviceId();
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      var deviceId = prefs.getString('device_id');
      deviceId ??= DateTime.now().millisecondsSinceEpoch.toString();
      if (prefs.getString('device_id') == null) {
        await prefs.setString('device_id', deviceId);
      }
      return deviceId;
    }
  }

  Future<void> unregisterToken() async {
    final headers = await buildAuthHeaders();
    if (!headers.containsKey('Authorization')) return;

    try {
      final uri = Uri.parse('${BaseUrl().url}/api/fcm/unregister');
      await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'deviceId': await _getOrCreateDeviceId(),
        }),
      );
      debugPrint('??? FCM token unregistered');
    } catch (e) {
      debugPrint('??? Unregister failed: $e');
    }
  }

  static String _resolveNotificationType(Map<String, dynamic> data) {
    final explicitType = _readStringValue(
      data,
      const ['type', 'notificationType', 'notification_type'],
    ).toLowerCase();
    if (explicitType.isNotEmpty) {
      return explicitType;
    }

    if (_extractFixtureId(data).isNotEmpty) {
      return 'matchevent';
    }

    final newsId = _readStringValue(data, const ['newsId', 'news_id']);
    if (newsId.isNotEmpty) {
      return 'breakingnews';
    }

    final podcastId =
        _readStringValue(data, const ['programId', 'liveLink', 'rssLink']);
    if (podcastId.isNotEmpty) {
      return 'podcastlive';
    }

    return '';
  }

  static String _extractFixtureId(Map<String, dynamic> data) {
    final rawFixtureId = _readStringValue(
      data,
      const [
        'fixtureId',
        'fixtureID',
        'fixtureid',
        'fixture_id',
        'fixture',
        'matchId',
        'matchID',
        'matchid',
        'match_id',
      ],
    );
    return _coerceNumericId(rawFixtureId);
  }

  static String _extractFixtureIdFromDeepLinkFields(Map<String, dynamic> data) {
    const deepLinkKeys = [
      'deepLink',
      'deep_link',
      'deeplink',
      'link',
      'url',
      'route',
      'target',
      'targetUrl',
      'target_url',
      'click_action',
      'clickAction',
    ];

    final deepLinkCandidate = _readStringValue(data, deepLinkKeys);
    if (deepLinkCandidate.isNotEmpty) {
      final fixtureIdFromLink = _extractFixtureIdFromLink(deepLinkCandidate);
      if (fixtureIdFromLink.isNotEmpty) {
        return fixtureIdFromLink;
      }
    }

    final nestedPayload = _readStringValue(
      data,
      const [
        'payload',
        'notification_payload',
        'notificationPayload',
        'data',
        'extra',
        'meta',
      ],
    );
    if (nestedPayload.isEmpty ||
        !nestedPayload.trimLeft().startsWith('{') ||
        !nestedPayload.trimRight().endsWith('}')) {
      return '';
    }

    try {
      final decoded = jsonDecode(nestedPayload);
      if (decoded is! Map) {
        return '';
      }

      final nestedMap = Map<String, dynamic>.from(decoded);
      final nestedDeepLink = _readStringValue(nestedMap, deepLinkKeys);
      if (nestedDeepLink.isNotEmpty) {
        final nestedFixtureId = _extractFixtureIdFromLink(nestedDeepLink);
        if (nestedFixtureId.isNotEmpty) {
          return nestedFixtureId;
        }
      }

      return _extractFixtureId(nestedMap);
    } catch (_) {
      return '';
    }
  }

  static String _extractFixtureIdFromLink(String rawLink) {
    final trimmed = rawLink.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return '';
    }

    if (uri.scheme.isEmpty && uri.host.isEmpty && !trimmed.startsWith('/')) {
      uri = Uri.tryParse('testaapp://$trimmed');
      if (uri == null) {
        return '';
      }
    }

    final hostLower = uri.host.toLowerCase();
    final pathLower = uri.path.toLowerCase();
    final isMatchRoute =
        hostLower == 'matchdetail' || pathLower.contains('matchdetail');
    if (isMatchRoute) {
      final fixtureIdFromQuery =
          _extractFixtureId(Map<String, dynamic>.from(uri.queryParameters));
      if (fixtureIdFromQuery.isNotEmpty) {
        return fixtureIdFromQuery;
      }

      final pathSegments =
          uri.pathSegments.where((segment) => segment.trim().isNotEmpty);
      if (pathSegments.isNotEmpty) {
        final fixtureIdFromPath = _coerceNumericId(pathSegments.last);
        if (fixtureIdFromPath.isNotEmpty) {
          return fixtureIdFromPath;
        }
      }
    }

    if (trimmed.toLowerCase().contains('matchdetail')) {
      return _coerceNumericId(trimmed);
    }

    return '';
  }

  static String _coerceNumericId(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final intValue = int.tryParse(trimmed);
    if (intValue != null) {
      return intValue.toString();
    }

    final doubleValue = double.tryParse(trimmed);
    if (doubleValue != null) {
      return doubleValue.toInt().toString();
    }

    final firstDigits = RegExp(r'\d+').firstMatch(trimmed)?.group(0);
    return firstDigits ?? '';
  }

  static String _readStringValue(Map<String, dynamic> data, List<String> keys) {
    final normalizedEntries = <String, dynamic>{};
    data.forEach((key, value) {
      normalizedEntries[_normalizeKey(key)] = value;
    });

    for (final key in keys) {
      final value = data[key] ?? normalizedEntries[_normalizeKey(key)];
      if (value == null) continue;

      final normalized = _valueToNormalizedString(value);
      if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
        return normalized;
      }
    }
    return '';
  }

  static String _normalizeKey(String input) {
    final compact = input.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final codeUnit in compact.codeUnits) {
      final isAlphaNumeric = (codeUnit >= 48 && codeUnit <= 57) ||
          (codeUnit >= 97 && codeUnit <= 122);
      if (isAlphaNumeric) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  static String _valueToNormalizedString(dynamic value) {
    if (value is Map) {
      final candidates = [
        value['id'],
        value['Id'],
        value['ID'],
        value['fixtureId'],
        value['matchId'],
      ];
      for (final candidate in candidates) {
        final normalized = candidate?.toString().trim() ?? '';
        if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
          return normalized;
        }
      }
      return '';
    }

    return value.toString().trim();
  }
}

// Rest of the code (ensureBreakingNewsSubscription and FCMTopicManager) remains the same...
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Auto-subscribe helper
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

const _notificationPrefKeys = <String>[
  'Started',
  'Half time',
  'Full time',
  'Goals',
  'Red cards',
  'Missed penalty',
  'lineup',
  'Lineup',
  'Match reminder',
  'Substitution',
  'Vibration',
  'Sound',
  'Breaking News',
  'Official Highlights',
  'Podcasts',
  'Match Started',
  'Extra time',
  '15_min',
  'var',
  'all',
];

Future<void> enableAllNotificationPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in _notificationPrefKeys) {
    await prefs.setBool(key, true);
  }
}

Future<void> resubscribeUserTopics({
  required List<int> matchIds,
  required List<String> podcastIds,
  required String languageCode,
}) async {
  final lang = languageCode.trim().isEmpty ? 'am' : languageCode.trim();

  final uniqueMatchIds = matchIds.toSet();
  for (final fixtureId in uniqueMatchIds) {
    await FCMTopicManager.subscribeToMatch(
      fixtureId: fixtureId.toString(),
      languageCode: lang,
    );
  }

  final uniquePodcastIds = podcastIds.map((id) => id.trim()).toSet();
  for (final programId in uniquePodcastIds) {
    if (programId.isEmpty) continue;
    await FCMTopicManager.subscribeToPodcast(
      programId: programId,
      languageCode: lang,
    );
  }
}

/// Manages topic subscriptions
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      debugPrint('âœ… Subscribed â†’ $topic');
    } catch (e) {
      debugPrint('âŒ Subscribe failed â†’ $topic : $e');
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
        debugPrint(
            'âš ï¸ Invalid unsubscribe parameters: program=$program, lang=$lang');
        return false;
      }

      final topic = 'program_${program}_$lang';

      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('âœ… Unsubscribed: $topic');
      return true;
    } catch (e, st) {
      debugPrint('âŒ FCM unsubscribe failed â†’ $e');
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

    debugPrint(
        'ðŸ”” Breaking News Update: lang=$languageCode, enabled=$isEnabled, lastLang=$lastLanguage');

    if (!isEnabled) {
      if (lastLanguage != null && lastLanguage.isNotEmpty) {
        await fcm.unsubscribeFromTopic('breaking_news_$lastLanguage');
        debugPrint('âœ… Unsubscribed from breaking_news_$lastLanguage');
      }
      if (languageCode.isNotEmpty) {
        await fcm.unsubscribeFromTopic('breaking_news_$languageCode');
        debugPrint('âœ… Unsubscribed from breaking_news_$languageCode');
      }
      await prefs.remove(_lastLangKey);
      return;
    }

    if (lastLanguage != null && lastLanguage != languageCode) {
      await fcm.unsubscribeFromTopic('breaking_news_$lastLanguage');
      debugPrint(
          'âœ… Unsubscribed from old language: breaking_news_$lastLanguage');
    }

    await fcm.subscribeToTopic('breaking_news_$languageCode');
    debugPrint('âœ… Subscribed to breaking_news_$languageCode');

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
      debugPrint('âš½ Subscribed to Match: $topic');

      await _saveMatchSubscription(fixtureId, true);
    } catch (e) {
      debugPrint('âŒ Match Subscribe Error: $e');
    }
  }

  static Future<void> unsubscribeFromMatch({
    required String fixtureId,
    required String languageCode,
  }) async {
    final topic = 'testa_match_${fixtureId}_${languageCode.toLowerCase()}';

    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('ðŸ”• Unsubscribed from Match: $topic');

      await _saveMatchSubscription(fixtureId, false);
    } catch (e) {
      debugPrint('âŒ Match Unsubscribe Error: $e');
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

  static Future<void> _saveMatchSubscription(
      String fixtureId, bool isSubscribed) async {
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
    debugPrint(
        'ðŸ’¾ Match subscriptions updated: ${subscriptions.length} matches');
  }

  static Future<void> unsubscribeFromAllMatches(String languageCode) async {
    final subscribedMatches = await getSubscribedMatches();

    for (final fixtureId in subscribedMatches) {
      await unsubscribeFromMatch(
          fixtureId: fixtureId, languageCode: languageCode);
    }

    debugPrint('âœ… Unsubscribed from all ${subscribedMatches.length} matches');
  }

  static Future<void> resubscribeMatchesForLanguage({
    required String oldLanguageCode,
    required String newLanguageCode,
  }) async {
    final subscribedMatches = await getSubscribedMatches();

    debugPrint(
        'ðŸ”„ Resubscribing ${subscribedMatches.length} matches: $oldLanguageCode â†’ $newLanguageCode');

    final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

    for (final fixtureId in subscribedMatches) {
      for (final lang in allPossibleLanguages) {
        if (lang != newLanguageCode) {
          try {
            final oldTopic = 'testa_match_${fixtureId}_${lang.toLowerCase()}';
            await _messaging.unsubscribeFromTopic(oldTopic);
            debugPrint('ðŸ”• Unsubscribed: $oldTopic');
          } catch (e) {
            debugPrint('âš ï¸ Failed to unsubscribe from $lang match: $e');
          }
        }
      }

      final newTopic =
          'testa_match_${fixtureId}_${newLanguageCode.toLowerCase()}';
      await _messaging.subscribeToTopic(newTopic);
      debugPrint('âœ… Subscribed: $newTopic');
    }

    debugPrint('âœ… Resubscribed ${subscribedMatches.length} matches complete');
  }

  // Language change handler
  static Future<void> updateLanguageSubscriptions({
    required String oldLanguageCode,
    required String newLanguageCode,
  }) async {
    debugPrint(
        'ðŸŒ Updating language subscriptions: $oldLanguageCode â†’ $newLanguageCode');

    final prefs = await SharedPreferences.getInstance();
    final breakingNewsEnabled = prefs.getBool('Breaking News') ?? true;

    if (breakingNewsEnabled) {
      final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

      debugPrint('ðŸ§¹ Cleaning up all possible old language subscriptions...');
      for (final lang in allPossibleLanguages) {
        if (lang != newLanguageCode) {
          try {
            await _messaging.unsubscribeFromTopic('breaking_news_$lang');
            debugPrint('ðŸ”• Unsubscribed from breaking_news_$lang');
          } catch (e) {
            debugPrint(
                'âš ï¸ Failed to unsubscribe from breaking_news_$lang: $e');
          }
        }
      }

      await _messaging.subscribeToTopic('breaking_news_$newLanguageCode');
      debugPrint('âœ… Subscribed to breaking_news_$newLanguageCode');

      await prefs.setString(_lastLangKey, newLanguageCode);
    }

    await resubscribeMatchesForLanguage(
      oldLanguageCode: oldLanguageCode,
      newLanguageCode: newLanguageCode,
    );

    debugPrint('âœ… Language subscriptions updated successfully');
  }

  static Future<void> cleanupAllLanguageSubscriptions() async {
    debugPrint(
        'ðŸ§¹ Performing complete cleanup of all language subscriptions...');

    final allPossibleLanguages = ['en', 'am', 'or', 'tr', 'so'];

    for (final lang in allPossibleLanguages) {
      try {
        await _messaging.unsubscribeFromTopic('breaking_news_$lang');
        debugPrint('ðŸ”• Unsubscribed from breaking_news_$lang');
      } catch (e) {
        debugPrint('âš ï¸ Failed to unsubscribe from breaking_news_$lang: $e');
      }
    }

    final subscribedMatches = await getSubscribedMatches();
    for (final fixtureId in subscribedMatches) {
      for (final lang in allPossibleLanguages) {
        try {
          await _messaging
              .unsubscribeFromTopic('testa_match_${fixtureId}_$lang');
          debugPrint('ðŸ”• Unsubscribed from testa_match_${fixtureId}_$lang');
        } catch (e) {
          debugPrint('âš ï¸ Failed to unsubscribe: $e');
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLangKey);

    debugPrint('âœ… Complete cleanup finished');
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

    debugPrint(
        'FCM cleanup on logout completed for language: $currentLanguage');
  }
}
