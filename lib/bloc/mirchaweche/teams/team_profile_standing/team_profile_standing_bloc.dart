import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../models/favourites_page/teams/standing_model.dart';
import '../../../../models/leagueNames.dart';
import '../../../../models/standings/standings.dart';
import '../../../../util/baseUrl.dart';
import 'team_profile_standing_event.dart';
import 'team_profile_standing_state.dart';

class TeamProfileStandingBloc
    extends Bloc<TeamProfileStandingEvent, TeamProfileStandingState> {
  TeamProfileStandingBloc() : super(const TeamProfileStandingState()) {
    on<TeamStandingRequested>(_handleTeamStandingRequested);
  }

  final String _baseUrl = BaseUrl().url;

  Future<void> _handleTeamStandingRequested(
    TeamStandingRequested event,
    Emitter<TeamProfileStandingState> emit,
  ) async {
    emit(state.copyWith(status: teamProfileStandingStatus.requested));

    // Backend now picks current season automatically — no season parameter needed
    final uri =
        Uri.parse('$_baseUrl/api/teamProfile/standings?teamId=${event.teamId}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);

        final List<TeamProfileStandingModel> teamProfileStandings = [];

        for (final json in results) {
          // Parse table items (nearby teams in standings)
          final List<TableItem> tableItems = (json['standings'] as List)
              .map((standing) => TableItem.Overall(
                    standing,
                    json['season']?.toString() ??
                        DateTime.now().year.toString(),
                  ))
              .toList();

          // Parse league info
          final LeagueName league = LeagueName(
            awayWon: json['standings']?[0]?['awayWon'],
            awayPlayed: json['standings']?[0]?['awayPlayed'],
            awayLoose: json['standings']?[0]?['awayLoose'],
            awayDraw: json['standings']?[0]?['awayDraw'],
            awayScored: json['standings']?[0]?['awayScored'],
            homeScored: json['standings']?[0]?['homeScored'],
            homePlayed: json['standings']?[0]?['homePlayed'],
            homeLoose: json['standings']?[0]?['homeLoose'],
            homeWon: json['standings']?[0]?['homeWon'],
            homeDraw: json['standings']?[0]?['homeDraw'],
            homepoint: json['standings']?[0]?['homePoint'],
            awaypoint: json['standings']?[0]?['awayPoint'],
            point: json['standings']?[0]?['point'],
            scored: json['standings']?[0]?['scored'],
            averagescored: json['standings']?[0]?['conceded'] ?? 1,
            homeConceded: json['standings']?[0]?['homeConceded'],
            awayConceded: json['standings']?[0]?['awayConceded'],
            amharicName: json['amharicLeagueName'] ?? '',
            englishName: json['englishLeagueName'] ?? '',
            oromoName: json['oromoLeagueName'] ?? '',
            somaliName: json['somaliLeagueName'] ?? '',
            logo: json['logo'] ?? '',
            id: json['league'],
          );

          teamProfileStandings.add(
            TeamProfileStandingModel(
              tableItems: tableItems,
              leagueName: league,
            ),
          );
        }

        emit(state.copyWith(
          status: teamProfileStandingStatus.success,
          standings: teamProfileStandings,
        ));
      } else if (response.statusCode == 404) {
        emit(state.copyWith(status: teamProfileStandingStatus.notFound));
      } else {
        emit(state.copyWith(status: teamProfileStandingStatus.networkError));
      }
    } catch (e) {
      print('Error fetching team standings: $e');
      emit(state.copyWith(status: teamProfileStandingStatus.networkError));
    }
  }
}

class FormMatchModel {
  final String result; // 'W', 'D', 'L'
  final String score; // '1 - 1'
  final int opponentId;

  FormMatchModel({
    required this.result,
    required this.score,
    required this.opponentId,
  });

  // Factory to parse from JSON
  factory FormMatchModel.fromJson(Map<String, dynamic> json) {
    return FormMatchModel(
      result: json['result'] ?? 'D',
      score: json['score'] ?? '0-0',
      opponentId: json['opponentId'] ?? 0,
    );
  }
}
