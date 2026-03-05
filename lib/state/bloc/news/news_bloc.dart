import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:blogapp/models/news.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import 'package:blogapp/data/repositories/news_repository.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'news_cache_manager.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  // ── Dependencies ─────────────────────────────────────────────────────────
  final String _url = BaseUrl().url;
  final NewsRepository _api = NewsRepository();

  /// Single shared cache manager instance (singleton under the hood too,
  /// but holding the reference here avoids even the factory call overhead).
  final _cache = NewsCacheManager();

  NewsBloc() : super(NewsState()) {
    // Main news
    on<NewsRequested>(_handleNewsRequested);
    on<RefreshRequested>(_handleRefreshRequested);
    on<LoadNextPage>(_handleLoadNextPage);

    // Trending news
    on<TrendingNewsRequested>(_handleTrendingNewsRequested);
    on<TrendingNewsRefreshRequested>(_handleTrendingNewsRefreshRequested);
    on<TrendingNewsLoadNextPage>(_handleLoadTrendingNextPage);

    // Transfer news
    on<TransferNewsRequested>(_handletansferNewsPage);
    on<TransferLoadnextNewsRequested>(_handleLoadNextTransfernewsPage);
    on<TransferNewsRefreshRequested>(_handleTransferNewsRefreshRequested);

    // Top transfers
    on<TopTransferRequested>(_handleTopTransferRequested);
    on<TopLoadNextTransferPage>(_handleLoadNextTopTransferPage);

    // For You
    on<ForYouNewsRequested>(_handleForYouNewsRequested);
    on<ForYouLoadNextPage>(_handleLoadNextForYouPage);
    on<ForYouRefreshRequested>(_handleForYouRefreshRequested);

    // League news
    on<LeagueNewsRequested>(_handleLeagueNewsRequested);
    on<LeagueNewsNextPageRequested>(_handleLeaguesLoadNextPage);

    // Team news
    on<TeamNewsRequested>(_handleTeamNewsRequested);
    on<TeamNewsNextPageRequested>(_handleTeamNewsNextPageRequested);

    // Player news
    on<PlayerNewsRequested>(_handlePlayerNewsRequested);
    on<PlayerNewsNextPageRequested>(_handlePlayerNewsNextPageRequested);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ForYouNewsResponse _withPlayerImages(ForYouNewsResponse response) {
    final images = Map<String, String>.from(response.playerImages);
    for (final id in response.playerNews.keys) {
      images.putIfAbsent(
        id,
        () => 'https://media.api-sports.io/football/players/$id.png',
      );
    }
    return ForYouNewsResponse(
      items: response.items,
      teamNews: response.teamNews,
      playerNews: response.playerNews,
      teamNames: response.teamNames,
      playerNames: response.playerNames,
      teamLogos: response.teamLogos,
      playerImages: images,
    );
  }

  List<News> _mergeForYouNews(List<News> existing, List<News> incoming) {
    if (existing.isEmpty) return List<News>.from(incoming);
    final seen = <String>{};
    final result = <News>[];
    for (final item in [...existing, ...incoming]) {
      final id = item.id;
      if (id.isEmpty || seen.add(id)) result.add(item);
    }
    return result;
  }

  // ===================== MAIN NEWS =============================================

  Future<void> _handleNewsRequested(
      NewsRequested event, Emitter<NewsState> emit) async {
    // 1. Show cache immediately if available (stale-while-revalidate)
    final cached = await _cache.getNewsCache();
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        news: cached,
        newsStatus: NewsRequest.requestSuccess,
        currentPage: 0,
        isNewsLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        newsStatus: NewsRequest.requestInProgress,
        currentPage: 0,
        isNewsLastPage: false,
      ));
    }

    // 2. Fetch fresh data in the background
    try {
      final fresh = await _api.getnews(
          lang: event.language, page: 0, queryUrl: '$_url/news');

      if (fresh.isNotEmpty) {
        await _cache.cacheNews(fresh);
        emit(state.copyWith(
          news: fresh,
          newsStatus: NewsRequest.requestSuccess,
          counter: 0,
          currentPage: 0,
          isNewsLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          newsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          newsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
      }
    }
  }

  Future<void> _handleLoadNextPage(
      LoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isNextPageLoading || state.isNewsLastPage) return;

    emit(state.copyWith(isNextPageLoading: true));
    try {
      final nextPage = await _api.getnews(
          page: state.currentPage + 1,
          lang: event.language,
          queryUrl: '$_url/news');

      if (nextPage.isEmpty) {
        emit(state.copyWith(isNextPageLoading: false, isNewsLastPage: true));
        return;
      }

      emit(state.copyWith(
        news: [...state.news, ...nextPage],
        isNextPageLoading: false,
        isNewsLastPage: false,
        currentPage: state.currentPage + 1,
      ));
    } catch (_) {
      emit(state.copyWith(isNextPageLoading: false));
    }
  }

  Future<void> _handleRefreshRequested(
      RefreshRequested event, Emitter<NewsState> emit) async {
    emit(state.copyWith(
      newsStatus: NewsRequest.requestInProgress,
      newsRefreshing: true,
      news: state.news,
      currentPage: 0,
      isNewsLastPage: false,
    ));

    try {
      final fresh = await _api.getnews(
          page: 0, lang: event.language, queryUrl: '$_url/news');

      if (fresh.isNotEmpty) {
        await _cache.cacheNews(fresh);
        emit(state.copyWith(
          news: fresh,
          newsStatus: NewsRequest.requestSuccess,
          counter: 0,
          currentPage: 0,
          newsRefreshing: false,
          isNewsLastPage: false,
        ));
      } else {
        final fallback = await _cache.getNewsCache();
        if (fallback != null && fallback.isNotEmpty) {
          emit(state.copyWith(
            news: fallback,
            newsStatus: NewsRequest.requestSuccess,
            newsRefreshing: false,
            currentPage: 0,
            isNewsLastPage: false,
          ));
        } else {
          emit(state.copyWith(
            newsStatus: NewsRequest.requestFailure,
            newsRefreshing: false,
            counter: state.counter + 1,
          ));
        }
      }
    } catch (_) {
      final fallback = await _cache.getNewsCache();
      if (fallback != null && fallback.isNotEmpty) {
        emit(state.copyWith(
          news: fallback,
          newsStatus: NewsRequest.requestSuccess,
          newsRefreshing: false,
          currentPage: 0,
          isNewsLastPage: false,
        ));
      } else {
        emit(state.copyWith(
          newsStatus: NewsRequest.requestFailure,
          newsRefreshing: false,
          counter: state.counter + 1,
        ));
      }
    }
  }

  // ===================== TRANSFER NEWS =========================================

  Future<void> _handletansferNewsPage(
      TransferNewsRequested event, Emitter<NewsState> emit) async {
    // Stale-while-revalidate
    final cached = await _cache.getTransferNewsCache();
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        transfernews: cached,
        transfernewsStatus: NewsRequest.requestSuccess,
        counter: 0,
        transferCurrentPage: 0,
        isTransferLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        transfernewsStatus: NewsRequest.requestInProgress,
        transferCurrentPage: 0,
        isTransferLastPage: false,
      ));
    }

    try {
      final fresh = await _api.getnews(
          lang: event.language, page: 0, queryUrl: '$_url/transfernews');

      if (fresh.isNotEmpty) {
        await _cache.cacheTransferNews(fresh);
        emit(state.copyWith(
          transfernews: fresh,
          transfernewsStatus: NewsRequest.requestSuccess,
          counter: 0,
          transferCurrentPage: 0,
          isTransferLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          transfernewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          transfernewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
      }
    }
  }

  Future<void> _handleLoadNextTransfernewsPage(
      TransferLoadnextNewsRequested event, Emitter<NewsState> emit) async {
    if (state.isTransferNextPageLoading || state.isTransferLastPage) return;

    emit(state.copyWith(isTransferNextPageLoading: true));
    try {
      final nextPage = await _api.getnews(
          page: state.transferCurrentPage + 1,
          lang: event.language,
          queryUrl: '$_url/transfernews');

      if (nextPage.isEmpty) {
        emit(state.copyWith(
            isTransferNextPageLoading: false, isTransferLastPage: true));
        return;
      }

      emit(state.copyWith(
        transfernews: [...state.transfernews, ...nextPage],
        isTransferNextPageLoading: false,
        isTransferLastPage: false,
        transferCurrentPage: state.transferCurrentPage + 1,
      ));
    } catch (_) {
      emit(state.copyWith(isTransferNextPageLoading: false));
    }
  }

  Future<void> _handleTransferNewsRefreshRequested(
      TransferNewsRefreshRequested event, Emitter<NewsState> emit) async {
    emit(state.copyWith(
      transfernewsStatus: NewsRequest.requestInProgress,
      counter: 0,
      transferCurrentPage: 0,
      transferNewsRefreshing: true,
      isTransferLastPage: false,
    ));

    try {
      final fresh = await _api.getnews(
          lang: event.language, page: 0, queryUrl: '$_url/transfernews');

      if (fresh.isNotEmpty) {
        await _cache.cacheTransferNews(fresh);
        emit(state.copyWith(
          transfernews: fresh,
          transfernewsStatus: NewsRequest.requestSuccess,
          counter: 0,
          transferNewsRefreshing: false,
          isTransferLastPage: false,
        ));
      } else {
        final fallback = await _cache.getTransferNewsCache();
        if (fallback != null && fallback.isNotEmpty) {
          emit(state.copyWith(
            transfernews: fallback,
            transfernewsStatus: NewsRequest.requestSuccess,
            counter: 0,
            transferNewsRefreshing: false,
            isTransferLastPage: false,
          ));
        } else {
          emit(state.copyWith(
            transfernewsStatus: NewsRequest.requestFailure,
            counter: state.counter + 1,
            transferNewsRefreshing: false,
          ));
        }
      }
    } catch (_) {
      final fallback = await _cache.getTransferNewsCache();
      if (fallback != null && fallback.isNotEmpty) {
        emit(state.copyWith(
          transfernews: fallback,
          transfernewsStatus: NewsRequest.requestSuccess,
          counter: 0,
          transferNewsRefreshing: false,
          isTransferLastPage: false,
        ));
      } else {
        emit(state.copyWith(
          transfernewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
          transferNewsRefreshing: false,
        ));
      }
    }
  }

  // ===================== TOP TRANSFER ==========================================

  Future<void> _handleTopTransferRequested(
      TopTransferRequested event, Emitter<NewsState> emit) async {
    // Show cache first
    final cached = await _cache.getTopTransferNewsCache();
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        topTransfernewsStatus: NewsRequest.requestSuccess,
        topTransferNews: cached,
        counter: 0,
        topTransferCurrentPage: 0,
        isTopTransferLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        topTransfernewsStatus: NewsRequest.requestInProgress,
        topTransferCurrentPage: 0,
        isTopTransferLastPage: false,
      ));
    }

    try {
      final response =
          await http.get(Uri.parse('$_url/api/transfer?pageNumber=0'));

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = parsedData['response'] as List<dynamic>;

        final lists = result
            .where((item) => item != null)
            .map((item) => TransferModel.fromJson(item))
            .toList();

        if (lists.isNotEmpty) {
          await _cache.cacheTopTransferNews(lists);
          emit(state.copyWith(
            topTransfernewsStatus: NewsRequest.requestSuccess,
            topTransferNews: lists,
            counter: 0,
            topTransferCurrentPage: 0,
            isTopTransferLastPage: false,
          ));
        } else if (cached == null || cached.isEmpty) {
          emit(state.copyWith(
              topTransfernewsStatus: NewsRequest.requestFailure));
        }
      } else {
        throw Exception('Top transfer request failed: ${response.statusCode}');
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(topTransfernewsStatus: NewsRequest.requestFailure));
      }
    }
  }

  Future<void> _handleLoadNextTopTransferPage(
      TopLoadNextTransferPage event, Emitter<NewsState> emit) async {
    if (state.isTopTransferNextPageLoading || state.isTopTransferLastPage) {
      return;
    }

    emit(state.copyWith(isTopTransferNextPageLoading: true));
    try {
      final response = await http.get(Uri.parse(
          '$_url/api/transfer?pageNumber=${state.topTransferCurrentPage + 1}'));

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = parsedData['response'] as List<dynamic>;

        if (result.isEmpty) {
          emit(state.copyWith(
              isTopTransferNextPageLoading: false,
              isTopTransferLastPage: true));
          return;
        }

        final lists = result.map((item) => TransferModel.fromJson(item)).toList();
        emit(state.copyWith(
          topTransfernewsStatus: NewsRequest.requestSuccess,
          topTransferNews: [...state.topTransferNews, ...lists],
          isTopTransferNextPageLoading: false,
          isTopTransferLastPage: false,
          topTransferCurrentPage: state.topTransferCurrentPage + 1,
        ));
      } else {
        emit(state.copyWith(isTopTransferNextPageLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(isTopTransferNextPageLoading: false));
    }
  }

  // ===================== FOR YOU ================================================

  Future<void> _handleForYouNewsRequested(
    ForYouNewsRequested event,
    Emitter<NewsState> emit,
  ) async {
    // Show cache first
    final cached = await _cache.getForYouNewsCache();
    if (cached != null) {
      emit(state.copyWith(
        forYouTeamNews: cached.teamNews,
        forYouPlayerNews: cached.playerNews,
        forYouNews: cached.items,
        teamNames: cached.teamNames,
        playerNames: cached.playerNames,
        teamLogos: cached.teamLogos,
        playerImages: cached.playerImages,
        forYouNewsStatus: NewsRequest.requestSuccess,
        forYouCurrentPage: 0,
        isForYouLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        forYouNewsStatus: NewsRequest.requestInProgress,
        forYouCurrentPage: 0,
        isForYouLastPage: false,
      ));
    }

    try {
      final fresh = _withPlayerImages(
          await _api.getForYouNews(lang: event.language, page: 0));

      await _cache.cacheForYouNews(fresh);

      emit(state.copyWith(
        forYouTeamNews: fresh.teamNews,
        forYouPlayerNews: fresh.playerNews,
        forYouNews: fresh.items,
        teamNames: fresh.teamNames,
        playerNames: fresh.playerNames,
        teamLogos: fresh.teamLogos,
        playerImages: fresh.playerImages,
        forYouNewsStatus: NewsRequest.requestSuccess,
        forYouCurrentPage: 0,
        isForYouLastPage: false,
      ));
    } catch (_) {
      if (cached == null) {
        emit(state.copyWith(
          forYouNewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
      }
    }
  }

  Future<void> _handleLoadNextForYouPage(
      ForYouLoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isForYouNextPageLoading || state.isForYouLastPage) return;

    emit(state.copyWith(isForYouNextPageLoading: true));
    try {
      final response = _withPlayerImages(await _api.getForYouNews(
        lang: event.language,
        page: state.forYouCurrentPage + 1,
      ));

      if (response.items.isEmpty) {
        emit(state.copyWith(
            isForYouNextPageLoading: false, isForYouLastPage: true));
        return;
      }

      emit(state.copyWith(
        forYouNews: _mergeForYouNews(state.forYouNews, response.items),
        forYouTeamNews: response.teamNews,
        forYouPlayerNews: response.playerNews,
        teamNames: response.teamNames.isEmpty
            ? state.teamNames
            : {...state.teamNames, ...response.teamNames},
        playerNames: response.playerNames.isEmpty
            ? state.playerNames
            : {...state.playerNames, ...response.playerNames},
        playerImages: response.playerImages.isEmpty
            ? state.playerImages
            : {...state.playerImages, ...response.playerImages},
        isForYouNextPageLoading: false,
        forYouCurrentPage: state.forYouCurrentPage + 1,
        isForYouLastPage: false,
      ));
    } catch (_) {
      emit(state.copyWith(isForYouNextPageLoading: false));
    }
  }

  Future<void> _handleForYouRefreshRequested(
    ForYouRefreshRequested event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(
      forYouNewsStatus: NewsRequest.requestInProgress,
      forYouNewsRefreshing: true,
      forYouCurrentPage: 0,
      isForYouLastPage: false,
    ));

    try {
      final fresh = _withPlayerImages(
          await _api.getForYouNews(lang: event.language, page: 0));

      await _cache.cacheForYouNews(fresh);

      emit(state.copyWith(
        forYouTeamNews: fresh.teamNews,
        forYouPlayerNews: fresh.playerNews,
        forYouNews: fresh.items,
        teamNames: fresh.teamNames,
        playerNames: fresh.playerNames,
        teamLogos: fresh.teamLogos,
        playerImages: fresh.playerImages,
        forYouNewsStatus: NewsRequest.requestSuccess,
        forYouNewsRefreshing: false,
        counter: 0,
        forYouCurrentPage: 0,
        isForYouLastPage: false,
      ));
    } catch (_) {
      final fallback = await _cache.getForYouNewsCache();
      if (fallback != null) {
        emit(state.copyWith(
          forYouTeamNews: fallback.teamNews,
          forYouPlayerNews: fallback.playerNews,
          forYouNews: fallback.items,
          teamNames: fallback.teamNames,
          playerNames: fallback.playerNames,
          teamLogos: fallback.teamLogos,
          playerImages: fallback.playerImages,
          forYouNewsStatus: NewsRequest.requestSuccess,
          forYouNewsRefreshing: false,
          forYouCurrentPage: 0,
          isForYouLastPage: false,
        ));
      } else {
        emit(state.copyWith(
          forYouNewsStatus: NewsRequest.requestFailure,
          forYouNewsRefreshing: false,
          forYouCurrentPage: 0,
          isForYouLastPage: false,
        ));
      }
    }
  }

  // ===================== LEAGUE NEWS ===========================================

  Future<void> _handleLeagueNewsRequested(
      LeagueNewsRequested event, Emitter<NewsState> emit) async {
    // Show cache first
    final cached = await _cache.getLeagueNewsCache(event.leagueName);
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        leagueNews: cached,
        leagueNewsStatus: NewsRequest.requestSuccess,
        leaguesCurrentPage: 0,
        isLeagueLastPage: false,
        isLeaguesNextPageLoading: false,
      ));
    } else {
      emit(state.copyWith(
        leagueNewsStatus: NewsRequest.requestInProgress,
        leaguesCurrentPage: 0,
        isLeagueLastPage: false,
        isLeaguesNextPageLoading: false,
      ));
    }

    try {
      final fresh = await _api.getLeagueNews(
        lang: event.language,
        page: 0,
        leagueName: event.leagueName,
      );

      if (fresh.isNotEmpty) {
        await _cache.cacheLeagueNews(fresh, event.leagueName);
        emit(state.copyWith(
          leagueNews: fresh,
          leagueNewsStatus: NewsRequest.requestSuccess,
          leaguesCurrentPage: 0,
          isLeagueLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(leagueNewsStatus: NewsRequest.requestFailure));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(leagueNewsStatus: NewsRequest.requestFailure));
      }
    }
  }

  Future<void> _handleLeaguesLoadNextPage(
      LeagueNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isLeaguesNextPageLoading || state.isLeagueLastPage) return;

    emit(state.copyWith(isLeaguesNextPageLoading: true));
    try {
      final nextPage = await _api.getLeagueNews(
        page: state.leaguesCurrentPage + 1,
        lang: event.language,
        leagueName: event.leagueName,
      );

      if (nextPage.isEmpty) {
        emit(state.copyWith(
            isLeaguesNextPageLoading: false, isLeagueLastPage: true));
        return;
      }

      emit(state.copyWith(
        leagueNews: [...state.leagueNews, ...nextPage],
        isLeaguesNextPageLoading: false,
        isLeagueLastPage: false,
        leaguesCurrentPage: state.leaguesCurrentPage + 1,
      ));
    } catch (_) {
      emit(state.copyWith(isLeaguesNextPageLoading: false));
    }
  }

  // ===================== TEAM NEWS =============================================

  Future<void> _handleTeamNewsRequested(
      TeamNewsRequested event, Emitter<NewsState> emit) async {
    // Show cache first
    final cached = await _cache.getTeamNewsCache(event.teamName);
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        teamNews: cached,
        teamNewsStatus: NewsRequest.requestSuccess,
        teamCurrentPage: 1,
        isTeamLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        teamNewsStatus: NewsRequest.requestInProgress,
        teamCurrentPage: 0,
        isTeamLastPage: false,
        teamNews: const [],
      ));
    }

    try {
      final fresh = await _api.getTeamNews(
        lang: event.language,
        page: 0,
        teamName: event.teamName,
      );

      if (fresh.isNotEmpty) {
        await _cache.cacheTeamNews(fresh, event.teamName);
        emit(state.copyWith(
          teamNews: fresh,
          teamNewsStatus: NewsRequest.requestSuccess,
          teamCurrentPage: 1,
          isTeamLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          teamNewsStatus: NewsRequest.requestFailure,
          isTeamLastPage: true,
        ));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(teamNewsStatus: NewsRequest.requestFailure));
      }
    }
  }

  Future<void> _handleTeamNewsNextPageRequested(
      TeamNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isTeamNextPageLoading || state.isTeamLastPage) return;

    emit(state.copyWith(isTeamNextPageLoading: true));
    try {
      final nextPage = await _api.getTeamNews(
        lang: event.language,
        page: state.teamCurrentPage,
        teamName: event.teamName,
      );

      if (nextPage.isEmpty) {
        emit(state.copyWith(
            isTeamNextPageLoading: false, isTeamLastPage: true));
        return;
      }

      emit(state.copyWith(
        teamNews: [...state.teamNews, ...nextPage],
        isTeamNextPageLoading: false,
        teamCurrentPage: state.teamCurrentPage + 1,
        isTeamLastPage: false,
      ));
    } catch (_) {
      emit(state.copyWith(isTeamNextPageLoading: false));
    }
  }

  // ===================== PLAYER NEWS ===========================================

  Future<void> _handlePlayerNewsRequested(
      PlayerNewsRequested event, Emitter<NewsState> emit) async {
    // Show cache first
    final cached = await _cache.getPlayerNewsCache(event.playerName);
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        playerNews: cached,
        playerNewsStatus: NewsRequest.requestSuccess,
        playerCurrentPage: 1,
        isPlayerLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        playerNewsStatus: NewsRequest.requestInProgress,
        playerCurrentPage: 0,
        isPlayerLastPage: false,
        playerNews: const [],
      ));
    }

    try {
      final fresh = await _api.getPlayerNews(
        lang: event.language,
        page: 0,
        playerName: event.playerName,
      );

      if (fresh.isNotEmpty) {
        await _cache.cachePlayerNews(fresh, event.playerName);
        emit(state.copyWith(
          playerNews: fresh,
          playerNewsStatus: NewsRequest.requestSuccess,
          playerCurrentPage: 1,
          isPlayerLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          playerNewsStatus: NewsRequest.requestFailure,
          isPlayerLastPage: true,
        ));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(playerNewsStatus: NewsRequest.requestFailure));
      }
    }
  }

  Future<void> _handlePlayerNewsNextPageRequested(
      PlayerNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isPlayerNextPageLoading || state.isPlayerLastPage) return;

    emit(state.copyWith(isPlayerNextPageLoading: true));
    try {
      final nextPage = await _api.getPlayerNews(
        lang: event.language,
        page: state.playerCurrentPage,
        playerName: event.playerName,
      );

      if (nextPage.isEmpty) {
        emit(state.copyWith(
            isPlayerNextPageLoading: false, isPlayerLastPage: true));
        return;
      }

      emit(state.copyWith(
        playerNews: [...state.playerNews, ...nextPage],
        isPlayerNextPageLoading: false,
        playerCurrentPage: state.playerCurrentPage + 1,
        isPlayerLastPage: false,
      ));
    } catch (_) {
      emit(state.copyWith(isPlayerNextPageLoading: false));
    }
  }

  // ===================== TRENDING NEWS =========================================

  Future<void> _handleTrendingNewsRequested(
      TrendingNewsRequested event, Emitter<NewsState> emit) async {
    // Show cache first
    final cached = await _cache.getTrendingNewsCache();
    if (cached != null && cached.isNotEmpty) {
      emit(state.copyWith(
        trendingNews: cached,
        trendingNewsStatus: NewsRequest.requestSuccess,
        trendingCurrentPage: 1,
        isTrendingLastPage: false,
      ));
    } else {
      emit(state.copyWith(
        trendingNewsStatus: NewsRequest.requestInProgress,
        trendingCurrentPage: 0,
        isTrendingLastPage: false,
      ));
    }

    try {
      final fresh = await _api.getTrendingNews(
        lang: event.language,
        page: 0,
      );

      if (fresh.isNotEmpty) {
        await _cache.cacheTrendingNews(fresh);
        emit(state.copyWith(
          trendingNews: fresh,
          trendingNewsStatus: NewsRequest.requestSuccess,
          trendingCurrentPage: 1,
          isTrendingLastPage: false,
        ));
      } else if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          trendingNewsStatus: NewsRequest.requestFailure,
          trendingCurrentPage: state.trendingCurrentPage,
          isTrendingLastPage: false,
        ));
      }
    } catch (_) {
      if (cached == null || cached.isEmpty) {
        emit(state.copyWith(
          trendingNewsStatus: NewsRequest.requestFailure,
          trendingCurrentPage: state.trendingCurrentPage,
          isTrendingLastPage: false,
        ));
      }
    }
  }

  Future<void> _handleLoadTrendingNextPage(
      TrendingNewsLoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isTrendingNextPageLoading || state.isTrendingLastPage) return;

    emit(state.copyWith(isTrendingNextPageLoading: true));
    try {
      final response = await _api.getTrendingNews(
        lang: event.language,
        page: state.trendingCurrentPage,
      );

      emit(state.copyWith(
        trendingNews: [...state.trendingNews, ...response],
        trendingNewsStatus: NewsRequest.requestSuccess,
        isTrendingNextPageLoading: false,
        trendingCurrentPage: state.trendingCurrentPage + 1,
        isTrendingLastPage: response.isEmpty,
      ));
    } catch (_) {
      emit(state.copyWith(
        trendingNewsStatus: NewsRequest.requestFailure,
        isTrendingNextPageLoading: false,
      ));
    }
  }

  Future<void> _handleTrendingNewsRefreshRequested(
      TrendingNewsRefreshRequested event, Emitter<NewsState> emit) async {
    emit(state.copyWith(
      trendingNewsStatus: NewsRequest.requestInProgress,
      trendingNewsRefreshing: true,
      trendingCurrentPage: 0,
      isTrendingLastPage: false,
    ));

    try {
      final fresh = await _api.getTrendingNews(lang: event.language, page: 0);

      if (fresh.isNotEmpty) {
        await _cache.cacheTrendingNews(fresh);
        emit(state.copyWith(
          trendingNews: fresh,
          trendingNewsStatus: NewsRequest.requestSuccess,
          trendingNewsRefreshing: false,
          trendingCurrentPage: 1,
          isTrendingLastPage: false,
        ));
      } else {
        final fallback = await _cache.getTrendingNewsCache();
        if (fallback != null && fallback.isNotEmpty) {
          emit(state.copyWith(
            trendingNews: fallback,
            trendingNewsStatus: NewsRequest.requestSuccess,
            trendingNewsRefreshing: false,
            trendingCurrentPage: 1,
            isTrendingLastPage: false,
          ));
        } else {
          emit(state.copyWith(
            trendingNewsStatus: NewsRequest.requestFailure,
            trendingNewsRefreshing: false,
            isTrendingLastPage: false,
          ));
        }
      }
    } catch (_) {
      final fallback = await _cache.getTrendingNewsCache();
      if (fallback != null && fallback.isNotEmpty) {
        emit(state.copyWith(
          trendingNews: fallback,
          trendingNewsStatus: NewsRequest.requestSuccess,
          trendingNewsRefreshing: false,
          trendingCurrentPage: 1,
          isTrendingLastPage: false,
        ));
      } else {
        emit(state.copyWith(
          trendingNewsStatus: NewsRequest.requestFailure,
          trendingNewsRefreshing: false,
          isTrendingLastPage: false,
        ));
      }
    }
  }
}
