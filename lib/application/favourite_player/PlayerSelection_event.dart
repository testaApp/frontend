// player_selection_event.dart
abstract class PlayerSelectionEvent {}

class FetchPlayersRequested extends PlayerSelectionEvent {}

class LoadMorePlayersRequested extends PlayerSelectionEvent {}

class FetchPopularPlayersRequested extends PlayerSelectionEvent {}

class SearchPlayerByNameRequested extends PlayerSelectionEvent {
  final String playerName;
  SearchPlayerByNameRequested({required this.playerName});
}

class TogglePlayerSelectionRequested extends PlayerSelectionEvent {
  final int playerId;
  TogglePlayerSelectionRequested({required this.playerId});
}

// ADD THESE TWO CLASSES:
class RemovePlayerSelectionRequested extends PlayerSelectionEvent {
  final int playerId;
  RemovePlayerSelectionRequested({required this.playerId});
}

class ClearAllSelectionsRequested extends PlayerSelectionEvent {}
