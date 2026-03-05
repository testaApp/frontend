import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/leagues_page/top_scorer.model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'top_assist_event.dart';
import 'top_assist_state.dart';

class TopAssistorsBloc extends Bloc<TopAssistEvent, TopAssistState> {
  String url = BaseUrl().url;
  TopAssistorsBloc() : super(TopAssistState()) {
    on<TopAssistRequested>((event, emit) async {
      developer.log('TopAssistRequested event received',
          name: 'TopAssistorsBloc',
          error: 'leagueId: ${event.leagueId}, season: ${event.season}');

      emit(state.copyWith(status: AssistStatus.requestInProgress));

      try {
        final requestUrl =
            '$url/api/leagues/topassists/?leagueId=${event.leagueId}&season=${event.season}';
        developer.log('Making request to: $requestUrl',
            name: 'TopAssistorsBloc');

        final response = await http.get(Uri.parse(requestUrl),
            headers: <String, String>{'Content-Type': 'application/json'});

        developer.log('Response status code: ${response.statusCode}',
            name: 'TopAssistorsBloc');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          developer.log('Response data: ${response.body}',
              name: 'TopAssistorsBloc');

          if (responseData is List && responseData.isNotEmpty) {
            List<TopScorerModel> topAssistors = TopScorerModel.fromJsonList(
                responseData[0], 'scorers',
                valueKey: 'assists');

            developer.log('Parsed ${topAssistors.length} top assistors',
                name: 'TopAssistorsBloc');

            // Sort by assists in descending order
            topAssistors
                .sort((a, b) => (b.assists ?? 0).compareTo(a.assists ?? 0));

            event.previous
                ? emit(state.copyWith(
                    status: AssistStatus.requestSuccessed,
                    previousTopAssistors: topAssistors,
                  ))
                : emit(state.copyWith(
                    status: AssistStatus.requestSuccessed,
                    topAssistors: topAssistors,
                  ));
          } else {
            developer.log('Response data is empty or invalid',
                name: 'TopAssistorsBloc');
            emit(state.copyWith(
              status: AssistStatus.requestSuccessed,
              topAssistors: [],
              previousTopAssistors: [],
            ));
          }
        } else if (response.statusCode == 503) {
          developer.log('Service unavailable (503)', name: 'TopAssistorsBloc');
          emit(state.copyWith(status: AssistStatus.requestFailure));
        } else {
          developer.log('Unknown error status code: ${response.statusCode}',
              name: 'TopAssistorsBloc');
          emit(state.copyWith(status: AssistStatus.unknown));
        }
      } catch (e, stackTrace) {
        developer.log('Error in TopAssistorsBloc',
            name: 'TopAssistorsBloc',
            error: e.toString(),
            stackTrace: stackTrace);
        emit(state.copyWith(status: AssistStatus.requestFailure));
      }
    });
  }
}
