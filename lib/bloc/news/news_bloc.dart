import 'dart:convert';

import 'package:bloc/bloc.dart';
import '../../models/news.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../pages/appbar_pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import '../../repository/news_repository.dart';
import '../../util/baseUrl.dart';
import 'news_cache_manager.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
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

    // ✅ Team news
    on<TeamNewsRequested>(_handleTeamNewsRequested);
    on<TeamNewsNextPageRequested>(_handleTeamNewsNextPageRequested);

    // ✅ Player news
    on<PlayerNewsRequested>(_handlePlayerNewsRequested);
    on<PlayerNewsNextPageRequested>(_handlePlayerNewsNextPageRequested);
  }

  String url = BaseUrl().url;
  final NewsRepository api = NewsRepository();

  // ===================== MAIN NEWS =====================
  Future<void> _handleNewsRequested(
      NewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        newsStatus: NewsRequest.requestInProgress,
      ));

      final response = await api.getnews(
          lang: event.language, page: state.currentPage, queryUrl: '$url/news');

      if (response.isEmpty) {
        emit(state.copyWith(
          newsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
        ));
        return;
      }

      emit(state.copyWith(
          news: response, newsStatus: NewsRequest.requestSuccess, counter: 0));
    } catch (e) {
      emit(state.copyWith(
          newsStatus: NewsRequest.requestFailure, counter: state.counter + 1));
    }
  }

  Future<void> _handleLoadNextPage(
      LoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isNextPageLoading) return;

    emit(state.copyWith(isNextPageLoading: true));
    try {
      final nextPage = await api.getnews(
          page: state.currentPage + 1,
          lang: event.language,
          queryUrl: '$url/news');

      final updatedNews = [...state.news, ...nextPage];
      emit(state.copyWith(
          news: updatedNews,
          isNextPageLoading: false,
          isLastPage: false,
          currentPage: state.currentPage + 1));
    } catch (e) {
      emit(state.copyWith(isNextPageLoading: false));
    }
  }

  Future<void> _handleRefreshRequested(
      RefreshRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        newsStatus: NewsRequest.requestInProgress,
        newsRefreshing: true,
        news: state.news,
      ));

      final news = await api.getnews(
          page: 0, lang: event.language, queryUrl: '$url/news');

      if (news.isEmpty) {
        final cachedNews = await NewsCacheManager().getNewsCache();

        if (cachedNews != null && cachedNews.isNotEmpty) {
          emit(state.copyWith(
            news: cachedNews,
            newsStatus: NewsRequest.requestSuccess,
            newsRefreshing: false,
          ));
        } else {
          emit(state.copyWith(
            newsStatus: NewsRequest.requestFailure,
            newsRefreshing: false,
            counter: state.counter + 1,
          ));
        }
        return;
      }

      await NewsCacheManager().cacheNews(news);

      emit(state.copyWith(
        news: news,
        newsStatus: NewsRequest.requestSuccess,
        counter: 0,
        currentPage: 0,
        newsRefreshing: false,
      ));
    } catch (e) {
      final cachedNews = await NewsCacheManager().getNewsCache();

      if (cachedNews != null && cachedNews.isNotEmpty) {
        emit(state.copyWith(
          news: cachedNews,
          newsStatus: NewsRequest.requestSuccess,
          newsRefreshing: false,
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

  // ===================== TRANSFER NEWS =====================
  Future<void> _handletansferNewsPage(
      TransferNewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        forYouNewsStatus: NewsRequest.requestInProgress,
      ));

      final response = await api.getnews(
          lang: event.language,
          page: state.transferCurrentPage,
          queryUrl: '$url/transfernews');

      emit(state.copyWith(
        transfernews: response,
        transfernewsStatus: NewsRequest.requestSuccess,
        counter: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
          forYouNewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1));
    }
  }

  Future<void> _handleLoadNextTransfernewsPage(
      TransferLoadnextNewsRequested event, Emitter<NewsState> emit) async {
    if (state.isTransferNextPageLoading) return;

    emit(state.copyWith(isTransferNextPageLoading: true));

    try {
      final nextPage = await api.getnews(
          page: state.transferCurrentPage + 1,
          lang: event.language,
          queryUrl: '$url/transfernews');

      final updatedNews = [...state.transfernews, ...nextPage];

      emit(state.copyWith(
          transfernews: updatedNews,
          isTransferNextPageLoading: false,
          isLastPage: nextPage.isEmpty,
          transferCurrentPage: state.transferCurrentPage + 1));
    } catch (e) {
      emit(state.copyWith(isTransferNextPageLoading: false));
    }
  }

  Future<void> _handleTransferNewsRefreshRequested(
      TransferNewsRefreshRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
          transfernewsStatus: NewsRequest.requestInProgress,
          counter: 0,
          transferCurrentPage: 0,
          transferNewsRefreshing: true));

      final response = await api.getnews(
          lang: localLanguageNotifier.value, page: 0, queryUrl: '$url/news');

      await NewsCacheManager().cacheTransferNews(response);

      emit(state.copyWith(
          transfernews: response,
          transfernewsStatus: NewsRequest.requestSuccess,
          counter: 0,
          transferNewsRefreshing: false));
    } catch (e) {
      emit(state.copyWith(
          transfernewsStatus: NewsRequest.requestFailure,
          counter: state.counter + 1,
          transferNewsRefreshing: false));
    }
  }

  // ===================== TOP TRANSFER =====================
  Future<void> _handleTopTransferRequested(
      TopTransferRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        topTransfernewsStatus: NewsRequest.requestInProgress,
      ));
      String url = BaseUrl().url;
      final response = await http.get(Uri.parse(
          '$url/api/transfer?pageNumber=${state.topTransferCurrentPage}'));

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);

        final result = parsedData['response'] as List<dynamic>;

        List<TransferModel> lists = [];
        for (var item in result) {
          if (item != null) {
            TransferModel transferModel = TransferModel.fromJson(item);
            lists.add(transferModel);
          }
        }

        await NewsCacheManager().cacheTopTransferNews(lists);

        emit(state.copyWith(
            topTransfernewsStatus: NewsRequest.requestSuccess,
            topTransferNews: lists,
            counter: 0));
      }
    } catch (e) {
      emit(state.copyWith(
        topTransfernewsStatus: NewsRequest.requestFailure,
      ));
    }
  }

  Future<void> _handleLoadNextTopTransferPage(
      TopLoadNextTransferPage event, Emitter<NewsState> emit) async {
    if (state.isTransferNextPageLoading) return;

    emit(state.copyWith(isTopTransferNextPageLoading: true));
    try {
      String url = BaseUrl().url;

      final response = await http.get(Uri.parse(
          '$url/api/transfer?pageNumber=${state.topTransferCurrentPage + 1}'));
      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = parsedData['response'] as List<dynamic>;
        if (result.isEmpty) {
          emit(state.copyWith(isLastPage: true));
          return;
        }
        List<TransferModel> lists = [];
        for (var item in result) {
          TransferModel transferModel = TransferModel.fromJson(item);
          lists.add(transferModel);
        }
        emit(state.copyWith(
            topTransfernewsStatus: NewsRequest.requestSuccess,
            topTransferNews: [...state.topTransferNews, ...lists],
            isTopTransferNextPageLoading: false,
            isLastPage: false,
            topTransferCurrentPage: state.topTransferCurrentPage + 1));
      }
    } catch (e) {
      emit(state.copyWith(
        isTopTransferNextPageLoading: false,
      ));
    }
  }

  // ===================== FOR YOU =====================
  Future<void> _handleForYouNewsRequested(
    ForYouNewsRequested event,
    Emitter<NewsState> emit,
  ) async {
    try {
      emit(state.copyWith(
        forYouNewsStatus: NewsRequest.requestInProgress,
      ));

      final response = await api.getForYouNews(
        lang: event.language,
        page: 0,
      );

      final playerImages = response.playerNews.keys
          .fold<Map<String, String>>({}, (map, playerId) {
        map[playerId] =
            'https://media.api-sports.io/football/players/$playerId.png';
        return map;
      });

      emit(state.copyWith(
        forYouTeamNews: response.teamNews,
        forYouPlayerNews: response.playerNews,
        teamNames: response.teamNames,
        playerNames: response.playerNames,
        teamLogos: response.teamLogos,
        playerImages: playerImages,
        forYouNewsStatus: NewsRequest.requestSuccess,
      ));
    } catch (e) {
      emit(state.copyWith(
        forYouNewsStatus: NewsRequest.requestFailure,
        counter: state.counter + 1,
      ));
    }
  }

  Future<void> _handleLoadNextForYouPage(
      ForYouLoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isForYouNextPageLoading) return;

    emit(state.copyWith(isForYouNextPageLoading: true));

    try {
      final response = await api.getForYouNews(
        lang: event.language,
        page: state.forYouCurrentPage + 1,
      );

      final updatedTeamNews =
          Map<String, List<News>>.from(state.forYouTeamNews);
      final updatedPlayerNews =
          Map<String, List<News>>.from(state.forYouPlayerNews);

      response.teamNews.forEach((teamId, newsList) {
        if (updatedTeamNews.containsKey(teamId)) {
          updatedTeamNews[teamId]!.addAll(newsList);
        } else {
          updatedTeamNews[teamId] = newsList;
        }
      });

      response.playerNews.forEach((playerId, newsList) {
        if (updatedPlayerNews.containsKey(playerId)) {
          updatedPlayerNews[playerId]!.addAll(newsList);
        } else {
          updatedPlayerNews[playerId] = newsList;
        }
      });

      emit(state.copyWith(
        forYouTeamNews: updatedTeamNews,
        forYouPlayerNews: updatedPlayerNews,
        teamNames: {...state.teamNames, ...response.teamNames},
        playerNames: {...state.playerNames, ...response.playerNames},
        isForYouNextPageLoading: false,
        forYouCurrentPage: state.forYouCurrentPage + 1,
      ));
    } catch (e) {
      emit(state.copyWith(isForYouNextPageLoading: false));
    }
  }

  Future<void> _handleForYouRefreshRequested(
    ForYouRefreshRequested event,
    Emitter<NewsState> emit,
  ) async {
    try {
      emit(state.copyWith(
        forYouNewsStatus: NewsRequest.requestInProgress,
        forYouNewsRefreshing: true,
        forYouTeamNews: state.forYouTeamNews,
        forYouPlayerNews: state.forYouPlayerNews,
        teamNames: state.teamNames,
        playerNames: state.playerNames,
        teamLogos: state.teamLogos,
        playerImages: state.playerImages,
      ));

      final response = await api.getForYouNews(
        lang: event.language,
        page: 0,
      );

      await NewsCacheManager().cacheForYouNews(response);

      emit(state.copyWith(
        forYouTeamNews: response.teamNews,
        forYouPlayerNews: response.playerNews,
        teamNames: response.teamNames,
        playerNames: response.playerNames,
        teamLogos: response.teamLogos,
        playerImages: response.playerImages,
        forYouNewsStatus: NewsRequest.requestSuccess,
        forYouNewsRefreshing: false,
        counter: 0,
      ));
    } catch (e) {
      final cachedData = await NewsCacheManager().getForYouNewsCache();

      if (cachedData != null) {
        emit(state.copyWith(
          forYouTeamNews: cachedData.teamNews,
          forYouPlayerNews: cachedData.playerNews,
          teamNames: cachedData.teamNames,
          playerNames: cachedData.playerNames,
          teamLogos: cachedData.teamLogos,
          playerImages: cachedData.playerImages,
          forYouNewsStatus: NewsRequest.requestSuccess,
          forYouNewsRefreshing: false,
        ));
      } else {
        emit(state.copyWith(
          forYouNewsStatus: NewsRequest.requestFailure,
          forYouNewsRefreshing: false,
          forYouTeamNews: state.forYouTeamNews,
          forYouPlayerNews: state.forYouPlayerNews,
          teamNames: state.teamNames,
          playerNames: state.playerNames,
          teamLogos: state.teamLogos,
          playerImages: state.playerImages,
        ));
      }
    }
  }

  // ===================== LEAGUE NEWS =====================
  Future<void> _handleLeagueNewsRequested(
      LeagueNewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        leagueNewsStatus: NewsRequest.requestInProgress,
        leaguesCurrentPage: 0,
        isLastPage: false,
        isLeaguesNextPageLoading: false,
      ));

      final response = await api.getLeagueNews(
        lang: event.language,
        page: 0,
        leagueName: event.leagueName,
      );

      await NewsCacheManager().cacheLeagueNews(response, event.leagueName);

      emit(state.copyWith(
        leagueNews: response,
        leagueNewsStatus: NewsRequest.requestSuccess,
        leaguesCurrentPage: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        leagueNewsStatus: NewsRequest.requestFailure,
      ));
    }
  }

  Future<void> _handleLeaguesLoadNextPage(
      LeagueNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isLeaguesNextPageLoading) return;

    emit(state.copyWith(isLeaguesNextPageLoading: true));
    try {
      final nextPage = await api.getLeagueNews(
          page: state.leaguesCurrentPage + 1,
          lang: event.language,
          leagueName: event.leagueName);

      if (nextPage.isEmpty) {
        emit(state.copyWith(isLeaguesNextPageLoading: false, isLastPage: true));
        return;
      } else {
        final updatedNews = [...state.leagueNews, ...nextPage];
        emit(state.copyWith(
            leagueNews: updatedNews,
            isLeaguesNextPageLoading: false,
            isLastPage: false,
            leaguesCurrentPage: state.leaguesCurrentPage + 1));
      }
    } catch (e) {
      emit(state.copyWith(isLeaguesNextPageLoading: false));
    }
  }

  // ===================== TEAM NEWS =====================
  Future<void> _handleTeamNewsRequested(
      TeamNewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(teamNewsStatus: NewsRequest.requestInProgress));

      final response = await api.getTeamNews(
        lang: event.language,
        page: state.teamCurrentPage,
        teamName: event.teamName,
      );

      emit(state.copyWith(
        teamNews: response,
        teamNewsStatus: NewsRequest.requestSuccess,
        teamCurrentPage: state.teamCurrentPage + 1,
      ));
    } catch (e) {
      emit(state.copyWith(teamNewsStatus: NewsRequest.requestFailure));
    }
  }

  Future<void> _handleTeamNewsNextPageRequested(
      TeamNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isTeamNextPageLoading) return;

    emit(state.copyWith(isTeamNextPageLoading: true));
    try {
      final nextPage = await api.getTeamNews(
        lang: event.language,
        page: state.teamCurrentPage,
        teamName: event.teamName,
      );

      if (nextPage.isEmpty) {
        emit(state.copyWith(
          isTeamNextPageLoading: false,
          isLastPage: true,
        ));
        return;
      }

      emit(state.copyWith(
        teamNews: [...state.teamNews, ...nextPage],
        isTeamNextPageLoading: false,
        teamCurrentPage: state.teamCurrentPage + 1,
      ));
    } catch (e) {
      emit(state.copyWith(isTeamNextPageLoading: false));
    }
  }

  // ===================== PLAYER NEWS =====================
  Future<void> _handlePlayerNewsRequested(
      PlayerNewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(playerNewsStatus: NewsRequest.requestInProgress));

      final response = await api.getPlayerNews(
        lang: event.language,
        page: state.playerCurrentPage,
        playerName: event.playerName,
      );

      emit(state.copyWith(
        playerNews: response,
        playerNewsStatus: NewsRequest.requestSuccess,
        playerCurrentPage: state.playerCurrentPage + 1,
      ));
    } catch (e) {
      emit(state.copyWith(playerNewsStatus: NewsRequest.requestFailure));
    }
  }

  Future<void> _handlePlayerNewsNextPageRequested(
      PlayerNewsNextPageRequested event, Emitter<NewsState> emit) async {
    if (state.isPlayerNextPageLoading) return;

    emit(state.copyWith(isPlayerNextPageLoading: true));
    try {
      final nextPage = await api.getPlayerNews(
        lang: event.language,
        page: state.playerCurrentPage,
        playerName: event.playerName,
      );

      if (nextPage.isEmpty) {
        emit(state.copyWith(
          isPlayerNextPageLoading: false,
          isLastPage: true,
        ));
        return;
      }

      emit(state.copyWith(
        playerNews: [...state.playerNews, ...nextPage],
        isPlayerNextPageLoading: false,
        playerCurrentPage: state.playerCurrentPage + 1,
      ));
    } catch (e) {
      emit(state.copyWith(isPlayerNextPageLoading: false));
    }
  }

  // ===================== TRENDING NEWS =====================
  Future<void> _handleTrendingNewsRequested(
      TrendingNewsRequested event, Emitter<NewsState> emit) async {
    try {
      emit(state.copyWith(
        trendingNewsStatus: NewsRequest.requestInProgress,
      ));

      final response = await api.getTrendingNews(
        lang: event.language,
        page: state.trendingCurrentPage,
      );

      if (response.isEmpty) {
        final cachedTrendingNews =
            await NewsCacheManager().getTrendingNewsCache();

        if (cachedTrendingNews != null && cachedTrendingNews.isNotEmpty) {
          emit(state.copyWith(
              trendingNews: cachedTrendingNews,
              trendingNewsStatus: NewsRequest.requestSuccess,
              trendingCurrentPage: 1));
        } else {
          emit(state.copyWith(
              trendingNewsStatus: NewsRequest.requestFailure,
              trendingCurrentPage: state.trendingCurrentPage));
        }
        return;
      }

      await NewsCacheManager().cacheTrendingNews(response);

      emit(state.copyWith(
          trendingNews: response,
          trendingNewsStatus: NewsRequest.requestSuccess,
          trendingCurrentPage: state.trendingCurrentPage + 1));
    } catch (e) {
      final cachedTrendingNews =
          await NewsCacheManager().getTrendingNewsCache();

      if (cachedTrendingNews != null && cachedTrendingNews.isNotEmpty) {
        emit(state.copyWith(
            trendingNews: cachedTrendingNews,
            trendingNewsStatus: NewsRequest.requestSuccess,
            trendingCurrentPage: 1));
      } else {
        emit(state.copyWith(
            trendingNewsStatus: NewsRequest.requestFailure,
            trendingCurrentPage: state.trendingCurrentPage));
      }
    }
  }

  Future<void> _handleLoadTrendingNextPage(
      TrendingNewsLoadNextPage event, Emitter<NewsState> emit) async {
    if (state.isTrendingNextPageLoading || state.isTrendingLastPage) return;

    try {
      emit(state.copyWith(isTrendingNextPageLoading: true));

      final response = await api.getTrendingNews(
        lang: event.language,
        page: state.trendingCurrentPage,
      );

      emit(state.copyWith(
          trendingNews: List.from(state.trendingNews)..addAll(response),
          trendingNewsStatus: NewsRequest.requestSuccess,
          isTrendingNextPageLoading: false,
          trendingCurrentPage: state.trendingCurrentPage + 1,
          isTrendingLastPage: response.isEmpty));
    } catch (e) {
      emit(state.copyWith(
          trendingNewsStatus: NewsRequest.requestFailure,
          isTrendingNextPageLoading: false));
    }
  }

  Future<void> _handleTrendingNewsRefreshRequested(
      TrendingNewsRefreshRequested event, Emitter<NewsState> emit) async {
    try {
      final response = await api.getTrendingNews(lang: event.language, page: 0);

      await NewsCacheManager().cacheTrendingNews(response);

      emit(state.copyWith(
          trendingNews: response,
          trendingNewsStatus: NewsRequest.requestSuccess,
          trendingNewsRefreshing: false,
          trendingCurrentPage: 1));
    } catch (e) {
      final cachedTrendingNews =
          await NewsCacheManager().getTrendingNewsCache();

      if (cachedTrendingNews != null && cachedTrendingNews.isNotEmpty) {
        emit(state.copyWith(
            trendingNews: cachedTrendingNews,
            trendingNewsStatus: NewsRequest.requestSuccess,
            trendingNewsRefreshing: false));
      } else {
        emit(state.copyWith(
            trendingNewsStatus: NewsRequest.requestFailure,
            trendingNewsRefreshing: false));
      }
    }
  }
}
