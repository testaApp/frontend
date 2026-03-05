import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/leagues_page/top_scorer.model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import './top_red_event.dart';
import './top_red_state.dart';

class TopRedCardsBloc extends Bloc<TopRedEvent, TopRedState> {
  String url = BaseUrl().url;
  TopRedCardsBloc() : super(TopRedState()) {
    on<TopRedRequested>((event, emit) async {
      emit(state.copyWith(status: RedStatus.requestInProgress));

      try {
        final response = await http.get(
            Uri.parse(
                '$url/api/leagues/topredcards/?leagueId=${event.leagueId}&season=${event.season}'),
            headers: <String, String>{
              'Content-Type': 'application/json'
            }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Connection timed out');
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData is List && responseData.isNotEmpty) {
            List<TopScorerModel> topRedCards = TopScorerModel.fromJsonList(
                responseData[0], 'scorers',
                valueKey: 'red');

            // Sort by red cards in descending order
            topRedCards.sort((a, b) => (b.red ?? 0).compareTo(a.red ?? 0));

            event.previous
                ? emit(state.copyWith(
                    status: RedStatus.requestSuccessed,
                    previousTopReds: topRedCards,
                  ))
                : emit(state.copyWith(
                    status: RedStatus.requestSuccessed,
                    topRed: topRedCards,
                  ));
          } else {
            emit(state.copyWith(
              status: RedStatus.requestSuccessed,
              topRed: [],
              previousTopReds: [],
            ));
          }
        } else if (response.statusCode == 503) {
          emit(state.copyWith(status: RedStatus.requestFailure));
        } else {
          emit(state.copyWith(status: RedStatus.unknown));
        }
      } catch (e) {
        print('Error in TopRedCardsBloc: $e');
        emit(state.copyWith(
          status: RedStatus.requestFailure,
          topRed: [], // Clear the list on error
        ));
      }
    });
  }
}
