// Events
abstract class YoutubePlayerEvent {}

class InitializePlayer extends YoutubePlayerEvent {
  final String videoUrl;
  InitializePlayer(this.videoUrl);
}
