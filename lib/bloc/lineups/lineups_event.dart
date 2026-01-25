abstract class LineupsEvent {}

class LineupsRequested extends LineupsEvent {
  LineupsRequested({
    required this.fixtureId,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int fixtureId;
  final int homeTeamId;
  final int awayTeamId;

  @override
  List<Object> get props => [fixtureId, homeTeamId, awayTeamId];
}
