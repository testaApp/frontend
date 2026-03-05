import 'package:blogapp/models/news.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';

enum NewsRequest {
  unknown,
  requestInProgress,
  requestSuccess,
  requestFailure,
  requesting,
  serverError,
  networkError,
}

class NewsState {
  NewsState({
    this.transfernewsStatus = NewsRequest.unknown,
    this.news = const [],
    this.transfernews = const [],
    this.forYouNews = const [],
    this.leagueNews = const [],
    this.teamNews = const [],
    this.playerNews = const [],
    this.TransferNews = const [],
    this.newsStatus = NewsRequest.unknown,
    this.leagueNewsStatus = NewsRequest.unknown,
    this.teamNewsStatus = NewsRequest.unknown,
    this.playerNewsStatus = NewsRequest.unknown,
    this.ids = const {},
    this.detail = const {},
    this.currentPage = 0,
    this.forYouCurrentPage = 0,
    this.leaguesCurrentPage = 0,
    this.teamCurrentPage = 0,
    this.playerCurrentPage = 0,
    this.isNextPageLoading = false,
    this.isLeaguesNextPageLoading = false,
    this.isTeamNextPageLoading = false,
    this.isPlayerNextPageLoading = false,
    this.isForYouNextPageLoading = false,
    this.isTransferNextPageLoading = false,
    this.isNewsLastPage = false,
    this.isTransferLastPage = false,
    this.isLeagueLastPage = false,
    this.isTeamLastPage = false,
    this.isPlayerLastPage = false,
    this.isTopTransferLastPage = false,
    this.isTrendingLastPage = false,
    this.isForYouLastPage = false,
    this.counter = 0,
    this.forYouNewsStatus = NewsRequest.unknown,
    this.newsRefreshing = false,
    this.transferNewsRefreshing = false,
    this.forYouNewsRefreshing = false,
    this.topTransferNews = const [],
    this.isTopTransferNextPageLoading = false,
    this.topTransfernewsStatus = NewsRequest.unknown,
    this.topTransferCurrentPage = 0,
    this.transferCurrentPage = 0,
    this.trendingNews = const [],
    this.isTrendingNextPageLoading = false,
    this.trendingNewsStatus = NewsRequest.unknown,
    this.trendingCurrentPage = 0,
    this.trendingNewsRefreshing = false,
    this.forYouTeamNews = const {},
    this.forYouPlayerNews = const {},
    this.teamNames = const {},
    this.playerNames = const {},
    this.teamLogos = const {},
    this.playerImages = const {},
  });

  List<News> news;
  List<News> transfernews;
  List<News> leagueNews;
  List<News> teamNews;
  List<News> playerNews;
  List<News> forYouNews;

  List<TransferModel> TransferNews;
  List<TransferModel> topTransferNews;
  List<News> trendingNews;

  final NewsRequest transfernewsStatus;
  final NewsRequest newsStatus;
  final NewsRequest forYouNewsStatus;
  final NewsRequest leagueNewsStatus;
  final NewsRequest teamNewsStatus;
  final NewsRequest playerNewsStatus;
  final NewsRequest topTransfernewsStatus;
  final NewsRequest trendingNewsStatus;

  final bool isTrendingLastPage;
  final Set<String> ids;
  final Map detail;

  int currentPage;
  int forYouCurrentPage;
  int leaguesCurrentPage;
  int teamCurrentPage;
  int playerCurrentPage;
  int topTransferCurrentPage;
  int transferCurrentPage;
  int trendingCurrentPage;

  final bool isNextPageLoading;
  final bool isForYouNextPageLoading;
  final bool isLeaguesNextPageLoading;
  final bool isTeamNextPageLoading;
  final bool isPlayerNextPageLoading;
  final bool isTransferNextPageLoading;
  final bool isTopTransferNextPageLoading;
  final bool isTrendingNextPageLoading;

  final bool isNewsLastPage;
  final bool isTransferLastPage;
  final bool isLeagueLastPage;
  final bool isTeamLastPage;
  final bool isPlayerLastPage;
  final bool isTopTransferLastPage;
  final bool isForYouLastPage;

  int counter;

  final bool newsRefreshing;
  final bool forYouNewsRefreshing;
  final bool transferNewsRefreshing;
  final bool trendingNewsRefreshing;

  final Map<String, List<News>> forYouTeamNews;
  final Map<String, List<News>> forYouPlayerNews;
  final Map<String, String> teamNames;
  final Map<String, String> playerNames;
  final Map<String, String> teamLogos;
  final Map<String, String> playerImages;

