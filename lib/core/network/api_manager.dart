import 'package:dio/dio.dart';

import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';

class ApiManager {
  static final ApiManager _singleton = ApiManager._internal();
  late Dio _dio;

  ApiManager._internal() {
    _dio = Dio();
  }

  static Future<Response> fetchData(String url,
      {bool useRefreshToken = false}) async {
    final headers = await buildAuthHeaders();
    _singleton._dio.options.headers = headers;
    final requestUrl = url.startsWith('http://') || url.startsWith('https://')
        ? url
        : '${BaseUrl().url}$url';
    print('Fetching data from: $requestUrl');

    try {
      Response response = await _singleton._dio.get(requestUrl);

      if (response.statusCode == 401) {
        final refreshed = await getFirebaseIdToken(forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty) {
          _singleton._dio.options.headers['Authorization'] =
              'Bearer $refreshed';
          response = await _singleton._dio.get(requestUrl);
        }
      }
      return response;
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: ''), statusCode: 500);
    }
  }

  static Future<Response?> postData(String url, Map<String, dynamic> body,
      {bool useRefreshToken = false, bool useAccessToken = true}) async {
    if (useAccessToken) {
      _singleton._dio.options.headers = await buildAuthHeaders();
    } else {
      _singleton._dio.options.headers = {'Content-Type': 'application/json'};
    }

    final requestUrl = url.startsWith('http://') || url.startsWith('https://')
        ? url
        : '${BaseUrl().url}$url';

    try {
      Response response = await _singleton._dio.post(requestUrl, data: body);
      if (response.statusCode == 401 && useAccessToken) {
        final refreshed = await getFirebaseIdToken(forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty) {
          _singleton._dio.options.headers['Authorization'] =
              'Bearer $refreshed';
          response = await _singleton._dio.post(requestUrl, data: body);
        }
      }
      return response;
    } catch (e) {
      return null;
    }
  }
}
