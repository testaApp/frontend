import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../models/playlist/playlist_model.dart';
import 'notifiers/music_type_notifiers.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'playlist_repository.dart';
import 'service_locator.dart';

class PageManager {
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentStationNotifier = ValueNotifier<String>('');
  final currentSongArtistNotifier = ValueNotifier<String>('');
  final currentSongAvatarNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();

  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final musicTypeNotifier = MusicTypeNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final currentVolumeNotifier = ValueNotifier<double>(0.0);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  Future<void> init() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> playMediaItem(PlaylistModel song) async {
    MediaItem media = MediaItem(
      id: '${song.audioUrl}/${Random().nextInt(700)}',
      album: '',
      title: song.title,
      extras: {
        'url': song.audioUrl,
        'picture': song.avatar,
        'station': song.station
      },
      artist: song.journalist,
      artUri: Uri.parse(song.avatar),
    );
    currentSongTitleNotifier.value = media.title;
    currentSongArtistNotifier.value = media.artist ?? '';
    currentSongAvatarNotifier.value = media.extras?['picture'] ?? '';
    currentStationNotifier.value = media.extras?['station'] ?? '';
    await _audioHandler.playMediaItem(media);

    musicTypeNotifier.value = MusicType.live;
  }

  Future<void> SeekForward() async {
    await _audioHandler
        .seek(Duration(seconds: progressNotifier.value.current.inSeconds + 10));
  }

  Future<void> SeekBack() async {
    await _audioHandler
        .seek(Duration(seconds: progressNotifier.value.current.inSeconds - 10));
  }

  Future<void> loadPlaylist(List<PlaylistModel> playlist, int index) async {
    try {
      final mediaItems = playlist.map((song) {
        return MediaItem(
          id: '${song.audioUrl}/${Random().nextInt(700)}',
          album: '',
          title: song.title,
          extras: {
            'url': song.audioUrl,
            'picture': song.avatar,
            'station': song.station
          },
          artist: song.journalist,
          artUri: Uri.parse(song.avatar),
        );
      }).toList();

      await _audioHandler.stop(); // Stop the current playback
      // await
      await _audioHandler
          .addQueueItems(mediaItems); // Add the new playlist to the queue

      // await
      // _audioHandler.skipToQueueItem(index); // Skip to the clicked song index
      await playSongAtIndex(index);
      // _audioHandler.play(); // Start playing the clicked song

      musicTypeNotifier.value = MusicType.playlist;
    } catch (e) {
      //print(e);
    }
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
        currentSongArtistNotifier.value = '';
        currentSongAvatarNotifier.value = '';
        currentStationNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void setVolume(double volume) {
    _audioHandler.customAction('volume', {'volume': volume});
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        playButtonNotifier.value = ButtonState.stopped;
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongArtistNotifier.value = mediaItem?.artist ?? '';
      currentSongAvatarNotifier.value = mediaItem?.extras?['picture'] ?? '';
      currentStationNotifier.value = mediaItem?.extras?['station'] ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add() async {
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    await _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  Future<void> stop() async {
    await _audioHandler.stop();
  }

  Future<void> playSongAtIndex(int index) async {
    // void playSongAtIndex(int index) {
    await _audioHandler.skipToQueueItem(index);
    await _audioHandler.play();
    // }
  }

  Future<void> forwardFiveSeconds() async {
    await _audioHandler.rewind();
  }

  Future<void> onSeekBackward(bool begin) async {
    if (begin) {
      // Get the current position

      final Duration position =
          _audioHandler.playbackState.value.bufferedPosition;

      // Calculate the new position by subtracting 5 seconds
      final Duration newPosition = position - const Duration(seconds: 5);

      // Seek the audio player to the new position
      await _audioHandler.seek(newPosition);
    }
  }

  Future<void> onSeekForward(bool begin) async {
    if (begin) {
      // Get the current position

      final Duration position =
          _audioHandler.playbackState.value.bufferedPosition;

      // Calculate the new position by subtracting 5 seconds
      final Duration newPosition = position - const Duration(seconds: 5);

      // Seek the audio player to the new position
      await _audioHandler.seek(newPosition);
    }
  }
}
