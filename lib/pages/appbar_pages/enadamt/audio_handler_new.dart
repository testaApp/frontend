import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final currentVolumeNotifier = ValueNotifier<double>(0.0);
  Future<void> _operation = Future.value();

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
      final items = sequence
          .where((source) => source.tag is MediaItem)
          .map((source) => source.tag as MediaItem)
          .toList();
      if (items.isNotEmpty) {
        queue.add(items);
      }
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
    try {
      await _player.stop();
    } on PlatformException catch (e) {
      if (e.code != 'abort') {
        rethrow;
      }
    }
    return super.stop();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    _operation = _operation.then((_) async {
      try {
        await stop();
        await _playlist.clear();
        final audioSource = _createAudioSource(mediaItem);
        await _playlist.add(audioSource);
        await _player.setAudioSource(
          _playlist,
          initialIndex: 0,
          initialPosition: Duration.zero,
        );
        queue.add([mediaItem]);
        this.mediaItem.add(mediaItem);
        await play();
      } on PlatformException catch (e) {
        if (e.code != 'abort') {
          rethrow;
        }
      }
    }).catchError((error) {
      debugPrint('playMediaItem failed: $error');
    });
    await _operation;
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final dynamic urlValue = mediaItem.extras?['url'] ?? mediaItem.id;
    final String url = urlValue.toString();
    return AudioSource.uri(
      Uri.parse(url),
      tag: mediaItem,
    );
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      try {
        await _player.stop();
      } on PlatformException catch (e) {
        if (e.code != 'abort') {
          rethrow;
        }
      }
      await _playlist.clear();
      queue.add(const []);
      // Keep mediaItem as-is to avoid null casts elsewhere.
    } else if (name == 'volume' && extras != null) {
      final volume = extras['volume'] as double;
      await _player.setVolume(volume);
    }
  }
}
