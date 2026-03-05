import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:blogapp/models/news.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import 'package:blogapp/data/repositories/news_repository.dart';

class NewsCacheManager {
  // ── Singleton ──────────────────────────────────────────────────────────────
  NewsCacheManager._internal();
  static final NewsCacheManager instance = NewsCacheManager._internal();
  factory NewsCacheManager() => instance;

  // ── Box registry ──────────────────────────────────────────────────────────
  static final Map<String, Box<String>> _boxCache = {};

  // ── Box name constants ─────────────────────────────────────────────────────
  static const String _newsKey = 'news_cache';
  static const String _forYouKey = 'for_you_news_cache';
  static const String _transferNewsKey = 'transfer_news_cache';
  static const String _topTransferNewsKey = 'top_transfer_news_cache';
  static const String _leagueNewsKey = 'league_news_cache';
  static const String _trendingNewsKey = 'trending_news_cache';
  static const String _teamNewsKey = 'team_news_cache';
  static const String _playerNewsKey = 'player_news_cache';

  // ── Cache version ──────────────────────────────────────────────────────────
  static const String CACHE_VERSION = '1.1';

  // ── Per-type TTLs ──────────────────────────────────────────────────────────
  static const Map<String, Duration> _cacheTTLs = {
    _newsKey: Duration(minutes: 30),
    _trendingNewsKey: Duration(minutes: 15),
    _transferNewsKey: Duration(hours: 1),
    _topTransferNewsKey: Duration(hours: 2),
    _leagueNewsKey: Duration(hours: 1),
    _forYouKey: Duration(minutes: 45),
    _teamNewsKey: Duration(hours: 1),
    _playerNewsKey: Duration(hours: 1),
  };

  Duration _ttlFor(String boxName) =>
      _cacheTTLs[boxName] ?? const Duration(minutes: 30);

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<Box<String>> _openBox(String name) async {
    final cached = _boxCache[name];
    if (cached != null && cached.isOpen) return cached;
    final box = await Hive.openBox<String>(name);
    _boxCache[name] = box;
    return box;
  }

  Future<void> _invalidateEntry(Box<String> box, String key) async {
    if (box.containsKey(key)) await box.delete(key);
  }

  /// Returns decoded cache map if the entry is valid, null otherwise.
  Future<Map<String, dynamic>?> _getValidCacheEntry(
    Box<String> box,
    String key,
    String boxName,
  ) async {
    final raw = box.get(key);
    if (raw == null) return null;

    Map<String, dynamic> decoded;
    try {
      decoded = Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      await _invalidateEntry(box, key);
      return null;
    }

    if (decoded['version'] != CACHE_VERSION) {
      await _invalidateEntry(box, key);
      return null;
    }

    // For SWR (Stale-While-Revalidate), we return the data even if it's past TTL.
    // The Bloc will handle fetching fresh data in the background.
    return decoded;
  }

