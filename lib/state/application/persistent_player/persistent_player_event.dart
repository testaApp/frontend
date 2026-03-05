abstract class PersistentPlayerEvent {}

class ShowPersistentPlayer extends PersistentPlayerEvent {
  final String avatar;
  final String name;
  final String station;
  final String program;
  final String liveLink;

  ShowPersistentPlayer({
    required this.avatar,
    required this.name,
    required this.station,
    required this.program,
    required this.liveLink,
  });
}

class HidePersistentPlayer extends PersistentPlayerEvent {}
