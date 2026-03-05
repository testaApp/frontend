import 'package:blogapp/domain/player/Players_for_selection_model.dart';

enum playersStatus { requested, serverError, connectionError, success, initial }

class MyfavouritePlayersState {
  final playersStatus status;
  final List<PlayerSelectionModel> players;

  MyfavouritePlayersState({
    this.status = playersStatus.initial,
    this.players = const [],
  });

  MyfavouritePlayersState copyWith({
    playersStatus? status,
    List<PlayerSelectionModel>? players,
  }) {
    return MyfavouritePlayersState(
      status: status ?? this.status,
      players: players ?? this.players,
    );
  }

  // ✅ Add this getter for favourite IDs
  List<int> get favouritePlayerIds =>
      players.map((player) => player.id).toList();
}
