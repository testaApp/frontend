import '../util/api_manager/api_manager.dart';
import '../util/baseUrl.dart';

class Ads {
  final Map<String, String> Ad_pic;
  final Map<String, String> Ad_redirect;
  final Map<String, String> Ad_video;
  final Map<String, dynamic> additionalData;

  Ads({
    required this.Ad_pic,
    required this.Ad_redirect,
    required this.Ad_video,
    required this.additionalData,
  });

  static fromListJson(List<dynamic> json) {
    return json.map((e) => Ads.fromJson(e as Map<String, dynamic>)).toList();
  }

  factory Ads.fromJson(Map<String, dynamic> json) {
    Map<String, String> extractCategory(String suffix) {
      String prefix = suffix.isEmpty ? '' : '_$suffix';
      return {
        'Ad_pic': json['Ad_pic$prefix'] ?? '',
        'Ad_redirect': json['Ad_redirect$prefix'] ?? '',
        'Ad_video': json['Ad_video$prefix'] ?? '',
      };
    }

    final categories = ['', 'am', 'or', 'tr', 'so'];
    Map<String, String> adPic = {};
    Map<String, String> adRedirect = {};
    Map<String, String> adVideo = {};

    for (var suffix in categories) {
      var data = extractCategory(suffix);
      String categoryKey = suffix.isEmpty ? 'default' : suffix;
      adPic[categoryKey] = data['Ad_pic']!;
      adRedirect[categoryKey] = data['Ad_redirect']!;
      adVideo[categoryKey] = data['Ad_video']!;
    }

    return Ads(
      Ad_pic: adPic,
      Ad_redirect: adRedirect,
      Ad_video: adVideo,
      additionalData: json,
    );
  }
}

class AdsRepository {
  final String endpoint;

  AdsRepository({this.endpoint = '/ads'});

  getAds() async {
    final String url = BaseUrl().url + endpoint;
    try {
      final response = await ApiManager.fetchData(url);
      return Ads.fromListJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
