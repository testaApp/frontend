import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../models/fixtures/stat.dart';
import '../../../util/baseUrl.dart';
import 'head_to_head_event.dart';
import 'head_to_head_state.dart';

class HeadToHeadBloc extends Bloc<HeadToHeadEvent, HeadToHeadState> {
  final String baseUrl = BaseUrl().url;

  HeadToHeadBloc() : super(HeadToHeadState()) {
    // Reset the state
    on<ResetHeadToHead>((event, emit) {
      emit(HeadToHeadState());
    });

    // Fetch head-to-head matches
    on<HeadToHeadRequested>((event, emit) async {
      // 1. Start loading state
      emit(state.copyWith(
        status: h2hStatus.requestInProgress,
        matches: [],
      ));

      try {
        // 2. Build URL
        final uri = Uri.parse('$baseUrl/api/h2h/').replace(queryParameters: {
          'teamOne': event.homeTeamId.toString(),
          'teamTwo': event.awayTeamId.toString(),
          if (event.currentFixtureId != null)
            'currentFixtureId': event.currentFixtureId.toString(),
        });

        final response = await http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> responseData = jsonDecode(response.body);

          if (responseData.isEmpty) {
            emit(state.copyWith(
              status: h2hStatus.requestSuccess,
              matches: [],
            ));
            return;
          }

          List<Stat> matches = [];

          // 3. Process data.
          // Note: Backend already sorts by date: -1 (Newest First).
          // If you want Newest First in UI, DO NOT reverse here.
          // If you want Oldest First, use responseData.reversed
          for (var data in responseData) {
            if (data != null && data is Map<String, dynamic>) {
              try {
                final match = Stat.fromJson(data);

                // 4. Double-check: Client-side filter to ensure current match isn't included
                if (event.currentFixtureId != null &&
                    match.fixtureId == event.currentFixtureId) {
                  continue;
                }

                matches.add(match);
              } catch (e) {
                // This is likely why matches are missing. Check your console!
                print("H2H Parsing Error: $e");
                print("Problematic JSON object: $data");
              }
            }
          }

          emit(state.copyWith(
            status: h2hStatus.requestSuccess,
            matches: matches,
          ));
        } else {
          emit(state.copyWith(status: h2hStatus.networkProblem));
        }
      } catch (e, stackTrace) {
        emit(state.copyWith(status: h2hStatus.networkProblem));
      }
    });
  }
}
