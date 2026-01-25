abstract class TopScorersEvent {}

class TopScorersRequested extends TopScorersEvent {
  int leagueId;
  int? season;
  bool previous;
  TopScorersRequested(
      {required this.leagueId, String? season, this.previous = false})
      : season = season != null ? int.tryParse(season) : null;
}
