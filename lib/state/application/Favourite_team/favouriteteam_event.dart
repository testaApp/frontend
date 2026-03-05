abstract class FavouriteTeamEvent {}

class TwentyPlayersRequested extends FavouriteTeamEvent {}

class AddToFavouriteList extends FavouriteTeamEvent {
  AddToFavouriteList({required this.playerId});

  final int playerId;
}

class RemoveFromFavouriteList extends FavouriteTeamEvent {
  RemoveFromFavouriteList({required this.playerId});

  final int playerId;
}

class FavouritePlayersRequested extends FavouriteTeamEvent {}

class LoadNextPage extends FavouritePlayersRequested {}

class RequestPlayers extends FavouriteTeamEvent {}

class SearchPlayerByName extends FavouriteTeamEvent {
  SearchPlayerByName({required this.playerName});

  final String playerName;
}

class UpdateFavouriteList extends FavouriteTeamEvent {
  final List<int> newFavPlayersIds;

  UpdateFavouriteList(this.newFavPlayersIds);
}
