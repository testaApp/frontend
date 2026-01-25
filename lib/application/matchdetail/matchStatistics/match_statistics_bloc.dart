import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../models/fixtures/match_statistics.dart';
import '../../../util/baseUrl.dart';
import 'match_statistics_event.dart';
import 'match_statistics_state.dart';

class MatchStatisticsBloc
    extends Bloc<MatchStatisticsEvent, MatchStatisticsState> {
  MatchStatisticsBloc() : super(MatchStatisticsState()) {
    on<MatchStatisticsEvent>((event, emit) {});
    on<MatchStatisticsRequested>(_handleMatchStatisticsRequested);
  }

  Future<void> _handleMatchStatisticsRequested(MatchStatisticsRequested event,
      Emitter<MatchStatisticsState> emit) async {
    emit(state.copyWith(status: matchesStatsStatus.requestInProgess));
    String url = BaseUrl().url;

    try {
      final response =
          await http.get(Uri.parse('$url/api/details/${event.fixtureId}'));

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          final teamsMatchStat = TeamsMatchStat.fromMap(responseData);

          emit(state.copyWith(
              teamsMatchStat: teamsMatchStat,
              status: matchesStatsStatus.requestSuccessed));
        } catch (e) {
          emit(state.copyWith(status: matchesStatsStatus.networkProblem));
        }
      } else {
        emit(state.copyWith(status: matchesStatsStatus.networkProblem));
      }
    } catch (e) {
      emit(state.copyWith(status: matchesStatsStatus.networkProblem));
    }
  }
}
