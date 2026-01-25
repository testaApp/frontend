class VolumeState {
  double volume;
  VolumeState({this.volume = 1.0});

  VolumeState copyWith({double? volume}) =>
      VolumeState(volume: volume ?? this.volume);
}
