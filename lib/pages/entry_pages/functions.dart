// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../../components/routenames.dart';
// import '../../functions/check_settings.dart';
// import '../../localization/demo_localization.dart';
// import '../../main.dart';
// import '../../notifications/notifier.dart';
// import '../../notifications/showNotification.dart';
// import '../../util/auth/tokens.dart';
// import '../../util/baseUrl.dart';

// class Functionsinit {
//   static IO.Socket? _socket;
//   static bool _isConnected = false;

// Future<void> initializeSocket() async {
//   try {
//     if (_socket != null && _isConnected) return;

//     _socket = IO.io(
//       BaseUrl().url,
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableReconnection()
//           .setReconnectionAttempts(999)
//           .setReconnectionDelay(2000)
//           .build(),
//     );

//     _socket!.onConnect((_) async {
//       _isConnected = true;
//       print('✅ Socket connected');

//       String? accessToken = await getAccessToken();
//       if (accessToken != null) {
//         _socket!.emit('registerUser', accessToken);
//       }
//     });

//     _socket!.onDisconnect((_) {
//       _isConnected = false;
//       print('🔌 Socket disconnected');
//     });

//     _socket!.onConnectError((err) {
//       print('❌ Socket error: $err');
//     });

//     _socket!.onError((err) {
//       print('❌ General socket error: $err');
//     });

    

//   } catch (e) {
//     print("❌ Socket init crashed but ignored: $e");
//   }
// }
// }
