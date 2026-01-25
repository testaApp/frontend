// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../pages/bottom_navigation/Tv/highlight/Highlight_player.dart';

// class YouTubeCacheService {
//   static final YouTubeCacheService _instance = YouTubeCacheService._internal();
//   factory YouTubeCacheService() => _instance;
//   YouTubeCacheService._internal();

//   // Pool of pre-loaded video blocs
//   final Map<String, YouTubePlayerBloc> _cache = {};
//   final int _maxCacheSize = 5; // Cache up to 5 videos

//   // Pre-load a video in the background
//   void preload(String videoUrl) {
//     // Don't preload if already in cache
//     if (_cache.containsKey(videoUrl)) return;

//     // Remove oldest if cache is full
//     if (_cache.length >= _maxCacheSize) {
//       final oldestKey = _cache.keys.first;
//       _cache[oldestKey]?.close();
//       _cache.remove(oldestKey);
//     }

//     // Create and cache the bloc
//     final bloc = YouTubePlayerBloc()..add(LoadYouTubeVideo(videoUrl));
//     _cache[videoUrl] = bloc;
//   }

//   // Get a pre-loaded bloc (or create new one)
//   YouTubePlayerBloc getOrCreate(String videoUrl) {
//     if (_cache.containsKey(videoUrl)) {
//       final bloc = _cache[videoUrl]!;
//       _cache.remove(videoUrl); // Remove from cache after use
//       return bloc;
//     }

//     // Not cached, create new one
//     return YouTubePlayerBloc()..add(LoadYouTubeVideo(videoUrl));
//   }

//   // Check if video is ready to play
//   bool isReady(String videoUrl) {
//     final bloc = _cache[videoUrl];
//     return bloc?.state is YouTubePlayerReady;
//   }

//   // Get loading progress (0.0 to 1.0)
//   double getProgress(String videoUrl) {
//     final bloc = _cache[videoUrl];
//     final state = bloc?.state;
//     if (state is YouTubePlayerLoading) return state.progress;
//     if (state is YouTubePlayerReady) return 1.0;
//     return 0.0;
//   }

//   // Clear all cache
//   void clearAll() {
//     for (var bloc in _cache.values) {
//       bloc.close();
//     }
//     _cache.clear();
//   }

//   // Clear specific video
//   void clear(String videoUrl) {
//     _cache[videoUrl]?.close();
//     _cache.remove(videoUrl);
//   }
// }
