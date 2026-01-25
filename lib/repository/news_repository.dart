import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/details.dart';
import '../models/news.dart';
import '../util/api_manager/api_manager.dart';
import '../util/baseUrl.dart';

final String url = BaseUrl().url;

class NewsRepository {
  Future<List<News>> getnews({
    required int page,
    required String lang,
    required String queryUrl,
  }) async {
    final response = await ApiManager.fetchData(
      '$queryUrl/?page=$page&lang=$lang',
      useRefreshToken: true,
    );

    try {
      List<News> newsList = [];
      if (response.data != null && response.data is List) {
        for (var json in response.data) {
          if (json != null && json is Map) {
            // Extract mainImages as List<ImageModel>
            List<ImageModel> mainImages = [];
            if (json['mainImages'] != null && json['mainImages'] is List) {
              mainImages = (json['mainImages'] as List)
                  .map((image) => ImageModel(
                        url: image['url'] ?? '',
                        caption: image['caption'] ?? '',
                      ))
                  .toList();
            }

            final news = News(
              id: json['id'] ?? '',
              mainImages: mainImages.isNotEmpty
                  ? mainImages
                  : [
                      ImageModel(
                          url: json['sourceimage'] ?? '',
                          caption: json['figCaption'] ?? '')
                    ],
              author: json['author'] ?? '',
              figCaption: json['figCaption'] ?? '',
              time: json['publishedDate'] ?? '',
              summarized: json['summarized'] ?? '',
              summarizedTitle: json['summarizedTitle'] ?? '',
              sourceimage: json['sourceimage'],
              sourcename: json['sourcename'],
              source: json['source'],
            );
            newsList.add(news);
          }
        }
      }
      return newsList;
    } catch (e) {
      rethrow;
    }
  }

