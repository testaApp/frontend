import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/failures.dart';
import '../models/program_card/PodcastModel.dart';
import '../util/baseUrl.dart';

class PodcastsApiDataSource {
  final url = BaseUrl().url;
  Future<Either<GeneralFailure, PodcastPageResult>> getPodcastsPage({
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$url/api/podcasts?page=$page&limit=$limit&include=descriptions'),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List<dynamic> jsonData = decoded['data'] as List<dynamic>;
          final List<PodcastModel> podcastList = jsonData
              .map((data) => PodcastModel.fromJson(
                  Map<String, dynamic>.from(data as Map)))
              .toList();

          final pagination = decoded['pagination'] as Map<String, dynamic>? ?? {};
          final hasNext = pagination['hasNextPage'] == true;
          final totalPages = pagination['totalPages'] is int
              ? pagination['totalPages'] as int
              : 1;

          return Right(PodcastPageResult(
            items: podcastList,
            page: page,
            hasNext: hasNext,
            totalPages: totalPages,
            limit: limit,
          ));
        }

        if (decoded is List) {
          final List<PodcastModel> podcastList = decoded
              .map((data) => PodcastModel.fromJson(
                  Map<String, dynamic>.from(data as Map)))
              .toList();
          return Right(PodcastPageResult(
            items: podcastList,
            page: 1,
            hasNext: false,
            totalPages: 1,
            limit: podcastList.length,
          ));
        }

        return Left(NetworkFailure(message: 'invalid response'));
      } catch (e) {
        rethrow;
      }
    } else {
      return Left(NetworkFailure(message: 'network failure'));
    }
  }
}

class PodcastPageResult {
  final List<PodcastModel> items;
  final int page;
  final bool hasNext;
  final int totalPages;
  final int limit;

  const PodcastPageResult({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.totalPages,
    required this.limit,
  });
}
