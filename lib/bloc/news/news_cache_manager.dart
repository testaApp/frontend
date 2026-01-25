import 'dart:convert';
import 'package:hive/hive.dart';
import '../../models/news.dart';
import '../../pages/appbar_pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import '../../repository/news_repository.dart';
import 'dart:async';

class NewsCacheManager {
  // Cache configuration constants
  static const String _newsKey = 'news_cache';
  static const String _forYouKey = 'for_you_news_cache';
  static const String _transferNewsKey = 'transfer_news_cache';
  static const String _topTransferNewsKey = 'top_transfer_news_cache';
  static const String _leagueNewsKey = 'league_news_cache';
  static const String _trendingNewsKey = 'trending_news_cache';

  static const int MAX_CACHE_ITEMS = 100;
  static const Duration MAX_CACHE_AGE = Duration(minutes: 30);
  static const String CACHE_VERSION = '1.0';

  // Logging method (can be replaced with proper logging)
  void _log(String message, {bool isError = false}) {
    if (isError) {
      print('CacheManager ERROR: $message');
    } else {
      print('CacheManager: $message');
    }
  }

  // Error handling wrapper
  Future<T?> _safeExecute<T>(Future<T?> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      _log('Operation failed: $e', isError: true);
      return null;
    }
  }

  // For regular news
  Future<void> cacheNews(List<News> news) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_newsKey);

      // Implement size management
      if (box.length >= MAX_CACHE_ITEMS) {
        _trimCache(box);
      }

      // Create cache entry with metadata
      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'data': news.map((e) => e.toJson()).toList()
      };

      await box.put('latest_news', jsonEncode(cacheEntry));
      _log('Cached ${news.length} news items');
    });
  }

  Future<List<News>?> getNewsCache() async {
    return _safeExecute<List<News>>(() async {
      final box = await Hive.openBox<String>(_newsKey);
      final cachedData = box.get('latest_news');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      // Version and age validation
      if (decodedCache['version'] != CACHE_VERSION) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return (decodedCache['data'] as List)
          .map((e) => News.fromJson(e))
          .toList();
    });
  }

  // For ForYou news
  Future<void> cacheForYouNews(ForYouNewsResponse response) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_forYouKey);

      // Implement size management
      if (box.length >= MAX_CACHE_ITEMS) {
        _trimCache(box);
      }

      // Create comprehensive cache entry
      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'teamNews': jsonEncode(response.teamNews),
        'playerNews': jsonEncode(response.playerNews),
        'teamNames': jsonEncode(response.teamNames),
        'playerNames': jsonEncode(response.playerNames),
        'teamLogos': jsonEncode(response.teamLogos),
        'playerImages': jsonEncode(response.playerImages),
      };

      // Store entire cache entry
      await box.put('for_you_news', jsonEncode(cacheEntry));
      _log('Cached ForYou news');
    });
  }

  Future<ForYouNewsResponse?> getForYouNewsCache() async {
    return _safeExecute<ForYouNewsResponse>(() async {
      final box = await Hive.openBox<String>(_forYouKey);
      final cachedData = box.get('for_you_news');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      // Version validation
      if (decodedCache['version'] != CACHE_VERSION) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return ForYouNewsResponse(
        teamNews:
            Map<String, List<News>>.from(jsonDecode(decodedCache['teamNews'])),
        playerNews: Map<String, List<News>>.from(
            jsonDecode(decodedCache['playerNews'])),
        teamNames:
            Map<String, String>.from(jsonDecode(decodedCache['teamNames'])),
        playerNames:
            Map<String, String>.from(jsonDecode(decodedCache['playerNames'])),
        teamLogos:
            Map<String, String>.from(jsonDecode(decodedCache['teamLogos'])),
        playerImages:
            Map<String, String>.from(jsonDecode(decodedCache['playerImages'])),
      );
    });
  }

  // Cache size management
  void _trimCache(Box box) {
    while (box.length >= MAX_CACHE_ITEMS) {
      box.deleteAt(0);
    }
    _log('Cache trimmed');
  }

  // Optional: Clear entire cache
  Future<void> clearCache(String cacheKey) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(cacheKey);
      await box.clear();
      _log('Cache cleared: $cacheKey');
    });
  }

  // Transfer News Caching
  Future<void> cacheTransferNews(List<News> transferNews) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_transferNewsKey);

      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'data': transferNews.map((e) => e.toJson()).toList()
      };

      await box.put('latest_transfer_news', jsonEncode(cacheEntry));
      _log('Cached ${transferNews.length} transfer news items');
    });
  }

  Future<List<News>?> getTransferNewsCache() async {
    return _safeExecute<List<News>>(() async {
      final box = await Hive.openBox<String>(_transferNewsKey);
      final cachedData = box.get('latest_transfer_news');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      if (decodedCache['version'] != CACHE_VERSION) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return (decodedCache['data'] as List)
          .map((e) => News.fromJson(e))
          .toList();
    });
  }

  // Top Transfer News Caching
  Future<void> cacheTopTransferNews(List<TransferModel> topTransferNews) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_topTransferNewsKey);

      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'data': topTransferNews.map((e) => e.toJson()).toList()
      };

      await box.put('latest_top_transfer_news', jsonEncode(cacheEntry));
      _log('Cached ${topTransferNews.length} top transfer news items');
    });
  }

  Future<List<TransferModel>?> getTopTransferNewsCache() async {
    return _safeExecute<List<TransferModel>>(() async {
      final box = await Hive.openBox<String>(_topTransferNewsKey);
      final cachedData = box.get('latest_top_transfer_news');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      if (decodedCache['version'] != CACHE_VERSION) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return (decodedCache['data'] as List)
          .map((e) => TransferModel.fromJson(e))
          .toList();
    });
  }

  // League News Caching
  Future<void> cacheLeagueNews(List<News> response, int leagueId) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_leagueNewsKey);

      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'leagueId': leagueId.toString(),
        'data': response.map((e) => e.toJson()).toList()
      };

      await box.put('league_news_$leagueId', jsonEncode(cacheEntry));
      _log('Cached ${response.length} league news items for league $leagueId');
    });
  }

  Future<List<News>?> getLeagueNewsCache(int leagueId) async {
    return _safeExecute<List<News>>(() async {
      final box = await Hive.openBox<String>(_leagueNewsKey);
      final cachedData = box.get('league_news_$leagueId');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      if (decodedCache['version'] != CACHE_VERSION ||
          decodedCache['leagueId'] != leagueId.toString()) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return (decodedCache['data'] as List)
          .map((e) => News.fromJson(e))
          .toList();
    });
  }

  // Trending News Caching (already partially implemented)
  Future<void> cacheTrendingNews(List<News> trendingNews) async {
    return _safeExecute<void>(() async {
      final box = await Hive.openBox<String>(_trendingNewsKey);

      final cacheEntry = {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'data': trendingNews.map((e) => e.toJson()).toList()
      };

      await box.put('latest_trending_news', jsonEncode(cacheEntry));
      _log('Cached ${trendingNews.length} trending news items');
    });
  }

  Future<List<News>?> getTrendingNewsCache() async {
    return _safeExecute<List<News>>(() async {
      final box = await Hive.openBox<String>(_trendingNewsKey);
      final cachedData = box.get('latest_trending_news');

      if (cachedData == null) return null;

      final decodedCache = jsonDecode(cachedData);

      if (decodedCache['version'] != CACHE_VERSION) {
        await box.clear();
        return null;
      }

      final cacheTime = DateTime.parse(decodedCache['timestamp']);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge > MAX_CACHE_AGE) {
        await box.clear();
        return null;
      }

      return (decodedCache['data'] as List)
          .map((e) => News.fromJson(e))
          .toList();
    });
  }

  // Similar methods for Top Transfer, Trending, and League News
}
