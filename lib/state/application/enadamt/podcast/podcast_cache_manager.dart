import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:blogapp/models/program_card/PodcastModel.dart';

class PodcastCacheManager {
  static const String _podcastsKey = 'podcasts_cache';
  static const String _cacheEntryKey = 'latest_podcasts';
  static const Duration maxCacheAge = Duration(minutes: 30);
  static const String cacheVersion = '1.0';

  Future<void> cachePodcasts(
    List<PodcastModel> podcasts, {
    required int page,
    required bool hasNext,
    required int limit,
  }) async {
    try {
      final box = await Hive.openBox<String>(_podcastsKey);
      final cacheEntry = {
        'version': cacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'page': page,
        'hasNext': hasNext,
        'limit': limit,
        'data': podcasts.map((e) => e.toJson()).toList(),
      };

      await box.put(_cacheEntryKey, jsonEncode(cacheEntry));
    } catch (e) {
      print('PodcastCacheManager cache error: $e');
    }
  }

  Future<CachedPodcasts?> getPodcastsCache() async {
    try {
      final box = await Hive.openBox<String>(_podcastsKey);
      final cachedData = box.get(_cacheEntryKey);
      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      if (decodedCache['version'] != cacheVersion) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);
      if (cacheAge > maxCacheAge) {
        await box.clear();
        return null;
      }

      final items = (decodedCache['data'] as List)
          .map((e) => PodcastModel.fromCacheJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      return CachedPodcasts(
        items: items,
        page: decodedCache['page'] is int ? decodedCache['page'] as int : 1,
        hasNext: decodedCache['hasNext'] == true,
        limit: decodedCache['limit'] is int ? decodedCache['limit'] as int : 20,
      );
    } catch (e) {
      print('PodcastCacheManager read error: $e');
      return null;
    }
  }
}

class CachedPodcasts {
  final List<PodcastModel> items;
  final int page;
  final bool hasNext;
  final int limit;

  const CachedPodcasts({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.limit,
  });
}
