abstract class HeadToHeadEvent {}

class HeadToHeadRequested extends HeadToHeadEvent {
  final int homeTeamId;
  final int awayTeamId;
  final int? currentFixtureId;

  HeadToHeadRequested(
      {required this.homeTeamId,
      required this.awayTeamId,
      this.currentFixtureId});
}

class ResetHeadToHead extends HeadToHeadEvent {}
