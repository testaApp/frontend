abstract class FavouriteplayerEvent {
  // Good practice to make the base class constructor const

  const FavouriteplayerEvent();
}

class AddToFavouriteList extends FavouriteplayerEvent {
  // Constructors with non-const arguments cannot be const

  AddToFavouriteList({required this.playerId});

  final int playerId;
}

class RemoveFromFavouriteList extends FavouriteplayerEvent {
  // Constructors with non-const arguments cannot be const

  RemoveFromFavouriteList({required this.playerId});

  final int playerId;
}

class ClearSearch extends FavouriteplayerEvent {
  // FIX: Added const constructor

  const ClearSearch();
}

class LoadNextPage extends FavouriteplayerEvent {
  // FIX: Added const constructor

  const LoadNextPage();
}

class RequestPlayers extends FavouriteplayerEvent {
  // FIX: Added const constructor

  const RequestPlayers();
}

class SearchPlayerByName extends FavouriteplayerEvent {
  // Constructors with non-const arguments cannot be const

  SearchPlayerByName({required this.playerName});

  final String playerName;
}

class UpdateFavouriteList extends FavouriteplayerEvent {
  final List<int> newFavPlayersIds;

  // Constructors with non-const arguments cannot be const

  UpdateFavouriteList(this.newFavPlayersIds);
}
