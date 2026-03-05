abstract class FixtureEventEvent {}

class FixtureEventsRequested extends FixtureEventEvent {
  FixtureEventsRequested({required this.fixtureId});
  final int? fixtureId;
}
