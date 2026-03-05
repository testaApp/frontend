import 'package:blogapp/domain/player/playerModel.dart';

enum playersStatus {
  requested,
  serverError,
  connectionError,
  success,
  initial,
  notFound
}

class PlayerProfileState {
  playersStatus status;
  PlayerProfile? player;
  PlayerProfileState({this.status = playersStatus.initial, this.player});
  PlayerProfileState copyWith({
    playersStatus? status,
    PlayerProfile? player,
  }) {
    return PlayerProfileState(
      status: status ?? this.status,
      player: player ?? this.player,
    );
  }
}
