import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/models/matchdetail/fixureevent.model.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'fixtureevent_event.dart';
import 'fixtureevent_state.dart';

class FixtureeventBloc extends Bloc<FixtureEventEvent, FixtureEventState> {
  FixtureeventBloc() : super(FixtureEventState()) {
    on<FixtureEventEvent>((event, emit) {});
    on<FixtureEventsRequested>(_handleFixtureEventRequested);
  }

  Future<void> _handleFixtureEventRequested(
    FixtureEventsRequested event,
    Emitter<FixtureEventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.requestInProgress, events: []));

    final url = BaseUrl().url;

    final response =
        await http.get(Uri.parse('$url/api/event/${event.fixtureId}'));

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        final body = jsonDecode(response.body);

        final List<dynamic> result = body['response'] ?? [];

        for (var i = 0; i < result.length; i++) {
          // Log player JSON

          // Log assist JSON (if exists)
        }

        final events = result.map((e) => FixureEventModel.fromJson(e)).toList();

        emit(
          state.copyWith(
            events: events,
            status: EventStatus.requestSuccess,
          ),
        );
      } catch (e, stack) {
        emit(
          state.copyWith(
            events: [],
            status: EventStatus.requestSuccess,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          events: [],
          status: EventStatus.requestSuccess,
        ),
      );
    }
  }
}
