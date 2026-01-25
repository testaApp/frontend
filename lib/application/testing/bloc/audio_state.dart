enum AudStatus { livestream, playlist, stopped }

class AudioState {
  AudioState({this.playing = AudStatus.stopped, this.avatar = ''});
  AudStatus playing;
  String avatar;

  AudioState copyWith({AudStatus? playing, String? avatar}) => AudioState(
      playing: playing ?? this.playing, avatar: avatar ?? this.avatar);
}
