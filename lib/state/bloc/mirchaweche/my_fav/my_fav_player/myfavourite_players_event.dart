abstract class MyfavouritePlayersEvent {}

class MyfavouritePlayersRequested extends MyfavouritePlayersEvent {}

class PlayersRequested extends MyfavouritePlayersEvent {
  final String? teamId;
  PlayersRequested({required this.teamId});
}
