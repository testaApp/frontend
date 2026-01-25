import '../../domain/player/playerModel.dart';

enum FavPlayersStatus {
  initial,
  requestInProgress,
  requestSuccess,
  requestFailed,
  unknown,
}

class FavouriteplayerState {
  final FavPlayersStatus playersStatus;
  final List<PlayerProfile> players;
  final int pageNumber;
  final FavPlayersStatus nextPageStatus;
  final FavPlayersStatus searchStatus;
  final List<PlayerProfile> searchResults;
  final Set<int> favoritePlayerIds;
  final String searchQuery;

  FavouriteplayerState({
    this.playersStatus = FavPlayersStatus.initial,
    this.players = const [],
    this.pageNumber = 0, // CORRECTED: Start page number at 0 for API skip logic
    this.nextPageStatus = FavPlayersStatus.initial,
    this.searchStatus = FavPlayersStatus.initial,
    this.searchResults = const [],
    this.favoritePlayerIds = const {},
    this.searchQuery = '',
  });

  FavouriteplayerState copyWith({
    FavPlayersStatus? playersStatus,
    List<PlayerProfile>? players,
    int? pageNumber,
    FavPlayersStatus? nextPageStatus,
    FavPlayersStatus? searchStatus,
    List<PlayerProfile>? searchResults,
    Set<int>? favoritePlayerIds,
    String? searchQuery,
  }) {
    return FavouriteplayerState(
      playersStatus: playersStatus ?? this.playersStatus,
      players: players ?? this.players,
      pageNumber: pageNumber ?? this.pageNumber,
      nextPageStatus: nextPageStatus ?? this.nextPageStatus,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      favoritePlayerIds: favoritePlayerIds ?? this.favoritePlayerIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
