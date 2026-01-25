import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

// In getDeviceInfo.dart - make this the source of truth
Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId = '';
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.id; // Android ID
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor ?? 'unknown';
  }
  return deviceId;
}
