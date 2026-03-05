import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

// External Imports (Definitions provided in Section 2 below)
import 'package:blogapp/domain/player/playerModel.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'favouriteplayer_event.dart';
import 'favouriteplayer_state.dart';

class FavouriteplayerBloc
    extends Bloc<FavouriteplayerEvent, FavouriteplayerState> {
  FavouriteplayerBloc() : super(FavouriteplayerState()) {
    // Selection Handlers (Already fixed to emit state)
    on<AddToFavouriteList>(_handleAddToFavlist);
    on<RemoveFromFavouriteList>(_handleRemoveFromFavlist);

    // Pagination/Data Fetching
    on<LoadNextPage>(_handleLoadNextPage);
    on<UpdateFavouriteList>(_handleUpdateFavList);
    on<RequestPlayers>(_handleRequestPlayers);

    // Search Handlers (FIXED to manage searchQuery in state)
    on<SearchPlayerByName>(_handleSearchPlayersByName);
    on<ClearSearch>(_handleClearSearch);
  }

  // NOTE: We no longer need 'String _latestSearchQuery = "";'
  // as the search query is now managed in 'state.searchQuery'.

  // --- HANDLER FOR INITIAL PLAYER REQUEST (Loads initial favorites) ---
  Future<void> _handleRequestPlayers(
      RequestPlayers event, Emitter<FavouriteplayerState> emit) async {
    // Start request progress
    emit(state.copyWith(playersStatus: FavPlayersStatus.requestInProgress));

    // 1. Load existing favorites from Hive
    final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    final initialFavIds = favPlayersBox
            .get('favPlayersId', defaultValue: [])
            ?.cast<int>()
            .toSet() ??
        {};

    // 2. Proceed with network request
    const int initialPageNumber = 0;
    const int initialPageSize = 40;
    final String baseUrl = BaseUrl().url;

    final url = Uri.parse(
        '$baseUrl/api/players/allProfiles?page=$initialPageNumber&size=$initialPageSize');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        final players =
            data.map((item) => PlayerProfile.fromJson(item)).toList();

        // 3. Emit success state, including the players AND the initial favorite IDs
        emit(state.copyWith(
          playersStatus: FavPlayersStatus.requestSuccess,
          players: players,
          pageNumber: initialPageNumber + 1,
          favoritePlayerIds: initialFavIds,
          // Retain the existing search query state if it was somehow set before loading
          searchQuery: state.searchQuery,
        ));
      } else {
        emit(state.copyWith(playersStatus: FavPlayersStatus.requestFailed));
      }
    } catch (e) {
      emit(state.copyWith(playersStatus: FavPlayersStatus.requestFailed));
    }
  }

  // --- HANDLER FOR PAGINATION ---

  Future<void> _handleLoadNextPage(
      LoadNextPage event, Emitter<FavouriteplayerState> emit) async {
    if (state.nextPageStatus == FavPlayersStatus.requestInProgress) return;

    emit(state.copyWith(nextPageStatus: FavPlayersStatus.requestInProgress));

    const int subsequentPageSize = 30;
    final String baseUrl = BaseUrl().url;

    final url = Uri.parse(
        '$baseUrl/api/players/allProfiles?page=${state.pageNumber}&size=$subsequentPageSize');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        final newPlayers =
            data.map((item) => PlayerProfile.fromJson(item)).toList();

        // Ensure no duplicates
        final existingPlayerIds = state.players.map((p) => p.id).toSet();
        final uniqueNewPlayers =
            newPlayers.where((p) => !existingPlayerIds.contains(p.id)).toList();

        final updatedPlayers = [...state.players, ...uniqueNewPlayers];

        emit(state.copyWith(
          nextPageStatus: FavPlayersStatus.requestSuccess,
          players: updatedPlayers,
          pageNumber: state.pageNumber + 1,
        ));
      } else {
        emit(state.copyWith(nextPageStatus: FavPlayersStatus.requestFailed));
      }
    } catch (e) {
      emit(state.copyWith(nextPageStatus: FavPlayersStatus.requestFailed));
    }
  }

  // --- HANDLER FOR SEARCH (FIXED for state persistence) ---

  Future<void> _handleSearchPlayersByName(
      SearchPlayerByName event, Emitter<FavouriteplayerState> emit) async {
    final currentQuery = event.playerName.trim();

    // 1. Immediately update the state with the current query (for persistence)
    emit(state.copyWith(searchQuery: currentQuery));

    if (currentQuery.isEmpty) {
      emit(state.copyWith(
        searchStatus: FavPlayersStatus.initial,
        searchResults: [],
      ));
      return;
    }

    emit(state.copyWith(searchStatus: FavPlayersStatus.requestInProgress));

    final String baseUrl = BaseUrl().url;

    final url = Uri.parse('$baseUrl/api/players/search?name=$currentQuery');

    try {
      final response = await http.get(url);

      // Use the latest state.searchQuery for cancellation check
      if (state.searchQuery.trim() != currentQuery) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final players =
            data.map((item) => PlayerProfile.fromJson(item)).toList();

        emit(state.copyWith(
          searchStatus: FavPlayersStatus.requestSuccess,
          searchResults: players,
        ));
      } else {
        emit(state.copyWith(searchStatus: FavPlayersStatus.requestFailed));
      }
    } catch (e) {
      // Use the latest state.searchQuery for cancellation check
      if (state.searchQuery.trim() != currentQuery) return;
      emit(state.copyWith(searchStatus: FavPlayersStatus.requestFailed));
    }
  }

  // --- HANDLER TO CLEAR SEARCH (FIXED for state persistence) ---
  Future<void> _handleClearSearch(
      ClearSearch event, Emitter<FavouriteplayerState> emit) async {
    emit(state.copyWith(
      searchResults: [],
      searchStatus: FavPlayersStatus.initial,
      searchQuery: '', // *** FIX: Clear the stored query in state ***
    ));
  }

  // --- FIXED HIVE/BLOC STATE HANDLERS ---

  Future<void> _handleAddToFavlist(
      AddToFavouriteList event, Emitter<FavouriteplayerState> emit) async {
    // 1. Create a mutable copy of the current set from the BLoC state
    final updatedFavoritesSet = Set<int>.from(state.favoritePlayerIds);

    if (!updatedFavoritesSet.contains(event.playerId)) {
      // 2. BLoC State Update (Add to Set)
      updatedFavoritesSet.add(event.playerId);

      // 3. Hive Update (Open Box, Get List, Add ID, Put List)
      final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
      final favPlayersIdList =
          favPlayersBox.get('favPlayersId', defaultValue: [])?.cast<int>() ??
              [];

      favPlayersIdList.add(event.playerId);
      await favPlayersBox.put('favPlayersId', favPlayersIdList);

      // 4. Emit the new state to trigger UI rebuild
      emit(state.copyWith(
        favoritePlayerIds: updatedFavoritesSet,
      ));
    }
  }

  Future<void> _handleRemoveFromFavlist(
      RemoveFromFavouriteList event, Emitter<FavouriteplayerState> emit) async {
    // 1. Create a mutable copy of the current set from the BLoC state
    final updatedFavoritesSet = Set<int>.from(state.favoritePlayerIds);

    if (updatedFavoritesSet.contains(event.playerId)) {
      // 2. BLoC State Update (Remove from Set)
      updatedFavoritesSet.remove(event.playerId);

      // 3. Hive Update (Open Box, Get List, Remove ID, Put List)
      final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
      final favPlayersIdList =
          favPlayersBox.get('favPlayersId', defaultValue: [])?.cast<int>() ??
              [];

      favPlayersIdList.remove(event.playerId);
      await favPlayersBox.put('favPlayersId', favPlayersIdList);

      // 4. Emit the new state to trigger UI rebuild
      emit(state.copyWith(
        favoritePlayerIds: updatedFavoritesSet,
      ));
    }
  }

  Future<void> _handleUpdateFavList(
      UpdateFavouriteList event, Emitter<FavouriteplayerState> emit) async {
    final favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');

    // Merge the existing BLoC favorites with the incoming ones
    final updatedFavPlayersSet = Set<int>.from(state.favoritePlayerIds)
        .union(event.newFavPlayersIds.cast<int>().toSet());

    // Update Hive (store as List)
    await favPlayersBox.put('favPlayersId', updatedFavPlayersSet.toList());

    // Update BLoC state
    emit(state.copyWith(
      favoritePlayerIds: updatedFavPlayersSet,
    ));
  }
}
