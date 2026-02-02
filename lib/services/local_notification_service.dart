import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

/// Service to handle local notifications in coordination with FCM
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Callback to handle notification taps
  Function(RemoteMessage)? onNotificationTap;

  // ────────────────────────────────────────────────
  // Initialize local notifications
  // ────────────────────────────────────────────────
  Future<void> initialize({
    required Function(RemoteMessage) onTapCallback,
  }) async {
    if (_isInitialized) return;

    onNotificationTap = onTapCallback;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

   await _notificationsPlugin.initialize(
  settings: initSettings,
  onDidReceiveNotificationResponse: _onNotificationTapped,
  onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
);

    _isInitialized = true;
    debugPrint('✅ Local Notification Service initialized');
  }

  // ────────────────────────────────────────────────
  // Handle notification tap
  // ────────────────────────────────────────────────
  @pragma('vm:entry-point')
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('👆 LOCAL NOTIFICATION TAPPED');
    debugPrint('   Payload: ${response.payload}');
    debugPrint('═══════════════════════════════════════════════════════════');

    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint('❌ No payload in notification');
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      final remoteMessage = RemoteMessage(
        messageId: data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        data: Map<String, dynamic>.from(data),
      );

      // Call the callback
      LocalNotificationService().onNotificationTap?.call(remoteMessage);
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
    }
  }

  // ────────────────────────────────────────────────
  // Show notification from FCM message
  // ────────────────────────────────────────────────
  Future<void> showNotificationFromFCM(RemoteMessage message) async {
    debugPrint('📱 Showing local notification for FCM message: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    // Create notification details
    final androidDetails = AndroidNotificationDetails(
      'fcm_default_channel', // Channel ID
      'FCM Notifications', // Channel name
      channelDescription: 'Notifications from Firebase Cloud Messaging',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Prepare payload with all FCM data
    final payload = jsonEncode({
      'messageId': message.messageId,
      ...data,
    });

    // Show the notification
  await _notificationsPlugin.show(
  id: DateTime.now().millisecondsSinceEpoch % 100000,
  title: notification?.title ?? _getDefaultTitle(data['type']),
  body: notification?.body ?? _getDefaultBody(data),
  notificationDetails: notificationDetails,
  payload: payload,
);

    debugPrint('✅ Local notification displayed');
  }

  // ────────────────────────────────────────────────
  // Helper methods for default notification content
  // ────────────────────────────────────────────────
  String _getDefaultTitle(String? type) {
    switch (type?.toLowerCase()) {
      case 'breakingnews':
        return 'Breaking News';
      case 'matchevent':
        return 'Match Update';
      case 'podcastlive':
        return 'Podcast Live';
      default:
        return 'Testa App';
    }
  }

  String _getDefaultBody(Map<String, dynamic> data) {
    final type = data['type']?.toLowerCase();
    switch (type) {
      case 'matchevent':
        final subtype = data['subtype']?.toLowerCase();
        return 'Match ${subtype ?? 'update'}';
      case 'breakingnews':
        return 'New breaking news available';
      case 'podcastlive':
        return data['name'] ?? 'Live podcast available';
      default:
        return 'You have a new notification';
    }
  }

  // ────────────────────────────────────────────────
  // Cancel all notifications
  // ────────────────────────────────────────────────
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🔕 All local notifications cancelled');
  }

  // ────────────────────────────────────────────────
  // Request permissions (iOS)
  // ────────────────────────────────────────────────
  Future<bool> requestPermissions() async {
    final result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? true;
  }
}