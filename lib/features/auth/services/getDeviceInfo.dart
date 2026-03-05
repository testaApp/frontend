import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// In getDeviceInfo.dart - make this the source of truth
Future<String> getDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getString('device_id');
  if (cached != null && cached.isNotEmpty) return cached;

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final secure = await storage.read(key: 'device_id');
  if (secure != null && secure.isNotEmpty) {
    await prefs.setString('device_id', secure);
    return secure;
  }

  final deviceInfo = DeviceInfoPlugin();
  var deviceId = '';

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final androidId = androidInfo.data['androidId']?.toString();
      deviceId = (androidId != null && androidId.isNotEmpty)
          ? androidId
          : androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }
  } catch (_) {}

  if (deviceId.isEmpty) {
    deviceId = _generateFallbackId();
  }

  await prefs.setString('device_id', deviceId);
  await storage.write(key: 'device_id', value: deviceId);

  return deviceId;
}

String _generateFallbackId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
