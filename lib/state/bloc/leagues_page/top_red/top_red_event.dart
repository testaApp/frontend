abstract class TopRedEvent {}

class TopRedRequested extends TopRedEvent {
  int leagueId;
  String? season;
  bool previous;
  TopRedRequested({required this.leagueId, this.season, this.previous = false});
}
