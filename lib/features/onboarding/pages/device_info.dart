import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/features/auth/services/getDeviceInfo.dart';
import 'package:blogapp/services/analytics_service.dart';

Future<void> deviceInfo() async {
  final url = BaseUrl().url;
  final Map<String, dynamic> deviceData = await phone_info();
  final headers = await buildAuthHeaders();

  await _logDeviceInfoAnalytics(deviceData);

  try {
    final response = await http.post(
      Uri.parse('$url/api/authentication/deviceinfo'),
      headers: headers,
      body: json.encode({
        'deviceInfo': deviceData,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response.body);
    }
  } catch (e) {
    print('Network error occurred');
  }
}

Future<Map<String, dynamic>> phone_info() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final Map<String, dynamic> deviceData = <String, dynamic>{};

  final deviceId = await getDeviceId();
  deviceData['deviceId'] = deviceId;
  deviceData['capturedAt'] = DateTime.now().toUtc().toIso8601String();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    deviceData.addAll({
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
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'model': iosInfo.model,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
    });
  }

  final networkInfo = await _collectNetworkInfo();
  var locationInfo = await _collectIpLocationInfo();
  String ipAddress = locationInfo['ip']?.toString().trim() ?? '';
  locationInfo.remove('ip');

  if (locationInfo['status']?.toString() != 'ok') {
    final fallbackLocation = await _collectIpWhoLocationInfo();
    if (fallbackLocation['status']?.toString() == 'ok') {
      locationInfo = fallbackLocation;
      ipAddress = fallbackLocation['ip']?.toString().trim() ?? ipAddress;
      locationInfo.remove('ip');
    }
  }

  if (ipAddress.isEmpty) {
    ipAddress = 'unknown';
  }

  deviceData['ipAddress'] = ipAddress;
  final batteryInfo = await _collectBatteryInfo();
  final displayInfo = _collectDisplayInfo();
  final appInfo = await _collectAppInfo();

  deviceData['network'] = networkInfo;
  deviceData['location'] = locationInfo;
  deviceData['battery'] = batteryInfo;
  deviceData['display'] = displayInfo;
  deviceData['app'] = appInfo;

  return deviceData;
}

Future<Map<String, dynamic>> _collectNetworkInfo() async {
  try {
    final connectivity = Connectivity();
    final dynamic result = await connectivity.checkConnectivity();
    final List<ConnectivityResult> values = result is List<ConnectivityResult>
        ? result
        : <ConnectivityResult>[result as ConnectivityResult];
    final types = values.map((value) => value.name).toSet().toList()..sort();

    if (types.isEmpty) {
      types.add(ConnectivityResult.none.name);
    }

    final connectionType = _resolveConnectionType(types);
    return {
      'types': types,
      'connection_type': connectionType,
      'isConnected': types.any((type) => type != ConnectivityResult.none.name),
    };
  } catch (_) {
    return {
      'types': ['unknown'],
      'connection_type': 'unknown',
      'isConnected': false,
    };
  }
}

Future<Map<String, dynamic>> _collectIpLocationInfo() async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'http://ip-api.com/json/?fields=status,message,query,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,mobile,proxy,hosting',
          ),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      return {
        'status': 'lookup_failed',
        'source': 'ip-api.com',
      };
    }

    final data = json.decode(response.body);
    if (data is! Map<String, dynamic> || data['status'] != 'success') {
      return {
        'status': 'lookup_failed',
        'source': 'ip-api.com',
        'message': data is Map ? data['message']?.toString() : null,
      };
    }

    final location = <String, dynamic>{
      'status': 'ok',
      'source': 'ip-api.com',
      'location_precision': 'city',
      'ip': data['query'],
      'country': data['country'],
      'country_code': data['countryCode'],
      'region': data['regionName'] ?? data['region'],
      'city': data['city'],
      'postal_code': data['zip'],
      'latitude': data['lat'],
      'longitude': data['lon'],
      'timezone': data['timezone'],
      'isp': data['isp'],
      'org': data['org'],
      'asn': data['as'],
      'is_mobile': data['mobile'],
      'is_proxy': data['proxy'],
      'is_hosting': data['hosting'],
      'formatted': _joinLocationLabel(
        city: data['city']?.toString(),
        region: (data['regionName'] ?? data['region'])?.toString(),
        country: data['country']?.toString(),
      ),
    };

    location.removeWhere((key, value) => value == null);
    return location;
  } catch (_) {
    return {
      'status': 'lookup_error',
      'source': 'ip-api.com',
    };
  }
}