  NewsState copyWith({
    List<News>? news,
    List<News>? transfernews,
    List<News>? forYouNews,
    List<News>? leagueNews,
    List<News>? teamNews,
    List<News>? playerNews,
    List<TransferModel>? TransferNews,
    List<TransferModel>? topTransferNews,
    List<News>? trendingNews,
    NewsRequest? newsStatus,
    NewsRequest? transfernewsStatus,
    NewsRequest? forYouNewsStatus,
    NewsRequest? leagueNewsStatus,
    NewsRequest? teamNewsStatus,
    NewsRequest? playerNewsStatus,
    NewsRequest? topTransfernewsStatus,
    NewsRequest? trendingNewsStatus,
    Set<String>? ids,
    Map? detail,
    int? currentPage,
    int? forYouCurrentPage,
    int? leaguesCurrentPage,
    int? teamCurrentPage,
    int? playerCurrentPage,
    int? topTransferCurrentPage,
    int? transferCurrentPage,
    int? trendingCurrentPage,
    bool? isNextPageLoading,
    bool? isForYouNextPageLoading,
    bool? isLeaguesNextPageLoading,
    bool? isTeamNextPageLoading,
    bool? isPlayerNextPageLoading,
    bool? isTransferNextPageLoading,
    bool? isTopTransferNextPageLoading,
    bool? isTrendingNextPageLoading,
    bool? isNewsLastPage,
    bool? isTransferLastPage,
    bool? isLeagueLastPage,
    bool? isTeamLastPage,
    bool? isPlayerLastPage,
    bool? isTopTransferLastPage,
    bool? isForYouLastPage,
    bool? isTrendingLastPage,
    int? counter,
    bool? newsRefreshing,
    bool? forYouNewsRefreshing,
    bool? transferNewsRefreshing,
    bool? trendingNewsRefreshing,
    Map<String, List<News>>? forYouTeamNews,
    Map<String, List<News>>? forYouPlayerNews,
    Map<String, String>? teamNames,
    Map<String, String>? playerNames,
    Map<String, String>? teamLogos,
    Map<String, String>? playerImages,
  }) =>
      NewsState(
        news: news ?? this.news,
        transfernews: transfernews ?? this.transfernews,
        forYouNews: forYouNews ?? this.forYouNews,
        leagueNews: leagueNews ?? this.leagueNews,
        teamNews: teamNews ?? this.teamNews,
        playerNews: playerNews ?? this.playerNews,
        TransferNews: TransferNews ?? this.TransferNews,
        topTransferNews: topTransferNews ?? this.topTransferNews,
        trendingNews: trendingNews ?? this.trendingNews,
        newsStatus: newsStatus ?? this.newsStatus,
        transfernewsStatus: transfernewsStatus ?? this.transfernewsStatus,
        forYouNewsStatus: forYouNewsStatus ?? this.forYouNewsStatus,
        leagueNewsStatus: leagueNewsStatus ?? this.leagueNewsStatus,
        teamNewsStatus: teamNewsStatus ?? this.teamNewsStatus,
        playerNewsStatus: playerNewsStatus ?? this.playerNewsStatus,
        topTransfernewsStatus:
            topTransfernewsStatus ?? this.topTransfernewsStatus,
        trendingNewsStatus:
            trendingNewsStatus ?? this.trendingNewsStatus,
        ids: ids ?? this.ids,
        detail: detail ?? this.detail,
        currentPage: currentPage ?? this.currentPage,
        forYouCurrentPage: forYouCurrentPage ?? this.forYouCurrentPage,
        leaguesCurrentPage: leaguesCurrentPage ?? this.leaguesCurrentPage,
        teamCurrentPage: teamCurrentPage ?? this.teamCurrentPage,
        playerCurrentPage: playerCurrentPage ?? this.playerCurrentPage,
        topTransferCurrentPage:
            topTransferCurrentPage ?? this.topTransferCurrentPage,
        transferCurrentPage: transferCurrentPage ?? this.transferCurrentPage,
        trendingCurrentPage: trendingCurrentPage ?? this.trendingCurrentPage,
        isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
        isForYouNextPageLoading:
            isForYouNextPageLoading ?? this.isForYouNextPageLoading,
        isLeaguesNextPageLoading:
            isLeaguesNextPageLoading ?? this.isLeaguesNextPageLoading,
        isTeamNextPageLoading:
            isTeamNextPageLoading ?? this.isTeamNextPageLoading,
        isPlayerNextPageLoading:
            isPlayerNextPageLoading ?? this.isPlayerNextPageLoading,
        isTransferNextPageLoading:
            isTransferNextPageLoading ?? this.isTransferNextPageLoading,
        isTopTransferNextPageLoading:
            isTopTransferNextPageLoading ?? this.isTopTransferNextPageLoading,
        isTrendingNextPageLoading:
            isTrendingNextPageLoading ?? this.isTrendingNextPageLoading,
        isTrendingLastPage: isTrendingLastPage ?? this.isTrendingLastPage,
        isNewsLastPage: isNewsLastPage ?? this.isNewsLastPage,
        isTransferLastPage: isTransferLastPage ?? this.isTransferLastPage,
        isLeagueLastPage: isLeagueLastPage ?? this.isLeagueLastPage,
        isTeamLastPage: isTeamLastPage ?? this.isTeamLastPage,
        isPlayerLastPage: isPlayerLastPage ?? this.isPlayerLastPage,
        isTopTransferLastPage:
            isTopTransferLastPage ?? this.isTopTransferLastPage,
        isForYouLastPage: isForYouLastPage ?? this.isForYouLastPage,
        counter: counter ?? this.counter,
        newsRefreshing: newsRefreshing ?? this.newsRefreshing,
        forYouNewsRefreshing: forYouNewsRefreshing ?? this.forYouNewsRefreshing,
        transferNewsRefreshing:
            transferNewsRefreshing ?? this.transferNewsRefreshing,
        trendingNewsRefreshing:
            trendingNewsRefreshing ?? this.trendingNewsRefreshing,
        forYouTeamNews: forYouTeamNews ?? this.forYouTeamNews,
        forYouPlayerNews: forYouPlayerNews ?? this.forYouPlayerNews,
        teamNames: teamNames ?? this.teamNames,
        playerNames: playerNames ?? this.playerNames,
        teamLogos: teamLogos ?? this.teamLogos,
        playerImages: playerImages ?? this.playerImages,
      );
}
