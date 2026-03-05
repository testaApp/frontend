import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/leagues_page/top_scorer.model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'top_scorers_event.dart';
import 'top_scorers_state.dart';

class TopScorersBloc extends Bloc<TopScorersEvent, TopScorersState> {
  String url = BaseUrl().url;
  TopScorersBloc() : super(TopScorersState()) {
    on<TopScorersRequested>((event, emit) async {
      emit(state.copyWith(status: ScorerStatus.requestInProgress));

      try {
        final response = await http.get(
            Uri.parse(
                '$url/api/leagues/topscorers/?leagueId=${event.leagueId}&season=${event.season}'),
            headers: <String, String>{'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData is List && responseData.isNotEmpty) {
            List<TopScorerModel> topScorers = TopScorerModel.fromJsonList(
                responseData[0], 'scorers',
                valueKey: 'goals');

            emit(state.copyWith(
              status: ScorerStatus.requestSuccessed,
              topScorers: topScorers,
            ));
          } else {
            emit(state.copyWith(
              status: ScorerStatus.requestSuccessed,
              topScorers: [],
            ));
          }
        } else if (response.statusCode == 503) {
          emit(state.copyWith(status: ScorerStatus.requestFailure));
        } else {
          emit(state.copyWith(status: ScorerStatus.unknown));
        }
      } catch (e) {
        print('Error in TopScorersBloc: $e');
        emit(state.copyWith(status: ScorerStatus.requestFailure));
      }
    });
  }
}
