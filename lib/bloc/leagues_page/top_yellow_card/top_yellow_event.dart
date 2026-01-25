abstract class TopYellowCardsEvent {}

class TopYellowCardsRequested extends TopYellowCardsEvent {
  final int leagueId;
  final int season;
  final bool previous;

  TopYellowCardsRequested({
    required this.leagueId,
    required this.season,
    this.previous = false,
  });
}
