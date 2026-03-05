abstract class MatchEvent {
  const MatchEvent();
}

class GetMatchById extends MatchEvent {
  final int fixtureId;
  const GetMatchById({required this.fixtureId});
}

class RefreshMatch extends MatchEvent {
  final int? fixtureId;
  const RefreshMatch({required this.fixtureId});
}
