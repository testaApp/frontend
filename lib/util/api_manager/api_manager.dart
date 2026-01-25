import 'package:dio/dio.dart';

import '../auth/tokens.dart';
import '../baseUrl.dart';
import '../notifiers/initial_location_notifier.dart';

class ApiManager {
  static final ApiManager _singleton = ApiManager._internal();
  late Dio _dio;

  ApiManager._internal() {
    _dio = Dio();
  }

  static Future<Response> fetchData(String url,
      {bool useRefreshToken = false}) async {
    String accessToken = await getAccessToken();
    String refreshToken = useRefreshToken ? await getRefreshToken() ?? '' : '';

    _singleton._dio.options.headers['accesstoken'] = accessToken;

    if (useRefreshToken) {
      _singleton._dio.options.headers['refreshtoken'] = refreshToken;
    }
    String baseUrl = BaseUrl().url;

    try {
      Response response = await _singleton._dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401 && !useRefreshToken) {
        Dio dio = Dio();
        try {
          Response res = await dio.get('$baseUrl/refresh',
              options: Options(headers: {'refresh-token': refreshToken}));
          if (res.statusCode == 200) {
            response = await _singleton._dio.get(url);
          } else {
            await clearTokens();
            initialLocation.value = '/language';
          }
        } catch (e) {}
      } else if (response.statusCode == 401) {
        await clearTokens();
        initialLocation.value = '/language';
      }
      return response;
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: ''), statusCode: 500);
    }
  }

  static Future<Response?> postData(String url, Map<String, dynamic> body,
      {bool useRefreshToken = false, bool useAccessToken = true}) async {
    String refreshToken = useRefreshToken ? await getRefreshToken() ?? '' : '';

    if (useRefreshToken) {
      _singleton._dio.options.headers['refreshtoken'] = refreshToken;
    }
    if (useAccessToken) {
      String accessToken = await getAccessToken();
      _singleton._dio.options.headers['accesstoken'] = accessToken;
    }

    _singleton._dio.options.headers['Content-Type'] = 'application/json';

    String baseUrl = BaseUrl().url;
    try {
      Response response = await _singleton._dio.post(url, data: body);
      if (response.statusCode == 401 && !useRefreshToken) {
        Dio dio = Dio();
        try {
          Response res = await dio.get('$baseUrl/refresh',
              options: Options(headers: {'refresh-token': refreshToken}));

          if (res.statusCode == 200 || res.statusCode == 201) {
            await storeAccessToken(res.data['accesstoken']);
            await storeRefreshToken(res.data['refreshToken']);
            response = await _singleton._dio.post(url, data: body);
          } else {
            await clearTokens();
            initialLocation.value = '/language';
          }
        } catch (e) {}
      } else if (response.statusCode == 401) {
        await clearTokens();
        initialLocation.value = '/language';
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        await storeAccessToken(response.data['accessToken']);
        await storeRefreshToken(response.data['refreshToken']);
      }
      return response;
    } catch (e) {
      return null;
    }
  }
}