  Future<News?> getNewsById(String id, String lang) async {
    try {
      final response = await ApiManager.fetchData(
        '$url/news/$id?lang=$lang',
        useRefreshToken: true,
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        final json = response.data;

        // Extract mainImages as List<ImageModel>
        List<ImageModel> mainImages = [];
        if (json['mainImages'] != null && json['mainImages'] is List) {
          mainImages = (json['mainImages'] as List)
              .map((image) => ImageModel(
                    url: image['url'] ?? '',
                    caption: image['caption'] ?? '',
                  ))
              .toList();
        }

        final news = News(
          id: json['id'] ?? '',
          mainImages: mainImages.isNotEmpty
              ? mainImages
              : [
                  ImageModel(
                      url: json['sourceimage'] ?? '',
                      caption: json['figCaption'] ?? '')
                ],
          author: json['author'] ?? '',
          figCaption: json['figCaption'] ?? '',
          time: json['publishedDate'] ?? '',
          summarized: json['summarized'] ?? '',
          summarizedTitle: json['summarizedTitle'] ?? '',
          sourceimage: json['sourceimage'],
          sourcename: json['sourcename'],
          source: json['source'],
        );
        return news;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<News>> getTrendingNews({
    required String lang,
    required int page,
  }) async {
    final response = await ApiManager.fetchData(
      '$url/trending?lang=$lang&page=$page',
      useRefreshToken: true,
    );

    try {
      List<News> trendingNewsList = [];
      if (response.data != null && response.data is List) {
        for (var json in response.data) {
          if (json != null && json is Map) {
            List<ImageModel> mainImages = [];
            if (json['mainImages'] != null && json['mainImages'] is List) {
              mainImages = (json['mainImages'] as List)
                  .map((image) => ImageModel(
                        url: image['url'] ?? '',
                        caption: image['caption'] ?? '',
                      ))
                  .toList();
            }

            final news = News(
              id: json['id'] ?? '',
              mainImages: mainImages.isNotEmpty
                  ? mainImages
                  : [
                      ImageModel(
                          url: json['sourceimage'] ?? '',
                          caption: json['figCaption'] ?? '')
                    ],
              author: json['author'] ?? '',
              figCaption: json['figCaption'] ?? '',
              time: json['publishedDate'] ?? '',
              summarized: json['summarized'] ?? '',
              summarizedTitle: json['summarizedTitle'] ?? '',
              sourceimage: json['sourceimage'],
              sourcename: json['sourcename'],
              source: json['source'],
            );
            trendingNewsList.add(news);
          }
        }
      }

      return trendingNewsList;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<News>> getLeagueNews({
    required int page,
    required String lang,
    required int leagueId,
  }) async {
    final response = await ApiManager.fetchData(
      '$url/api/leagues/news?leagueId=$leagueId&lang=$lang&page=$page',
      useRefreshToken: true,
    );
    try {
      final jsonData = response.data;
      List<News> newsList = [];

      for (var i = 0; i < jsonData.length; i++) {
        final json = jsonData[i];

        // Extract mainImages as List<ImageModel>
        List<ImageModel> mainImages = [];
        if (json['mainImages'] != null && json['mainImages'] is List) {
          mainImages = (json['mainImages'] as List)
              .map((image) => ImageModel(
                    url: image['url'] ?? '',
                    caption: image['caption'] ?? '',
                  ))
              .toList();
        }

        final news = News(
          id: json['id'] ?? '',
          mainImages: mainImages.isNotEmpty
              ? mainImages
              : [
                  ImageModel(
                      url: json['sourceimage'] ?? '',
                      caption: json['figCaption'] ?? '')
                ],
          author: json['author'] ?? '',
          figCaption: json['figCaption'] ?? '',
          time: json['publishedDate'] ?? '',
          summarized: json['summarized'] ?? '',
          summarizedTitle: json['summarizedTitle'] ?? '',
          sourceimage: json['sourceimage'],
          sourcename: json['sourcename'],
          source: json['source'],
        );
        newsList.add(news);
      }
      return newsList;
    } catch (e) {
      rethrow;
    }
  }

  Future<ForYouNewsResponse> getForYouNews({
    required String lang,
    required int page,
  }) async {
    try {
      final response = await ApiManager.fetchData(
        '$url/api/user/customnews?lang=$lang&page=$page',
        useRefreshToken: true,
      );

      final data = response.data;

      Map<String, List<News>> teamNews = {};
      Map<String, List<News>> playerNews = {};
      Map<String, String> teamNames = {};
      Map<String, String> playerNames = {};
      Map<String, String> teamLogos = {};
      Map<String, String> playerImages = {};

      if (data['teams'] != null) {
        for (var entry in data['teams'].entries) {
          final teamId = entry.key;
          final teamData = entry.value;

          teamNames[teamId] = teamData['teamName'] ?? 'Unknown Team';

          // Only add valid image URLs
          if (teamData['teamLogo'] != null &&
              teamData['teamLogo'].toString().trim().isNotEmpty) {
            teamLogos[teamId] = teamData['teamLogo'];
          }

          final newsList = _convertNewsListFromJson(teamData['news']);
          teamNews[teamId] = newsList;
        }
      }

      if (data['players'] != null) {
        for (var entry in data['players'].entries) {
          final playerId = entry.key;
          final playerData = entry.value;

          playerNames[playerId] = playerData['playerName'] ?? 'Unknown Player';

          // Construct the player image URL using the API-Sports format
          playerImages[playerId] =
              'https://media.api-sports.io/football/players/$playerId.png';

          final newsList = _convertNewsListFromJson(playerData['news']);
          playerNews[playerId] = newsList;
        }
      }

      return ForYouNewsResponse(
        teamNews: teamNews,
        playerNews: playerNews,
        teamNames: teamNames,
        playerNames: playerNames,
        teamLogos: teamLogos,
        playerImages: playerImages,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<News> _convertNewsListFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) {
      List<ImageModel> mainImages = [];
      if (json['mainImages'] != null && json['mainImages'] is List) {
        mainImages = (json['mainImages'] as List)
            .map((image) => ImageModel(
                  url: image['url'] ?? '',
                  caption: image['caption'] ?? '',
                ))
            .toList();
      }

      return News(
        id: json['id'] ?? '',
        mainImages: mainImages.isNotEmpty
            ? mainImages
            : [
                ImageModel(
                    url: json['sourceimage'] ?? '',
                    caption: json['figCaption'] ?? '')
              ],
        author: json['author'] ?? '',
        figCaption: json['figCaption'] ?? '',
        time: json['publishedDate'] ?? '',
        summarized: json['summarized'] ?? '',
        summarizedTitle: json['summarizedTitle'] ?? '',
        sourceimage: json['sourceimage'],
        sourcename: json['sourcename'],
        source: json['source'],
      );
    }).toList();
  }
}

Future<Detail> getDetails(String id) async {
  try {
    final response = await http.get(Uri.parse('$url/details/$id'));

    final resData = json.decode(response.body) as List<dynamic>;
    final jsonData = resData[0];
    return Detail.fromJson(jsonData);
  } catch (e) {
    rethrow;
  }
}

// Add this class at the end of the file, after the NewsRepository class
class ForYouNewsResponse {
  final Map<String, List<News>> teamNews;
  final Map<String, List<News>> playerNews;
  final Map<String, String> teamNames;
  final Map<String, String> playerNames;
  final Map<String, String> teamLogos;
  final Map<String, String> playerImages;

  ForYouNewsResponse({
    required this.teamNews,
    required this.playerNews,
    required this.teamNames,
    required this.playerNames,
    required this.teamLogos,
    required this.playerImages,
  });
}
