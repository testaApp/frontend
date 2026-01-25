import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final currentVolumeNotifier = ValueNotifier<double>(0.0);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    _listenForVolumeChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print('Error loading empty playlist: $e');
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _listenForVolumeChanges() {
    _player.volumeStream.listen((volume) {
      currentVolumeNotifier.value = volume;
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await stop();
    this.mediaItem.add(mediaItem);
    await _player.setUrl(mediaItem.id);
    await play();
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.stop();
      await _player.setAudioSource(_playlist);
      await _loadEmptyPlaylist();
    } else if (name == 'volume' && extras != null) {
      final volume = extras['volume'] as double;
      await _player.setVolume(volume);
    }
  }
}
