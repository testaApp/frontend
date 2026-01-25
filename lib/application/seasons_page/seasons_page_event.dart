abstract class SeasonsPageEvent {}

class LeagueWinnersRequested extends SeasonsPageEvent {
  final int leagueId;

  LeagueWinnersRequested(this.leagueId);
}

class ClearSeasonsState extends SeasonsPageEvent {}
