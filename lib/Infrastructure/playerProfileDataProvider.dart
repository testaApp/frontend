import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/core/failure.dart';
import '../domain/player/playerProfile.dart';
import '../util/baseUrl.dart';

class PlayerProfileDataProvider {
  static String baseURL = '${BaseUrl().url}/api';

  Future<Profile> fetchProfileData(String name, int league, int season) async {
    final Uri uri = Uri.parse(
        '$baseURL/player-data?search=$name&league=$league&season=$season');
    final response = await http.get(uri);
    ////print(response.body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Profile.fromJson(json[0] as Map<String, dynamic>);
    } else {
      throw Failure('Failed to fetch profile data');
    }
  }
}
