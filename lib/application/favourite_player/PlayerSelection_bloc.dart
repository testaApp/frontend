import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

import '../../domain/player/Players_for_selection_model.dart';
import '../../util/baseUrl.dart';
import 'PlayerSelection_event.dart';
import 'PlayerSelection_state.dart';

class PlayerSelectionBloc
    extends Bloc<PlayerSelectionEvent, PlayerSelectionState> {
  PlayerSelectionBloc() : super(const PlayerSelectionState()) {
    on<FetchPlayersRequested>(_handleFetchPlayers);
    on<LoadMorePlayersRequested>(_handleLoadMorePlayers);
    on<FetchPopularPlayersRequested>(_handleFetchPopularPlayers);
    on<SearchPlayerByNameRequested>(_handleSearchPlayers);
    on<TogglePlayerSelectionRequested>(_handleToggleSelection);
    on<RemovePlayerSelectionRequested>(_handleRemoveSelection);
    on<ClearAllSelectionsRequested>(_handleClearAll);
  }

  // --- 1. INITIAL FETCH ---
  Future<void> _handleFetchPlayers(
      FetchPlayersRequested event, Emitter<PlayerSelectionState> emit) async {
    emit(state.copyWith(
      status: PlayerSelectionStatus.loading,
      players: [],
      searchResults: [],
      pageNumber: 1,
      isLoadingMore: false,
      hasReachedMax: false,
    ));

    // Load previously saved favorite player IDs
    final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    final initialFavIds =
        favPlayersBox.get('favPlayersId', defaultValue: <int>[])?.cast<int>() ??
            [];

    const int initialPage = 1; // Most APIs start at page 1
    const int pageSize = 100;
    final String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/players/getPlayersForSelection?page=$initialPage&size=$pageSize');

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
          hasReachedMax: players.length <
              pageSize, // If less than pageSize, likely last page
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
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    final String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/players/getPlayersForSelection?page=${state.pageNumber}&size=50');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final newPlayers =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        final bool reachedMax = newPlayers.isEmpty || newPlayers.length < 30;

        emit(state.copyWith(
          players: [...state.players, ...newPlayers],
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

        emit(state.copyWith(
          popularPlayers: popularPlayers,
          // We don't change the status to 'loading' here to avoid
          // flickering the main list if they are loading separately
        ));
      }
    } catch (e) {
      // Handle error silently or log it;
      // usually you don't want to crash the whole UI if just the "popular" strip fails
      print('Error fetching popular players: $e');
    }
  }

  // --- 3. SEARCH ---
  Future<void> _handleSearchPlayers(SearchPlayerByNameRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final query = event.playerName.trim();

    if (query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    final String baseUrl = BaseUrl().url;
    final url = Uri.parse('$baseUrl/api/players/search?name=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results =
            data.map((item) => PlayerSelectionModel.fromJson(item)).toList();

        emit(state.copyWith(searchResults: results));
      } else {
        emit(state.copyWith(searchResults: []));
      }
    } catch (_) {
      emit(state.copyWith(searchResults: []));
    }
  }

  // --- SELECTION HANDLERS ---
  Future<void> _handleToggleSelection(TogglePlayerSelectionRequested event,
      Emitter<PlayerSelectionState> emit) async {
    // Create a NEW list instance to ensure Bloc detects the state change
    final updatedList = List<int>.from(state.selectedPlayerIds);

    if (updatedList.contains(event.playerId)) {
      updatedList.remove(event.playerId);
    } else {
      updatedList.add(event.playerId);
    }

    // Persist to Hive
    final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    await favPlayersBox.put('favPlayersId', updatedList);

    // Emit the new state with the updated list
    emit(state.copyWith(selectedPlayerIds: updatedList));
  }

  Future<void> _handleRemoveSelection(RemovePlayerSelectionRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final updatedList = List<int>.from(state.selectedPlayerIds);
    if (updatedList.remove(event.playerId)) {
      final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
      await favPlayersBox.put('favPlayersId', updatedList);
      emit(state.copyWith(selectedPlayerIds: updatedList));
    }
  }

  Future<void> _handleClearAll(ClearAllSelectionsRequested event,
      Emitter<PlayerSelectionState> emit) async {
    final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    await favPlayersBox.put('favPlayersId', <int>[]);

    emit(state.copyWith(selectedPlayerIds: const []));
  }
}
