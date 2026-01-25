import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/failures.dart';
import '../models/program_card/PodcastModel.dart';
import '../util/baseUrl.dart';

class PodcastsApiDataSource {
  final url = BaseUrl().url;
  Future<Either<GeneralFailure, List<PodcastModel>>> getAllPodcasts() async {
    final response = await http.get(Uri.parse('$url/api/podcasts'));

    if (response.statusCode == 200) {
      try {
        List jsonData = json.decode(response.body) as List<dynamic>;

        List<PodcastModel> podcastList = jsonData.map((data) {
          return PodcastModel.fromJson(data);
        }).toList();
        return Right(podcastList);
      } catch (e) {
        rethrow;
      }
    } else {
      return Left(NetworkFailure(message: 'network failure'));
    }
  }
}
