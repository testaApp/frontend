abstract class FavouriteLeagueEvent {}

class AddToFavouriteList extends FavouriteLeagueEvent {
  AddToFavouriteList({required this.leagueId});

  final int leagueId;
}

class RemoveFromFavouriteList extends FavouriteLeagueEvent {
  RemoveFromFavouriteList({required this.leagueId});

  final int leagueId;
}

class FavouriteLeaguesRequested extends FavouriteLeagueEvent {}
