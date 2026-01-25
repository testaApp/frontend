abstract class AudioEvent {}

class setStopped implements AudioEvent {}

class setLivePlaying implements AudioEvent {
  setLivePlaying({required this.avatar});
  String avatar;
}

class setPlaylistPlaying implements AudioEvent {
  setPlaylistPlaying({this.avatar = 'testa_logo.png'});
  String? avatar;
}
