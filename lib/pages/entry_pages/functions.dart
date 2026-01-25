import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../components/routenames.dart';
import '../../functions/check_settings.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import '../../notifications/notifier.dart';
import '../../notifications/showNotification.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';

class Functionsinit {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  Future<void> initializeSocket() async {
    if (_socket != null && _isConnected) {
      print('✅ Socket already initialized and connected');
      return;
    }

    print('🔌 Initializing socket connection...');

    _socket = IO.io(
      BaseUrl().url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': 'qwertyuioiuytre'})
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.onConnect((_) async {
      print('✅ Socket connected successfully');
      _isConnected = true;

      String? accessToken = await getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        print('📤 Emitting registerUser...');
        _socket!.emit('registerUser', accessToken);

        print('📤 Emitting getFavorites...');
        _socket!.emit('getFavorites', accessToken);
      } else {
        print('❌ No access token available');
      }
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    _socket!.on('ev', (data) async {
      print('📥 Event received: $data');
      _handleMatchEvent(data);
    });
  }

  Future<void> _handleMatchEvent(Map<String, dynamic> data) async {
    bool? showNotificationRes = await checkSettings(data['type']);

    if (showNotificationRes == true || showNotificationRes == null) {
      String deviceLanguage = localLanguageNotifier.value;
      String title, body;

      switch (deviceLanguage) {
        case 'am':
          title = data['event-am'];
          body = data[deviceLanguage];
          break;
        case 'tr':
          title = data['event-ti'];
          body = data[deviceLanguage];
          break;
        case 'or':
          title = data['event-or'];
          body = data[deviceLanguage];
          break;
        case 'so':
          title = data['event-so'];
          body = data[deviceLanguage];
          break;
        default:
          title = data['event'];
          body = data['team'];
      }

      await scheduleNotificationAfterDelay(
        title: title,
        body: body,
        type: data['type'],
        imageUrl: data['image'],
        fixtureId: data['fixtureId'],
      );
      print('Notification scheduled with title: $title and body: $body');
    }
  }
}
