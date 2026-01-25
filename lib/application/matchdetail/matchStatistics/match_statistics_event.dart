abstract class MatchStatisticsEvent {}

class MatchStatisticsRequested extends MatchStatisticsEvent {
  int? fixtureId;
  MatchStatisticsRequested({required this.fixtureId});
}