  Map<String, dynamic> _buildEntry(dynamic data) => {
        'version': CACHE_VERSION,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

  // ── Decoders ───────────────────────────────────────────────────────────────

  List<News> _decodeNewsList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => News.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Map<String, List<News>> _decodeNewsMap(dynamic raw) {
    if (raw is! Map) return {};
    final result = <String, List<News>>{};
    raw.forEach((k, v) {
      result[k.toString()] = v is List
          ? v
              .whereType<Map>()
              .map((item) => News.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [];
    });
    return result;
  }

  Map<String, String> _decodeStringMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
  }

  // ── Logging ────────────────────────────────────────────────────────────────

  void _log(String message, {bool isError = false}) {
    // ignore: avoid_print
    print('CacheManager${isError ? ' ERROR' : ''}: $message');
  }

  Future<T?> _safeExecute<T>(Future<T?> Function() op) async {
    try {
      return await op();
    } catch (e) {
      _log('Operation failed: $e', isError: true);
      return null;
    }
  }

  // ── Main news ──────────────────────────────────────────────────────────────

  Future<void> cacheNews(List<News> news) => _safeExecute(() async {
        final box = await _openBox(_newsKey);
        await box.put(
          'latest_news',
          jsonEncode(_buildEntry(news.map((e) => e.toJson()).toList())),
        );
        _log('Cached ${news.length} news items');
      });

  Future<List<News>?> getNewsCache() => _safeExecute(() async {
        final box = await _openBox(_newsKey);
        final entry =
            await _getValidCacheEntry(box, 'latest_news', _newsKey);
        if (entry == null) return null;
        return _decodeNewsList(entry['data']);
      });

  // ── For You news ───────────────────────────────────────────────────────────

  Future<void> cacheForYouNews(ForYouNewsResponse response) =>
      _safeExecute(() async {
        final box = await _openBox(_forYouKey);

        // Store everything as plain Dart objects — a single jsonEncode at the end.
        final entry = _buildEntry({
          'items': response.items.map((e) => e.toJson()).toList(),
          'teamNews': response.teamNews.map(
            (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
          ),
          'playerNews': response.playerNews.map(
            (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
          ),
          'teamNames': response.teamNames,
          'playerNames': response.playerNames,
          'teamLogos': response.teamLogos,
          'playerImages': response.playerImages,
        });

        await box.put('for_you_news', jsonEncode(entry));
        _log('Cached ForYou news');
      });

  Future<ForYouNewsResponse?> getForYouNewsCache() =>
      _safeExecute(() async {
        final box = await _openBox(_forYouKey);
        final entry =
            await _getValidCacheEntry(box, 'for_you_news', _forYouKey);
        if (entry == null) return null;

        final data = entry['data'] as Map<String, dynamic>? ?? {};

        final items = _decodeNewsList(data['items']);
        final teamNews = _decodeNewsMap(data['teamNews']);
        final playerNews = _decodeNewsMap(data['playerNews']);

        final mergedItems = items.isNotEmpty
            ? items
            : _mergeAndSortNews([
                ...teamNews.values.expand((l) => l),
                ...playerNews.values.expand((l) => l),
              ]);

        return ForYouNewsResponse(
          items: mergedItems,
          teamNews: teamNews,
          playerNews: playerNews,
          teamNames: _decodeStringMap(data['teamNames']),
          playerNames: _decodeStringMap(data['playerNames']),
          teamLogos: _decodeStringMap(data['teamLogos']),
          playerImages: _decodeStringMap(data['playerImages']),
        );
      });

  // ── Transfer news ──────────────────────────────────────────────────────────

  Future<void> cacheTransferNews(List<News> news) =>
      _safeExecute(() async {
        final box = await _openBox(_transferNewsKey);
        await box.put(
          'latest_transfer_news',
          jsonEncode(_buildEntry(news.map((e) => e.toJson()).toList())),
        );
        _log('Cached ${news.length} transfer news items');
      });

  Future<List<News>?> getTransferNewsCache() => _safeExecute(() async {
        final box = await _openBox(_transferNewsKey);
        final entry = await _getValidCacheEntry(
            box, 'latest_transfer_news', _transferNewsKey);
        if (entry == null) return null;
        return _decodeNewsList(entry['data']);
      });

  // ── Top transfer news ──────────────────────────────────────────────────────

  Future<void> cacheTopTransferNews(List<TransferModel> news) =>
      _safeExecute(() async {
        final box = await _openBox(_topTransferNewsKey);
        await box.put(
          'latest_top_transfer_news',
          jsonEncode(_buildEntry(news.map((e) => e.toJson()).toList())),
        );
        _log('Cached ${news.length} top transfer news items');
      });

  Future<List<TransferModel>?> getTopTransferNewsCache() =>
      _safeExecute(() async {
        final box = await _openBox(_topTransferNewsKey);
        final entry = await _getValidCacheEntry(
            box, 'latest_top_transfer_news', _topTransferNewsKey);
        if (entry == null) return null;
        final data = entry['data'];
        if (data is! List) return null;
        return data
            .whereType<Map>()
            .map((e) =>
                TransferModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  // ── League news ────────────────────────────────────────────────────────────

  Future<void> cacheLeagueNews(List<News> news, String leagueName) =>
      _safeExecute(() async {
        final box = await _openBox(_leagueNewsKey);
        final entry = _buildEntry({
          'leagueName': leagueName,
          'items': news.map((e) => e.toJson()).toList(),
        });
        await box.put('league_news_$leagueName', jsonEncode(entry));
        _log('Cached ${news.length} league news items for $leagueName');
      });

  Future<List<News>?> getLeagueNewsCache(String leagueName) =>
      _safeExecute(() async {
        final cacheKey = 'league_news_$leagueName';
        final box = await _openBox(_leagueNewsKey);
        final entry =
            await _getValidCacheEntry(box, cacheKey, _leagueNewsKey);
        if (entry == null) return null;

        final data = entry['data'] as Map<String, dynamic>? ?? {};
        if (data['leagueName'] != leagueName) {
          await _invalidateEntry(box, cacheKey);
          return null;
        }
        return _decodeNewsList(data['items']);
      });

  // ── Trending news ──────────────────────────────────────────────────────────

  Future<void> cacheTrendingNews(List<News> news) =>
      _safeExecute(() async {
        final box = await _openBox(_trendingNewsKey);
        await box.put(
          'latest_trending_news',
          jsonEncode(_buildEntry(news.map((e) => e.toJson()).toList())),
        );
        _log('Cached ${news.length} trending news items');
      });

  Future<List<News>?> getTrendingNewsCache() => _safeExecute(() async {
        final box = await _openBox(_trendingNewsKey);
        final entry = await _getValidCacheEntry(
            box, 'latest_trending_news', _trendingNewsKey);
        if (entry == null) return null;
        return _decodeNewsList(entry['data']);
      });

  // ── Team news ──────────────────────────────────────────────────────────────

  Future<void> cacheTeamNews(List<News> news, String teamName) =>
      _safeExecute(() async {
        final box = await _openBox(_teamNewsKey);
        final entry = _buildEntry({
          'teamName': teamName,
          'items': news.map((e) => e.toJson()).toList(),
        });
        await box.put('team_news_$teamName', jsonEncode(entry));
        _log('Cached ${news.length} team news items for $teamName');
      });

  Future<List<News>?> getTeamNewsCache(String teamName) =>
      _safeExecute(() async {
        final cacheKey = 'team_news_$teamName';
        final box = await _openBox(_teamNewsKey);
        final entry =
            await _getValidCacheEntry(box, cacheKey, _teamNewsKey);
        if (entry == null) return null;
        final data = entry['data'] as Map<String, dynamic>? ?? {};
        return _decodeNewsList(data['items']);
      });

  // ── Player news ────────────────────────────────────────────────────────────

  Future<void> cachePlayerNews(List<News> news, String playerName) =>
      _safeExecute(() async {
        final box = await _openBox(_playerNewsKey);
        final entry = _buildEntry({
          'playerName': playerName,
          'items': news.map((e) => e.toJson()).toList(),
        });
        await box.put('player_news_$playerName', jsonEncode(entry));
        _log('Cached ${news.length} player news items for $playerName');
      });

  Future<List<News>?> getPlayerNewsCache(String playerName) =>
      _safeExecute(() async {
        final cacheKey = 'player_news_$playerName';
        final box = await _openBox(_playerNewsKey);
        final entry =
            await _getValidCacheEntry(box, cacheKey, _playerNewsKey);
        if (entry == null) return null;
        final data = entry['data'] as Map<String, dynamic>? ?? {};
        return _decodeNewsList(data['items']);
      });

  // ── Utilities ──────────────────────────────────────────────────────────────

  List<News> _mergeAndSortNews(Iterable<News> items) {
    final deduped = <String, News>{};
    for (final n in items) {
      if (n.id.isNotEmpty) deduped[n.id] = n;
    }
    final list = deduped.values.toList();
    list.sort((a, b) {
      final dateA =
          a.publishedDate != null ? DateTime.tryParse(a.publishedDate!) : null;
      final dateB =
          b.publishedDate != null ? DateTime.tryParse(b.publishedDate!) : null;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return list;
  }

  Future<void> clearCache(String cacheKey) => _safeExecute(() async {
        final box = await _openBox(cacheKey);
        await box.clear();
        _log('Cache cleared: $cacheKey');
      });
}
