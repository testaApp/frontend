// Knockout_bloc.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../util/baseUrl.dart';
import 'Knock_out_event.dart';
import 'Knock_out_state.dart';

class KnockoutBloc extends Bloc<KnockoutEvent, KnockoutState> {
  String url = BaseUrl().url;

  KnockoutBloc() : super(const KnockoutState()) {
    on<KnockoutRequested>((event, emit) async {
      emit(state.copyWith(status: KnockoutStatus.requestInProgress));

      try {
        final response = await http.get(
          Uri.parse(
              '$url/Knockoutdata?leagueId=${event.leagueId}&season=${event.season}'),
          headers: <String, String>{'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          emit(state.copyWith(
            status: KnockoutStatus.requestSuccess,
            championsLeague: responseData,
          ));
        } else {
          emit(state.copyWith(
            status: KnockoutStatus.requestFailure,
            error: 'Failed to load data',
          ));
        }
      } catch (error) {
        emit(state.copyWith(
          status: KnockoutStatus.requestFailure,
          error: error.toString(),
        ));
      }
    });
  }
}
