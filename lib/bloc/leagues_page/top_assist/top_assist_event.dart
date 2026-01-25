abstract class TopAssistEvent {}

class TopAssistRequested extends TopAssistEvent {
  int leagueId;
  int? season;
  bool previous;
  TopAssistRequested(
      {required this.leagueId, String? season, this.previous = false})
      : season = season != null ? int.tryParse(season) : null;
}
