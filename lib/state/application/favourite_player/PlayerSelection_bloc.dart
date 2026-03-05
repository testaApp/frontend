import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/baseUrl.dart';
import '../../../domain/player/Players_for_selection_model.dart';
import '../../../features/auth/services/firebase_auth_helpers.dart';
import '../../../services/following_storage_service.dart';
import 'PlayerSelection_event.dart';
import 'PlayerSelection_state.dart';

class PlayerSelectionBloc
    extends Bloc<PlayerSelectionEvent, PlayerSelectionState> {
  final FollowingStorageService _storageService;
  static const int _pageSize = 100;
  int _searchRequestToken = 0;

  PlayerSelectionBloc({
    required FollowingStorageService storageService,
  })  : _storageService = storageService,
        super(const PlayerSelectionState()) {
    on<FetchPlayersRequested>(_handleFetchPlayers);
    on<LoadMorePlayersRequested>(_handleLoadMorePlayers);
    on<FetchPopularPlayersRequested>(_handleFetchPopularPlayers);
    on<SearchPlayerByNameRequested>(_handleSearchPlayers);
    on<FetchPlayersByIdsRequested>(_handleFetchPlayersByIds);
    on<TogglePlayerSelectionRequested>(_handleToggleSelection);
    on<RemovePlayerSelectionRequested>(_handleRemoveSelection);
    on<ClearAllSelectionsRequested>(_handleClearAll);
  }

  // --- 1. INITIAL FETCH ---
  Future<void> _handleFetchPlayers(
      FetchPlayersRequested event, Emitter<PlayerSelectionState> emit) async {
    _searchRequestToken++;
    emit(state.copyWith(
      status: PlayerSelectionStatus.loading,
      players: [],
      searchResults: [],
      favouritePlayers: [],
      pageNumber: 1,
      isLoadingMore: false,
      hasReachedMax: false,
      lastSearchQuery: '',
    ));

    // Load previously saved favorite player IDs
    final initialFavIds = _normalizeIds(_storageService.getFollowedPlayers());

    const int initialPage = 1; // Most APIs start at page 1
    final String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/players/getPlayersForSelection?page=$initialPage&size=$_pageSize');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final players =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        emit(state.copyWith(
          status: PlayerSelectionStatus.success,
          players: players,
          selectedPlayerIds: initialFavIds,
          pageNumber: initialPage + 1,
          hasReachedMax: players.length < _pageSize,
        ));
      } else {
        emit(state.copyWith(
          status: PlayerSelectionStatus.failure,
          errorMessage: 'Server error: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PlayerSelectionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // --- 2. LOAD MORE (PAGINATION) ---
  Future<void> _handleLoadMorePlayers(LoadMorePlayersRequested event,
      Emitter<PlayerSelectionState> emit) async {
    // Prevent multiple concurrent requests or loading when already at end
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.lastSearchQuery.isNotEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/players/getPlayersForSelection?page=${state.pageNumber}&size=$_pageSize');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final newPlayers =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        final bool reachedMax =
            newPlayers.isEmpty || newPlayers.length < _pageSize;

        emit(state.copyWith(
          players: _appendUniquePlayers(state.players, newPlayers),
          pageNumber: reachedMax ? state.pageNumber : state.pageNumber + 1,
          isLoadingMore: false,
          hasReachedMax: reachedMax,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

//popular players fetch
  Future<void> _handleFetchPopularPlayers(FetchPopularPlayersRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final String baseUrl = BaseUrl().url;
    final url = Uri.parse('$baseUrl/api/players/popularplayers');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final popularPlayers =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        if (_samePlayerIdsInOrder(state.popularPlayers, popularPlayers)) {
          return;
        }

        emit(state.copyWith(
          popularPlayers: popularPlayers,
          // We don't change the status to 'loading' here to avoid
          // flickering the main list if they are loading separately
        ));
      }
    } catch (_) {}
  }

  // --- 3. SEARCH ---
  Future<void> _handleSearchPlayers(SearchPlayerByNameRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final query = event.playerName.trim();

    if (query == state.lastSearchQuery && query.isNotEmpty) {
      return;
    }

    if (query.isEmpty) {
      _searchRequestToken++;
      if (state.searchResults.isNotEmpty || state.lastSearchQuery.isNotEmpty) {
        emit(state.copyWith(searchResults: [], lastSearchQuery: ''));
      }
      return;
    }

    final requestToken = ++_searchRequestToken;
    emit(state.copyWith(lastSearchQuery: query));

    final String baseUrl = BaseUrl().url;
    final url = Uri.parse('$baseUrl/api/players/search?name=$query');

    try {
      final response = await http.get(url);
      if (requestToken != _searchRequestToken) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        emit(state.copyWith(searchResults: results, lastSearchQuery: query));
      } else {
        emit(state.copyWith(searchResults: [], lastSearchQuery: query));
      }
    } catch (_) {
      if (requestToken != _searchRequestToken) return;
      emit(state.copyWith(searchResults: [], lastSearchQuery: query));
    }
  }

  // --- FAVOURITE PLAYERS (BY IDS) ---
  Future<void> _handleFetchPlayersByIds(FetchPlayersByIdsRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final ids = event.ids.where((id) => id > 0).toSet().toList();

    if (ids.isEmpty) {
      emit(state.copyWith(favouritePlayers: const []));
      return;
    }

    final existingMap = {for (final p in state.favouritePlayers) p.id: p};
    final missing = ids.where((id) => !existingMap.containsKey(id)).toList();

    if (missing.isEmpty) {
      final ordered = ids
          .map((id) => existingMap[id])
          .whereType<PlayerSelectionModel>()
          .toList();
      emit(state.copyWith(favouritePlayers: ordered));
      return;
    }

    final String baseUrl = BaseUrl().url;
    final url = Uri.parse('$baseUrl/api/players/by-ids');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({'ids': missing}),
        headers: await buildAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] ?? []);
        final fetched = data
            .map((item) =>
                PlayerSelectionModel.fromJson(item as Map<String, dynamic>))
            .toList();

        for (final p in fetched) {
          existingMap[p.id] = p;
        }

        final ordered = ids
            .map((id) => existingMap[id])
            .whereType<PlayerSelectionModel>()
            .toList();

        emit(state.copyWith(favouritePlayers: ordered));
      }
    } catch (_) {}
  }

  // --- SELECTION HANDLERS ---
  Future<void> _handleToggleSelection(TogglePlayerSelectionRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final selectedSet = state.selectedPlayerIds.toSet();
    final wasSelected = selectedSet.contains(event.playerId);
    if (wasSelected) {
      selectedSet.remove(event.playerId);
    } else {
      selectedSet.add(event.playerId);
    }
    final updatedList = selectedSet.toList(growable: false);

    // Persist locally using FollowingStorageService (no backend sync here)
    await _storageService.syncFromServer(players: updatedList);
    if (wasSelected) {
      await _storageService.removeFollowedPlayerName(event.playerId);
    } else {
      final player = _findPlayerById(event.playerId);
      final englishName = player?.englishName ?? '';
      await _storageService.setFollowedPlayerName(event.playerId, englishName);
    }

    // Emit the new state with the updated list
    emit(state.copyWith(selectedPlayerIds: updatedList));
  }

  Future<void> _handleRemoveSelection(RemovePlayerSelectionRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final selectedSet = state.selectedPlayerIds.toSet();
    if (selectedSet.remove(event.playerId)) {
      final updatedList = selectedSet.toList(growable: false);
      await _storageService.syncFromServer(players: updatedList);
      await _storageService.removeFollowedPlayerName(event.playerId);
      emit(state.copyWith(selectedPlayerIds: updatedList));
    }
  }

  Future<void> _handleClearAll(ClearAllSelectionsRequested event,
      Emitter<PlayerSelectionState> emit) async {
    if (state.selectedPlayerIds.isEmpty) return;
    await _storageService.syncFromServer(players: <int>[]);

    emit(state.copyWith(selectedPlayerIds: const []));
  }

  PlayerSelectionModel? _findPlayerById(int playerId) {
    for (final player in state.searchResults) {
      if (player.id == playerId) return player;
    }
    for (final player in state.players) {
      if (player.id == playerId) return player;
    }
    for (final player in state.popularPlayers) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  List<int> _normalizeIds(List<int> ids) {
    return ids.where((id) => id > 0).toSet().toList(growable: false);
  }

  List<PlayerSelectionModel> _appendUniquePlayers(
    List<PlayerSelectionModel> existing,
    List<PlayerSelectionModel> incoming,
  ) {
    if (incoming.isEmpty) return existing;

    final seen = existing.map((player) => player.id).toSet();
    final merged = List<PlayerSelectionModel>.from(existing);
    for (final player in incoming) {
      if (seen.add(player.id)) {
        merged.add(player);
      }
    }
    return merged;
  }

  bool _samePlayerIdsInOrder(
    List<PlayerSelectionModel> first,
    List<PlayerSelectionModel> second,
  ) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;
    for (int i = 0; i < first.length; i++) {
      if (first[i].id != second[i].id) return false;
    }
    return true;
  }
}