Future<Map<String, dynamic>> _collectIpWhoLocationInfo() async {
  try {
    final response = await http
        .get(Uri.parse('https://ipwho.is/'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      return {
        'status': 'lookup_failed',
        'source': 'ipwho.is',
      };
    }

    final data = json.decode(response.body);
    if (data is! Map<String, dynamic> || data['success'] != true) {
      return {
        'status': 'lookup_failed',
        'source': 'ipwho.is',
      };
    }

    final timezoneData = data['timezone'];
    final connectionData = data['connection'];
    final isp = connectionData is Map ? connectionData['isp'] : null;
    final location = <String, dynamic>{
      'status': 'ok',
      'source': 'ipwho.is',
      'location_precision': 'city',
      'ip': data['ip'],
      'country': data['country'],
      'region': data['region'],
      'city': data['city'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'timezone': timezoneData is Map ? timezoneData['id'] : timezoneData,
      'isp': isp,
      'formatted': _joinLocationLabel(
        city: data['city']?.toString(),
        region: data['region']?.toString(),
        country: data['country']?.toString(),
      ),
    };

    location.removeWhere((key, value) => value == null);
    return location;
  } catch (_) {
    return {
      'status': 'lookup_error',
      'source': 'ipwho.is',
    };
  }
}

Future<Map<String, dynamic>> _collectBatteryInfo() async {
  final battery = Battery();
  int? level;
  String? state;
  String? error;

  try {
    level = await battery.batteryLevel.timeout(const Duration(seconds: 5));
  } catch (e) {
    error = e.toString();
  }

  try {
    state =
        (await battery.batteryState.timeout(const Duration(seconds: 5))).name;
  } catch (e) {
    error = error == null ? e.toString() : '$error | $e';
  }

  if (level == null && state == null) {
    return {
      'status': 'unavailable',
      'battery_level': null,
      if (error != null) 'error': error,
    };
  }

  final normalized = level == null ? null : _round(level / 100, 2);
  return {
    'status': (level != null && state != null) ? 'ok' : 'partial',
    if (level != null) 'levelPercent': level,
    'battery_level': normalized,
    if (state != null) 'state': state,
    if (error != null) 'error': error,
  };
}

Map<String, dynamic> _collectDisplayInfo() {
  final views = ui.PlatformDispatcher.instance.views;
  if (views.isEmpty) {
    return {
      'status': 'unavailable',
    };
  }

  final view = views.first;
  final pixelRatio = view.devicePixelRatio <= 0 ? 1.0 : view.devicePixelRatio;
  final physical = view.physicalSize;
  final logicalWidth = physical.width / pixelRatio;
  final logicalHeight = physical.height / pixelRatio;

  return {
    'devicePixelRatio': _round(pixelRatio, 2),
    'physicalWidthPx': physical.width.round(),
    'physicalHeightPx': physical.height.round(),
    'logicalWidthDp': _round(logicalWidth, 2),
    'logicalHeightDp': _round(logicalHeight, 2),
    'screen_size': '${logicalWidth.round()}x${logicalHeight.round()}',
    'orientation': logicalWidth >= logicalHeight ? 'landscape' : 'portrait',
  };
}

Future<Map<String, dynamic>> _collectAppInfo() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return {
      'app_name': info.appName,
      'package_name': info.packageName,
      'app_version': info.version,
      'build_number': info.buildNumber,
    };
  } catch (_) {
    return {
      'app_version': 'unknown',
    };
  }
}

String _resolveConnectionType(List<String> types) {
  if (types.isEmpty) return 'unknown';
  if (types.length > 1 &&
      types.any((type) => type != ConnectivityResult.none.name)) {
    if (types.contains(ConnectivityResult.wifi.name)) return 'wifi';
    if (types.contains(ConnectivityResult.mobile.name)) return 'mobile';
    return 'multiple';
  }

  final type = types.first;
  if (type == ConnectivityResult.wifi.name) return 'wifi';
  if (type == ConnectivityResult.mobile.name) return 'mobile';
  if (type == ConnectivityResult.ethernet.name) return 'ethernet';
  if (type == ConnectivityResult.vpn.name) return 'vpn';
  if (type == ConnectivityResult.bluetooth.name) return 'bluetooth';
  if (type == ConnectivityResult.none.name) return 'none';
  return type;
}

String _extractCarrier(
  Map<String, dynamic> networkInfo,
  Map<String, dynamic> locationInfo,
) {
  final networkCarrier = networkInfo['carrier']?.toString().trim();
  if (networkCarrier != null && networkCarrier.isNotEmpty) {
    return networkCarrier;
  }

  final locationCarrier = locationInfo['carrier']?.toString().trim();
  if (locationCarrier != null && locationCarrier.isNotEmpty) {
    return locationCarrier;
  }

  final isp = locationInfo['isp']?.toString().trim();
  if (isp != null && isp.isNotEmpty) {
    return isp;
  }

  return 'unknown';
}

Future<void> _logDeviceInfoAnalytics(Map<String, dynamic> deviceData) async {
  try {
    final analytics = FollowingAnalyticsService();
    final networkInfo = _asMap(deviceData['network']);
    final locationInfo = _asMap(deviceData['location']);
    final batteryInfo = _asMap(deviceData['battery']);
    final appInfo = _asMap(deviceData['app']);
    final displayInfo = _asMap(deviceData['display']);

    await analytics.logEvent(
      name: 'device_info_collected',
      parameters: {
        'connection_type': networkInfo['connection_type'] ?? 'unknown',
        'carrier': _extractCarrier(networkInfo, locationInfo),
        'battery_level': batteryInfo['battery_level'] ?? -1.0,
        'app_version': appInfo['app_version'] ?? 'unknown',
        'screen_size': displayInfo['screen_size'] ?? 'unknown',
      },
    );
  } catch (_) {
    // Analytics failures should not block onboarding.
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _joinLocationLabel({
  String? city,
  String? region,
  String? country,
}) {
  final parts = <String>[
    if (city != null && city.trim().isNotEmpty) city.trim(),
    if (region != null && region.trim().isNotEmpty) region.trim(),
    if (country != null && country.trim().isNotEmpty) country.trim(),
  ];
  return parts.join(', ');
}

double _round(double value, int fractionDigits) {
  return double.parse(value.toStringAsFixed(fractionDigits));
}
