import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../models/leagues_page/top_scorer.model.dart';
import '../../../util/baseUrl.dart';
import './top_yellow_state.dart';
import './top_yellow_event.dart';

class TopYellowCardsBloc
    extends Bloc<TopYellowCardsEvent, TopYellowCardsState> {
  String url = BaseUrl().url;
  TopYellowCardsBloc() : super(TopYellowCardsState()) {
    on<TopYellowCardsRequested>((event, emit) async {
      emit(state.copyWith(status: CardScorerStatus.requestInProgress));

      try {
        final response = await http.get(
            Uri.parse(
                '$url/api/leagues/topyellowcards/?leagueId=${event.leagueId}&season=${event.season}'),
            headers: <String, String>{'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData is List && responseData.isNotEmpty) {
            List<TopScorerModel> topYellowCards = TopScorerModel.fromJsonList(
                responseData[0], 'scorers',
                valueKey: 'yellow');

            // Sort by yellow cards in descending order
            topYellowCards
                .sort((a, b) => (b.yellow ?? 0).compareTo(a.yellow ?? 0));

            event.previous
                ? emit(state.copyWith(
                    status: CardScorerStatus.requestSuccessed,
                    previousTopYellowCards: topYellowCards,
                  ))
                : emit(state.copyWith(
                    status: CardScorerStatus.requestSuccessed,
                    topYellowCards: topYellowCards,
                  ));
          } else {
            emit(state.copyWith(
              status: CardScorerStatus.requestSuccessed,
              topYellowCards: [],
              previousTopYellowCards: [],
            ));
          }
        } else if (response.statusCode == 503) {
          emit(state.copyWith(status: CardScorerStatus.requestFailure));
        } else {
          emit(state.copyWith(status: CardScorerStatus.unknown));
        }
      } catch (e) {
        print('Error in TopYellowCardsBloc: $e');
        emit(state.copyWith(status: CardScorerStatus.requestFailure));
      }
    });
  }
}
