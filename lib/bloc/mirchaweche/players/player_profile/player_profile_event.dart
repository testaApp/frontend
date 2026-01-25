abstract class PlayerProfileEvent {
  const PlayerProfileEvent();
}

class PlayerProfileRequested extends PlayerProfileEvent {
  final int playerId;
  PlayerProfileRequested({required this.playerId});
}

class PlayerProfilefor3 extends PlayerProfileEvent {
  final String teamId;
  PlayerProfilefor3({required this.teamId});
}
