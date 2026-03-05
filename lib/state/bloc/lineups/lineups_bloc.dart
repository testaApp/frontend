import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/fixtures/lineups.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'lineups_event.dart';
import 'lineups_state.dart';

class LineupsBloc extends Bloc<LineupsEvent, LineupsState> {
  LineupsBloc() : super(const LineupsState()) {
    on<LineupsRequested>(_handleLineupRequested);
  }

  Future<void> _handleLineupRequested(
      LineupsRequested event, Emitter<LineupsState> emit) async {
    // Start loading
    emit(state.copyWith(
      lineupsStatus: LineupStatus.requestInProgress,
      isFallback: false,
      fallbackMessage: null,
    ));

    final String baseUrl = BaseUrl().url;

    try {
      // === Step 1: Try to get the official current lineup ===
      final response = await http.get(
        Uri.parse('$baseUrl/api/lineup/${event.fixtureId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        if (decoded.isNotEmpty &&
            decoded[0]['response'] != null &&
            (decoded[0]['response'] as List).isNotEmpty) {
          final List<dynamic> result = decoded[0]['response'];
          final List<Lineup> lineups =
              result.map((e) => Lineup.fromJson(e)).toList();

          emit(state.copyWith(
            lineups: lineups,
            lineupsStatus: LineupStatus.requestSuccess,
            isFallback: false,
            fallbackMessage: null,
          ));
          return; // Success with official lineup
        }
      }

      // === Step 2: Official lineup not available → try fallback ===
      final fallbackResponse = await http.get(
        Uri.parse(
          '$baseUrl/api/lineup/${event.fixtureId}/fallback?'
          'teamOne=${event.homeTeamId}&teamTwo=${event.awayTeamId}',
        ),
      );

      if (fallbackResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(fallbackResponse.body);

        if (data['data'] != null &&
            (data['data'] as List).isNotEmpty &&
            data['data'][0]['response'] != null) {
          final List<dynamic> result = data['data'][0]['response'];
          final List<Lineup> lineups =
              result.map((e) => Lineup.fromJson(e)).toList();

          emit(state.copyWith(
            lineups: lineups,
            lineupsStatus: LineupStatus.requestSuccess,
            isFallback: true,
            fallbackMessage: data['message'] ??
                "Official lineup not announced yet – showing previous match lineup",
          ));
          return; // Success with fallback
        }
      }

      // === Step 3: Nothing found at all ===
      emit(state.copyWith(
        lineups: [],
        lineupsStatus: LineupStatus.requestSuccess,
        isFallback: true,
        fallbackMessage: "Lineup not available at this time",
      ));
    } catch (e) {
      // Network error, timeout, parsing error, etc.
      emit(state.copyWith(
        lineups: [],
        lineupsStatus: LineupStatus.requestFailure,
        isFallback: false,
        fallbackMessage: null,
      ));
    }
  }
}
