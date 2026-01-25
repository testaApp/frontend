import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import '../../models/playerWithTeam.dart';
import '../../util/baseUrl.dart';
import 'favouriteteam_event.dart';
import 'favouriteteam_state.dart';

class FavouriteTeamBloc extends Bloc<FavouriteTeamEvent, FavouriteTeamState> {
  FavouriteTeamBloc() : super(FavouriteTeamState()) {
    on<FavouriteTeamEvent>((event, emit) {});

    //  on<TwentyPlayersRequested>(_handleTwentyPlayersRequested);
    on<AddToFavouriteList>(_handleAddToFavlist);
    on<RemoveFromFavouriteList>(_handleRemoveFromFavlist);
    //  on<FavouritePlayersRequested>(_handleFavouritePlayersRequested);
    on<LoadNextPage>(_handleLoadNextPage);
    on<UpdateFavouriteList>(_handleUpdateFavList);
    on<RequestPlayers>(_handleRequestPlayers);
    on<SearchPlayerByName>(_handleSearchPlayersByName);
  }

  Future<void> _handleLoadNextPage(
      LoadNextPage event, Emitter<FavouriteTeamState> emit) async {
    if (state.nextPageStatus == FavTeamStatus.requestInProgress) {
      return;
    }

    emit(state.copyWith(nextPageStatus: FavTeamStatus.requestInProgress));
    String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/playersget?pageNumber=${state.pageNumber}&pageSize=20');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<PlayerWithTeam> playersWithTeam = [];
        final List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          final player = PlayerWithTeam.fromJson(item);
          playersWithTeam.add(player);
        }

        final uniquePlayers = {...state.players, ...playersWithTeam};
        emit(state.copyWith(
            nextPageStatus: FavTeamStatus.requestSuccess,
            players: uniquePlayers.toList(),
            pageNumber: state.pageNumber + 1));
      } else {
        emit(state.copyWith(nextPageStatus: FavTeamStatus.requestFailed));
      }
    } catch (e) {
      emit(state.copyWith(nextPageStatus: FavTeamStatus.requestFailed));
    }
  }

  Future<void> _handleAddToFavlist(
      AddToFavouriteList event, Emitter<FavouriteTeamState> emit) async {
    var favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    List<int> favPlayersId =
        favPlayersBox.get('favPlayersId', defaultValue: []) ?? [];

    if (!favPlayersId.contains(event.playerId)) {
      favPlayersId.add(event.playerId);
      await favPlayersBox.put('favPlayersId', favPlayersId);
    }
  }

  Future<void> _handleUpdateFavList(
      UpdateFavouriteList event, Emitter<FavouriteTeamState> emit) async {
    var favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    List<int> currentFavPlayersId =
        favPlayersBox.get('favPlayersId', defaultValue: []) ?? [];

    List<int> updatedFavPlayersId = <int>{
      ...currentFavPlayersId,
      ...event.newFavPlayersIds.cast<int>()
    }.toList();

    await favPlayersBox.put('favPlayersId', updatedFavPlayersId);

    print('Favorite players list updated successfully.');
  }

  Future<void> _updateFavPlayersList(UpdateFavouriteList event) async {
    Box<List<int>> favPlayersBox;

    try {
      // Open the Hive box
      favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');

      await favPlayersBox.put('favPlayersId', event.newFavPlayersIds);
    } catch (error) {}
  }

  Future<void> _handleRemoveFromFavlist(
      RemoveFromFavouriteList event, Emitter<FavouriteTeamState> emit) async {
    var favPlayersBox = await Hive.openBox<List<int>>('favPlayersBox');
    List<int> favPlayersId =
        favPlayersBox.get('favPlayersId', defaultValue: []) ?? [];

    if (!favPlayersId.contains(event.playerId)) {
      return;
    } else {
      favPlayersId.remove(event.playerId);
    }
  }

  Future<void> _handleRequestPlayers(
      RequestPlayers event, Emitter<FavouriteTeamState> emit) async {
    // Indicate that a request is in progress
    emit(state.copyWith(playersStatus: FavTeamStatus.requestInProgress));

    // Reset pageNumber to 1 for initial fetch or refresh
    int initialPageNumber = 1;
    String baseUrl = BaseUrl().url;
    final url = Uri.parse(
        '$baseUrl/api/playersget?pageNumber=$initialPageNumber&pageSize=20');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<PlayerWithTeam> playersWithTeam = [];
        final List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          final player = PlayerWithTeam.fromJson(item);
          playersWithTeam.add(player);
        }

        // Emit success state with fetched players, and reset pageNumber for subsequent fetches
        emit(state.copyWith(
            playersStatus: FavTeamStatus.requestSuccess,
            players: playersWithTeam,
            // Set pageNumber to 2 since we're ready to fetch the next page after initial load
            pageNumber: initialPageNumber + 1));
      } else {
        emit(state.copyWith(playersStatus: FavTeamStatus.requestFailed));
      }
    } catch (e) {
      print('Error fetching players: $e');
      emit(state.copyWith(playersStatus: FavTeamStatus.requestFailed));
    }
  }

  Future<void> _handleSearchPlayersByName(
      SearchPlayerByName event, Emitter<FavouriteTeamState> emit) async {
    final url = BaseUrl().url;

    final response = await http
        .get(Uri.parse('$url/api/players/search?name=${event.playerName}'));

    try {
      if (response.statusCode == 200) {
        List<PlayerWithTeam> playersWithTeam = [];
        final List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          final player = PlayerWithTeam.fromJson(item);
          playersWithTeam.add(player);
        }

        emit(state.copyWith(
            playersStatus: FavTeamStatus.requestSuccess,
            players: playersWithTeam,
            pageNumber: 0));
      } else {
        emit(state.copyWith(playersStatus: FavTeamStatus.requestFailed));
      }
    } catch (e) {
      //print('error caught while trying to fetch players ${e}');
    }
  }
}
