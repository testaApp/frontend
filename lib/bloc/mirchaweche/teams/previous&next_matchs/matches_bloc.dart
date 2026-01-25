import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../models/Matches_model.dart';
import '../../../../util/baseUrl.dart';
import 'match_page_state.dart';
import 'matches_page_event.dart';

class MatchesPageBloc extends Bloc<MatchesPageEvent, MatchPageState> {
  MatchesPageBloc() : super(MatchPageState()) {
    on<MatchesRequested>(_fixturesRequested);
    on<TeamPreviousMatchesRequested>(_onTeamPreviousRequested);
    on<TeamNextMatchesRequested>(_onTeamNextRequested);
  }

  // ────────────────────────────────────────────────────────────────
  // 1. ALL PREVIOUS MATCHES (no team filter)
  // ────────────────────────────────────────────────────────────────
  Future<void> _fixturesRequested(
    MatchesRequested event,
    Emitter<MatchPageState> emit,
  ) async {
    emit(state.copyWith(status: matchpageStatus.requested));

    final url = '${BaseUrl().url}/api/previousmatches';

    print('🌐 Fetching all previous matches: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matches = data.map((e) => Matches_model.fromJson(e)).toList();

        emit(state.copyWith(
          status: matchpageStatus.requestSuccess,
          matchs: matches,
        ));
      } else if (response.statusCode == 500) {
        emit(state.copyWith(status: matchpageStatus.serverError));
      } else {
        emit(state.copyWith(status: matchpageStatus.networkFailure));
      }
    } catch (e) {
      print('❌ Error fetching all previous: $e');
      emit(state.copyWith(status: matchpageStatus.networkFailure));
    }
  }

  // ────────────────────────────────────────────────────────────────
  // 2. PREVIOUS MATCHES FOR SPECIFIC TEAM
  // ────────────────────────────────────────────────────────────────
  Future<void> _onTeamPreviousRequested(
    TeamPreviousMatchesRequested event,
    Emitter<MatchPageState> emit,
  ) async {
    emit(state.copyWith(previousMatchesStatus: matchpageStatus.requested));

    var url = '${BaseUrl().url}/api/previousmatches?teamId=${event.teamId}';

    print('🌐 Fetching previous matches for team ${event.teamId}: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matches = data.map((e) => Matches_model.fromJson(e)).toList();

        print('✅ Loaded ${matches.length} previous matches for team');

        emit(state.copyWith(
          previousMatchesStatus: matchpageStatus.requestSuccess,
          previousMatches: matches,
        ));
      } else if (response.statusCode == 500) {
        emit(
            state.copyWith(previousMatchesStatus: matchpageStatus.serverError));
      } else {
        emit(state.copyWith(
            previousMatchesStatus: matchpageStatus.networkFailure));
      }
    } catch (e) {
      print('❌ Error fetching team previous: $e');
      emit(state.copyWith(
          previousMatchesStatus: matchpageStatus.networkFailure));
    }
  }

  // ────────────────────────────────────────────────────────────────
  // 3. NEXT MATCHES / FIXTURES FOR SPECIFIC TEAM
  // ────────────────────────────────────────────────────────────────
  Future<void> _onTeamNextRequested(
    TeamNextMatchesRequested event,
    Emitter<MatchPageState> emit,
  ) async {
    emit(state.copyWith(nextMatchesStatus: matchpageStatus.requested));

    var url = '${BaseUrl().url}/api/nextmatches?teamId=${event.teamId}';

    print('🌐 Fetching next matches for team ${event.teamId}: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matches = data.map((e) => Matches_model.fromJson(e)).toList();

        print('✅ Loaded ${matches.length} upcoming matches for team');

        emit(state.copyWith(
          nextMatchesStatus: matchpageStatus.requestSuccess,
          nextMatches: matches,
        ));
      } else if (response.statusCode == 500) {
        emit(state.copyWith(nextMatchesStatus: matchpageStatus.serverError));
      } else {
        emit(state.copyWith(nextMatchesStatus: matchpageStatus.networkFailure));
      }
    } catch (e) {
      print('❌ Error fetching team next matches: $e');
      emit(state.copyWith(nextMatchesStatus: matchpageStatus.networkFailure));
    }
  }
}
