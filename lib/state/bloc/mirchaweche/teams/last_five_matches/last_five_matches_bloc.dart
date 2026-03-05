import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/fixtures/last_5_matches_model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'last_five_matches_event.dart';
import 'last_five_matches_state.dart';

class LastFiveMatchesBloc
    extends Bloc<LastFiveMatchesEvent, LastFiveMatchesState> {
  LastFiveMatchesBloc() : super(LastFiveMatchesState()) {
    on<LastFiveMatchesRequested>(_handleLastFiveMatchesRequested);
  }

  final String _baseUrl = BaseUrl().url;
  Future<void> _handleLastFiveMatchesRequested(LastFiveMatchesRequested event,
      Emitter<LastFiveMatchesState> emit) async {
    emit(state.copyWith(status: fiveMatchesStatus.requestInProgress));

    try {
      final uri = Uri.parse(
          '$_baseUrl/api/teamProfile/lastFiveMatches?teamId=${event.teamId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<LastFiveMatchesByLeague> matchesByLeague = (decoded is List)
            ? decoded.map((e) => LastFiveMatchesByLeague.fromJson(e)).toList()
            : <LastFiveMatchesByLeague>[];

        emit(state.copyWith(
          status: fiveMatchesStatus.requestSuccess,
          matchesByLeague: matchesByLeague,
        ));
      } else if (response.statusCode == 404) {
        emit(state.copyWith(status: fiveMatchesStatus.notFound));
      } else {
        emit(state.copyWith(status: fiveMatchesStatus.requestFailure));
      }
    } catch (e) {
      print('Error fetching last five matches: $e');
      emit(state.copyWith(status: fiveMatchesStatus.requestFailure));
    }
  }
}
