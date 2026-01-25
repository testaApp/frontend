import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  final _currentMediaItemSubject = BehaviorSubject<MediaItem?>();
  Stream<MediaItem?> get mediaItemStream => _currentMediaItemSubject.stream;

  final _isPlayingSubject = BehaviorSubject<bool>();
  Stream<bool> get isPlayingStream => _isPlayingSubject.stream;

  final _processingStateSubject = BehaviorSubject<AudioProcessingState>();
  Stream<AudioProcessingState> get processingStateStream =>
      _processingStateSubject.stream;

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _init();
  }

  void _init() {
    mediaItem.listen((mediaItem) {
      _currentMediaItemSubject.add(mediaItem);
    });

    playbackState.listen((playbackState) {
      _isPlayingSubject.add(playbackState.playing);
      _processingStateSubject.add(playbackState.processingState);
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await stop();
    this.mediaItem.add(mediaItem);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
    await play();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState]!;
    return PlaybackState(
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: processingState,
      playing: playing,
      queueIndex: event.currentIndex,
      updatePosition: Duration.zero,
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
