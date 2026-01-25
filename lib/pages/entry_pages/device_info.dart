import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import '../../util/auth/getDeviceInfo.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';

Future<void> deviceInfo() async {
  String url = BaseUrl().url;
  final Map<String, dynamic> deviceData = await phone_info();
  String token = await getAccessToken();

  try {
    final response = await http.post(
      Uri.parse('$url/api/authentication/deviceinfo'),
      headers: {
        'Content-Type': 'application/json',
        'accesstoken': token,
      },
      body: json.encode({
        'deviceInfo': deviceData,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await storeAccessToken(jsonDecode(response.body)['accessToken']);
      print(response.body);
    } else {}
  } catch (e) {
    print('Network error occurred');
  }
}

Future<Map<String, dynamic>> phone_info() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final Map<String, dynamic> deviceData = <String, dynamic>{};

  // Use the same getDeviceId function for consistency
  String deviceId = await getDeviceId();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    deviceData.addAll({
      'deviceId': deviceId, // ✅ Use consistent device ID
      'board': androidInfo.board,
      'brand': androidInfo.brand,
      'device': androidInfo.device,
      'model': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'version': {
        'sdkInt': androidInfo.version.sdkInt,
        'release': androidInfo.version.release,
      },
    });
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    deviceData.addAll({
      'deviceId': deviceId, // ✅ Use consistent device ID
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'model': iosInfo.model,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
    });
  }

  final ipinfo = await fetchip();
  deviceData['ipAddress'] = ipinfo;

  return deviceData;
}

Future<String> fetchip() async {
  try {
    final respons =
        await http.get(Uri.parse('https://api64.ipify.org?format=json'));
    if (respons.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(respons.body);
      return data['ip'];
    } else {
      throw Exception('failed to fetch ip adress');
    }
  } catch (e) {
    print('error');
    return 'unknown';
  }
}
