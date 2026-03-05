// player_selection_state.dart

import 'package:blogapp/domain/player/Players_for_selection_model.dart';

enum PlayerSelectionStatus {
  initial,
  loading,
  success,
  failure,
}

class PlayerSelectionState {
  final PlayerSelectionStatus status;
  final List<PlayerSelectionModel> players;
  final List<PlayerSelectionModel> popularPlayers; // <--- ADD THIS
  final List<PlayerSelectionModel> favouritePlayers;
  final List<PlayerSelectionModel> searchResults;
  final List<int> selectedPlayerIds;

  // Pagination fields
  final int pageNumber;
  final bool isLoadingMore; // True when fetching next page
  final bool hasReachedMax; // True when no more pages to load

  final String errorMessage;

  // NEW: Track the last search query so we can restore it in the UI
  final String lastSearchQuery;

  const PlayerSelectionState({
    this.status = PlayerSelectionStatus.initial,
    this.players = const [],
    this.searchResults = const [],
    this.popularPlayers = const [], // <--- ADD THIS
    this.favouritePlayers = const [],
    this.selectedPlayerIds = const [],
    this.pageNumber = 1,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.lastSearchQuery = '', // Default to empty string
  });

  PlayerSelectionState copyWith({
    PlayerSelectionStatus? status,
    List<PlayerSelectionModel>? players,
    List<PlayerSelectionModel>? popularPlayers, // <--- ADD THIS
    List<PlayerSelectionModel>? favouritePlayers,
    List<PlayerSelectionModel>? searchResults,
    List<int>? selectedPlayerIds,
    int? pageNumber,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    String? lastSearchQuery,
  }) {
    return PlayerSelectionState(
      status: status ?? this.status,
      players: players ?? this.players,
      popularPlayers: popularPlayers ?? this.popularPlayers, // <--- ADD THIS
      favouritePlayers: favouritePlayers ?? this.favouritePlayers,
      searchResults: searchResults ?? this.searchResults,
      selectedPlayerIds: selectedPlayerIds ?? this.selectedPlayerIds,
      pageNumber: pageNumber ?? this.pageNumber,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerSelectionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          players == other.players &&
          popularPlayers == other.popularPlayers &&
          favouritePlayers == other.favouritePlayers &&
          searchResults == other.searchResults &&
          selectedPlayerIds == other.selectedPlayerIds &&
          pageNumber == other.pageNumber &&
          isLoadingMore == other.isLoadingMore &&
          hasReachedMax == other.hasReachedMax &&
          errorMessage == other.errorMessage &&
          lastSearchQuery == other.lastSearchQuery; // Include in equality

  @override
  int get hashCode =>
      status.hashCode ^
      players.hashCode ^
      popularPlayers.hashCode ^ // <--- ADD THIS
      favouritePlayers.hashCode ^
      searchResults.hashCode ^
      selectedPlayerIds.hashCode ^
      pageNumber.hashCode ^
      isLoadingMore.hashCode ^
      hasReachedMax.hashCode ^
      errorMessage.hashCode ^
      lastSearchQuery.hashCode; // Include in hashCode
}
