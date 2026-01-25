import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_handler_2.dart';

Future<AudioHandler> initAudioService() {
  return AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
        androidNotificationChannelId: 'testa',
        androidNotificationChannelName: 'Audio Service Demo',
        preloadArtwork: true),
  );
}

class AudioServiceInitializer extends StatefulWidget {
  final Widget child;

  const AudioServiceInitializer({super.key, required this.child});

  @override
  _AudioServiceInitializerState createState() =>
      _AudioServiceInitializerState();
}

class _AudioServiceInitializerState extends State<AudioServiceInitializer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // initAudioService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

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
      //print("Error: $e");
    }
  }

  // Future<void> updatePlaylist()

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
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
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

  void _listenForVolumeChanges() {
    _player.volumeStream.listen((volume) {
      currentVolumeNotifier.value = volume;
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

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    try {
      final audioSource = mediaItems.map(_createAudioSource);

      ///
      if (mediaItems.isNotEmpty) {
        await _playlist.clear();
        await _playlist.addAll(audioSource.toList());
        //  await _player.play();
        // notify system
        final newQueue = queue.value..addAll(mediaItems);
        queue.add(newQueue);
      }
    } catch (e) {
      //print(e);
    }
  }

  Future<void> makeNewPlaylist(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems.map(_createAudioSource);
    await _playlist.clear();
    await _playlist.addAll(audioSource.toList());
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    await _playlist.add(audioSource);
    await _player.play();
    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    await _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      await _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      await _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      await super.stop();
    } else if (name == 'volume') {
      double volume = extras!['volume'];

      await _player.setVolume(volume);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> playMediaItem(mediaItem) async {
    await _player.setUrl(mediaItem.id);
    await _player.play();
  }

  Future<void> playSongAtIndex(int index) async {
    if (index < 0 || index >= queue.value.length) return;

    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }

    if (_player.playing && _player.currentIndex == index) {
      // If the requested song is already playing, no action is needed.
      return;
    }

    await _player.pause();
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  Future<void> onSeekForward(bool isLongPress) async {
    await forwardFiveSeconds();
  }

  Future<void> onSeekBackward(bool isLongPress) async {
    await backFiveSeconds();
  }

  Future<void> forwardFiveSeconds() async {
    final currentPosition = _player.position;
    final newPosition = currentPosition + const Duration(seconds: 5);
    await _player.seek(newPosition);
  }

  Future<void> backFiveSeconds() async {
    final currentPosition = _player.position;
    final newPosition = currentPosition - const Duration(seconds: 5);
    await _player.seek(newPosition);
  }
}
