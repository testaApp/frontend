abstract class AvailableSeasonsEvent {}

class AvailableSeasonsRequested extends AvailableSeasonsEvent {
  int leagueId;
  AvailableSeasonsRequested({required this.leagueId});
}

class ChangeCurrentSeason extends AvailableSeasonsEvent {
  String season;
  ChangeCurrentSeason({required this.season});
}
