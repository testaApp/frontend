// Events
import 'package:equatable/equatable.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class InitializePlayer extends VideoPlayerEvent {
  final String videoUrl;
  const InitializePlayer(this.videoUrl);

  @override
  List<Object> get props => [videoUrl];
}

// Add this new event
class AddDirectChannel extends VideoPlayerEvent {
  final String name;
  final String url;
  final String? logo;

  const AddDirectChannel({
    required this.name,
    required this.url,
    this.logo,
  });
}

class DisposePlayer extends VideoPlayerEvent {}

class StartCasting extends VideoPlayerEvent {
  final String videoUrl;
  const StartCasting(this.videoUrl);

  @override
  List<Object> get props => [videoUrl];
}

class StopCasting extends VideoPlayerEvent {}
