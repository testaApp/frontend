import 'package:blogapp/models/matchdetail/fixureevent.model.dart';

enum EventStatus {
  requestInProgress,
  requestFailed,
  requestSuccess,
  unknown,
  start
}

class FixtureEventState {
  final List<FixureEventModel> events;
  final EventStatus status;

  FixtureEventState({this.events = const [], this.status = EventStatus.start});

  FixtureEventState copyWith(
          {List<FixureEventModel>? events, EventStatus? status}) =>
      FixtureEventState(
          events: events ?? this.events, status: status ?? this.status);
}
