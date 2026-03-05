enum PersistentPlayerStatus {
  visible,
  hidden,
}

class PersistentPlayerState {
  final PersistentPlayerStatus status;
  final String avatar;
  final String name;
  final String station;
  final String program;
  final String liveLink;

  PersistentPlayerState({
    this.status = PersistentPlayerStatus.hidden,
    this.avatar = '',
    this.name = '',
    this.station = '',
    this.program = '',
    this.liveLink = '',
  });

  PersistentPlayerState copyWith({
    PersistentPlayerStatus? status,
    String? avatar,
    String? name,
    String? station,
    String? program,
    String? liveLink,
  }) {
    return PersistentPlayerState(
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      station: station ?? this.station,
      program: program ?? this.program,
      liveLink: liveLink ?? this.liveLink,
    );
  }
}
