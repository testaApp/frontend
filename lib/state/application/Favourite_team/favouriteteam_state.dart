import 'package:blogapp/domain/player/player.model.dart';
import 'package:blogapp/models/playerWithTeam.dart';

enum FavTeamStatus {
  requestInProgress,
  requestFailed,
  requestSuccess,
  unknown,
  initial
}

class FavouriteTeamState {
  final List<Player> twentyPlayers;
  final List<Player> favouritePlayers;
  final FavTeamStatus twentyPlayersStatus;
  final FavTeamStatus favouritePlayersStatus;
  final List<PlayerWithTeam> players;
  final FavTeamStatus playersStatus;
  int pageNumber;
  FavTeamStatus searchStatus;
  FavTeamStatus nextPageStatus;
  FavouriteTeamState(
      {this.twentyPlayers = const [],
      this.twentyPlayersStatus = FavTeamStatus.unknown,
      this.favouritePlayers = const [],
      this.favouritePlayersStatus = FavTeamStatus.unknown,
      this.pageNumber = 0,
      this.players = const [],
      this.playersStatus = FavTeamStatus.initial,
      this.searchStatus = FavTeamStatus.initial,
      this.nextPageStatus = FavTeamStatus.initial});

  FavouriteTeamState copyWith(
          {final List<Player>? twentyPlayers,
          final List<Player>? favouritePlayers,
          final FavTeamStatus? twentyPlayersStatus,
          final FavTeamStatus? favouritePlayersStatus,
          int? pageNumber,
          final List<PlayerWithTeam>? players,
          final FavTeamStatus? playersStatus,
          final FavTeamStatus? searchStatus,
          final FavTeamStatus? nextPageStatus}) =>
      FavouriteTeamState(
          twentyPlayers: twentyPlayers ?? this.twentyPlayers,
          twentyPlayersStatus: twentyPlayersStatus ?? this.twentyPlayersStatus,
          favouritePlayersStatus:
              favouritePlayersStatus ?? this.favouritePlayersStatus,
          favouritePlayers: favouritePlayers ?? this.favouritePlayers,
          pageNumber: pageNumber ?? this.pageNumber,
          players: players ?? this.players,
          playersStatus: playersStatus ?? this.playersStatus,
          searchStatus: searchStatus ?? this.searchStatus,
          nextPageStatus: nextPageStatus ?? this.nextPageStatus);
}
