import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/favourites_page/teams/teamstas/teamProfileStat.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'team_profile_statistics_event.dart';
import 'team_profile_statistics_state.dart';

class TeamProfileStatisticsBloc
    extends Bloc<TeamProfileStatisticsEvent, TeamProfileStatisticsState> {
  TeamProfileStatisticsBloc() : super(TeamProfileStatisticsState()) {
    on<TeamProfileStatisticsRequested>(_handleProfileStatRequested);
  }

  Future<void> _handleProfileStatRequested(
    TeamProfileStatisticsRequested event,
    Emitter<TeamProfileStatisticsState> emit,
  ) async {
    emit(state.copyWith(status: teamProfileStatus.requested));

    final String baseUrl = BaseUrl().url;

    // Backend automatically uses current season — no season parameter sent
    final Uri uri =
        Uri.parse('$baseUrl/api/teamProfile/statistics?id=${event.teamId}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic result = jsonDecode(response.body);

        // Handle both single object and array responses for safety
        final List<dynamic> data = result is List ? result : [result];

        final List<TeamStats> teamStats = data
            .map((json) => TeamStats.fromJson(json as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          status: teamProfileStatus.success,
          teamStats: teamStats,
        ));
      } else if (response.statusCode == 404) {
        emit(state.copyWith(status: teamProfileStatus.notFound));
      } else {
        emit(state.copyWith(status: teamProfileStatus.networkFailed));
      }
    } catch (e) {
      print('Error in TeamProfileStatisticsBloc: $e');
      emit(state.copyWith(status: teamProfileStatus.failure));
    }
  }
}
