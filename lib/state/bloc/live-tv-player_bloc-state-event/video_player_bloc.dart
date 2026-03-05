// video_player_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import 'video_player_event.dart';
import 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  VideoPlayerBloc() : super(VideoPlayerInitial()) {
    on<InitializePlayer>(_initialize);
    on<DisposePlayer>(_dispose);
  }

  /// Resolve redirect URLs to get the actual stream URL
  Future<String> _resolveStreamUrl(String url, {int maxRedirects = 10}) async {
    try {
      print('🔍 Resolving: $url');

      var currentUrl = url;
      var redirectCount = 0;

      while (redirectCount < maxRedirects) {
        final client = http.Client();

        try {
          final request = http.Request('GET', Uri.parse(currentUrl))
            ..followRedirects = false
            ..headers.addAll({
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
              'Accept': '*/*',
              'Connection': 'keep-alive',
            });

          final streamedResponse = await client.send(request);
          final statusCode = streamedResponse.statusCode;

          print('📡 Status: $statusCode');

          // Check for redirect status codes
          if (statusCode >= 300 && statusCode < 400) {
            final location = streamedResponse.headers['location'];

            if (location == null) {
              await streamedResponse.stream.drain();
              throw Exception('Redirect without location header');
            }

            // Handle relative URLs
            currentUrl = location.startsWith('http')
                ? location
                : Uri.parse(currentUrl).resolve(location).toString();

            print('➡️  Redirecting to: $currentUrl');
            redirectCount++;

            await streamedResponse.stream.drain();
          }
          // Success - this is the final URL
          else if (statusCode == 200) {
            print('✅ Final stream URL: $currentUrl');
            await streamedResponse.stream.drain();
            client.close();
            return currentUrl;
          }
          // Error
          else {
            await streamedResponse.stream.drain();
            client.close();
            throw Exception('Cannot access stream (HTTP $statusCode)');
          }
        } catch (e) {
          client.close();
          rethrow;
        }
      }

      throw Exception('Too many redirects (>$maxRedirects)');
    } catch (e) {
      print('❌ Resolution failed: $e');
      rethrow;
    }
  }

  Future<void> _initialize(
    InitializePlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(VideoPlayerLoading());

    try {
      // Dispose old controllers
      _videoController?.pause();
      _videoController?.dispose();
      _chewieController?.dispose();

      print('🎬 Original URL: ${event.videoUrl}');

      // ✅ RESOLVE THE URL IF IT'S A REDIRECT
      String finalUrl = event.videoUrl;

      if (_isRedirectUrl(event.videoUrl)) {
        print('🔄 Detected redirect URL, resolving...');
        try {
          finalUrl = await _resolveStreamUrl(event.videoUrl);
          print('✅ Resolved to: $finalUrl');
        } catch (e) {
          print('❌ Failed to resolve URL: $e');
          throw Exception(
              'Cannot resolve video URL. This link may be expired or invalid.\n\n'
              'Error: ${e.toString()}');
        }
      }

      // Detect stream type
      final isLiveStream = _isLiveStream(finalUrl);
      print('🎬 Stream type: ${isLiveStream ? "LIVE (HLS)" : "VOD"}');

      // Try with original URL first (some streams need the ad params)
      String urlToUse = finalUrl;
      print('📺 Using URL: $urlToUse');

      // Initialize video player with resolved URL and proper headers
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(urlToUse),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': '*/*',
          'Accept-Encoding': 'identity',
          'Connection': 'keep-alive',
          'Referer': 'https://jmp2.uk/',
          'Origin': 'https://jmp2.uk',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'cross-site',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      print('⏳ Initializing video controller...');

      try {
        await _videoController!.initialize();
        print('✅ Video controller initialized');
      } catch (e) {
        print('⚠️  First attempt failed, trying with cleaned URL...');

        // Dispose failed controller
        _videoController?.dispose();

        // Try with cleaned URL (no ad params)
        final cleanUrl = _cleanStreamUrl(finalUrl);
        print('🧹 Trying cleaned URL: $cleanUrl');

        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(cleanUrl),
          httpHeaders: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
            'Accept': '*/*',
            'Referer': 'https://jmp2.uk/',
          },
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );

        await _videoController!.initialize();
        print('✅ Video controller initialized with cleaned URL');
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: !isLiveStream,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        isLive: isLiveStream,
        draggableProgressBar: !isLiveStream,
        aspectRatio: _videoController!.value.aspectRatio == 0
            ? 16 / 9
            : _videoController!.value.aspectRatio,
        hideControlsTimer: const Duration(seconds: 3),
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.greenAccent,
          bufferedColor: Colors.white54,
          handleColor: Colors.greenAccent,
          backgroundColor: Colors.white24,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Playback Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      );

      emit(VideoPlayerReady(_chewieController!));
    } catch (e) {
      print('💥 Video initialization error: $e');

      // Provide user-friendly error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('403')) {
        errorMessage =
            'This channel is not available in your region or requires authentication.';
      } else if (errorMessage.contains('404')) {
        errorMessage = 'Channel stream not found. It may be offline.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      }

      emit(VideoPlayerError(errorMessage));
    }
  }

  /// Check if URL is a redirect/shortener that needs resolution
  bool _isRedirectUrl(String url) {
    final redirectDomains = [
      'jmp2.uk',
      'bit.ly',
      'tinyurl.com',
      'goo.gl',
      't.co',
      'ow.ly',
      'short.link',
      'rebrand.ly',
    ];

    return redirectDomains.any((domain) => url.contains(domain));
  }

  /// Check if URL is a live stream
  bool _isLiveStream(String url) {
    return url.contains('.m3u8') ||
        url.contains('.m3u') ||
        url.contains('.ts') ||
        url.toLowerCase().contains('live');
  }

  /// Clean problematic URL parameters
  String _cleanStreamUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Remove ad tracking parameters that might cause 403 errors
      final cleanParams = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        // Keep only essential parameters, remove ad tracking ones
        if (!key.startsWith('ads.') &&
            !value.contains('%7B') &&
            !value.contains('%7D')) {
          cleanParams[key] = value;
        }
      });

      // Rebuild URL with clean parameters
      if (cleanParams.isEmpty) {
        return uri.replace(query: '').toString();
      }

      return uri.replace(queryParameters: cleanParams).toString();
    } catch (e) {
      return url;
    }
  }

  void _dispose(DisposePlayer event, Emitter<VideoPlayerState> emit) {
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    emit(VideoPlayerInitial());
  }

  @override
  Future<void> close() {
    _videoController?.dispose();
    _chewieController?.dispose();
    return super.close();
  }
}
