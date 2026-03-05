import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:blogapp/main.dart';
import 'package:blogapp/models/details.dart';
import 'package:blogapp/models/news.dart';
import 'package:blogapp/core/network/api_manager.dart';
import 'package:blogapp/core/network/baseUrl.dart';

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
                        caption: json['figCaption'] ?? '',
                      )
                    ],
              publishedDate: json['publishedDate'] ?? '',
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
                    caption: json['figCaption'] ?? '',
                  )
                ],
          publishedDate: json['publishedDate'] ?? '',
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
                        caption: json['figCaption'] ?? '',
                      )
                    ],
              publishedDate: json['publishedDate'] ?? '',
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
    required String leagueName,
  }) async {
    final response = await ApiManager.fetchData(
      '$url/api/leagues/news?leagueName=$leagueName&lang=$lang&page=$page',
      useRefreshToken: true,
    );
    try {
      final jsonData = response.data;
      List<News> newsList = [];

      for (var i = 0; i < jsonData.length; i++) {
        final json = jsonData[i];

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
                    caption: json['figCaption'] ?? '',
                  )
                ],
          publishedDate: json['publishedDate'] ?? '',
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

      List<News> items = [];
      Map<String, List<News>> teamNews = {};
      Map<String, List<News>> playerNews = {};
      Map<String, String> teamNames = {};
      Map<String, String> playerNames = {};
      Map<String, String> teamLogos = {};
      Map<String, String> playerImages = {};

      if (data['items'] != null && data['items'] is List) {
        items = _convertNewsListFromJson(data['items']);
      }

      if (data['teams'] != null) {
        for (var entry in data['teams'].entries) {
          final teamId = entry.key;
          final teamData = entry.value;

          teamNames[teamId] = teamData['teamName'] ?? 'Unknown Team';

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

          playerImages[playerId] =
              'https://media.api-sports.io/football/players/$playerId.png';

          final newsList = _convertNewsListFromJson(playerData['news']);
          playerNews[playerId] = newsList;
        }
      }

      if (items.isEmpty) {
        items = _mergeAndSortNews([
          ...teamNews.values.expand((list) => list),
          ...playerNews.values.expand((list) => list),
        ]);
      } else {
        items = _mergeAndSortNews(items);
      }

      return ForYouNewsResponse(
        items: items,
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

  List<News> _mergeAndSortNews(Iterable<News> items) {
    final Map<String, News> deduped = {};
    for (final news in items) {
      if (news.id.isNotEmpty) {
        deduped[news.id] = news;
      }
    }

    final merged = deduped.values.toList();
    merged.sort((a, b) {
      final dateA =
          a.publishedDate != null ? DateTime.tryParse(a.publishedDate!) : null;
      final dateB =
          b.publishedDate != null ? DateTime.tryParse(b.publishedDate!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return merged;
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
                  caption: json['figCaption'] ?? '',
                )
              ],
        publishedDate: json['publishedDate'] ?? '',
        summarizedTitle: json['summarizedTitle'] ?? '',
        sourceimage: json['sourceimage'],
        sourcename: json['sourcename'],
        source: json['source'],
      );
    }).toList();
  }


  //__________________________ to get team news by team name __________________________
  Future<List<News>> getTeamNews({
  required int page,
  required String lang,
  required String teamName,
}) async {
  final response = await ApiManager.fetchData(
    '$url/teamnews?name=$teamName&lang=$lang&page=$page',
    useRefreshToken: true,
  );

  return _convertNewsListFromJson(response.data);
}

//__________________________ to get player news by player name __________________________
Future<List<News>> getPlayerNews({
  required int page,
  required String lang,
  required String playerName,
}) async {
  final response = await ApiManager.fetchData(
    '$url/playernews?name=$playerName&lang=$lang&page=$page',
    useRefreshToken: true,
  );

  return _convertNewsListFromJson(response.data);
}

//__________________________ to get any news details by id __________________________ 
  Future<Detail> getDetails(String id, String lang) async {
    try {
      final response = await ApiManager.fetchData(
        '$url/details/$id?lang=$lang',
        useRefreshToken: true,
      );

      final jsonData = response.data;
      return Detail.fromJson(jsonData);
    } catch (e) {
      rethrow;
    }
  }
}

class ForYouNewsResponse {
  final List<News> items;
  final Map<String, List<News>> teamNews;
  final Map<String, List<News>> playerNews;
  final Map<String, String> teamNames;
  final Map<String, String> playerNames;
  final Map<String, String> teamLogos;
  final Map<String, String> playerImages;

  ForYouNewsResponse({
    required this.items,
    required this.teamNews,
    required this.playerNews,
    required this.teamNames,
    required this.playerNames,
    required this.teamLogos,
    required this.playerImages,
  });
}
