import '../../models/news.dart';
import '../../pages/appbar_pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';

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
    this.TransferNews = const [],
    this.newsStatus = NewsRequest.unknown,
    this.leagueNewsStatus = NewsRequest.unknown,
    this.ids = const {},
    this.detail = const {},
    this.currentPage = 0,
    this.forYouCurrentPage = 0,
    this.isNextPageLoading = false,
    this.isLeaguesNextPageLoading = false,
    this.isForYouNextPageLoading = false,
    this.isTransferNextPageLoading = false,
    this.isLastPage = false,
    this.isTrendingLastPage = false,
    this.isForYouLastPage = false,
    this.counter = 0,
    this.forYouNewsStatus = NewsRequest.unknown,
    this.newsRefreshing = false,
    this.transferNewsRefreshing = false,
    this.forYouNewsRefreshing = false,
    this.leaguesCurrentPage = 0,
    this.topTransferNews = const [],
    this.isTopTransferNextPageLoading = false,
    this.topTransfernewsStatus = NewsRequest.unknown,
    this.topTransferCurrentPage = 0,
    this.transferCurrentPage = 0,
    // Trending news fields
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
  List<News> forYouNews;

  List<TransferModel> TransferNews;
  List<TransferModel> topTransferNews;
  List<News> trendingNews; // Trending news list

  final NewsRequest transfernewsStatus;
  final NewsRequest newsStatus;
  final NewsRequest forYouNewsStatus;
  final NewsRequest leagueNewsStatus;
  final NewsRequest topTransfernewsStatus;
  final NewsRequest trendingNewsStatus; // Trending news status
  final bool isTrendingLastPage;
  final Set<String> ids;
  final Map detail;

  int currentPage;
  int forYouCurrentPage;
  int leaguesCurrentPage;
  int topTransferCurrentPage;
  int transferCurrentPage;
  int trendingCurrentPage; // Current page for trending news

  final bool isNextPageLoading;
  final bool isForYouNextPageLoading;
  final bool isLeaguesNextPageLoading;
  final bool isTransferNextPageLoading;
  final bool isTopTransferNextPageLoading;
  final bool isTrendingNextPageLoading; // Loading flag for trending news

  final bool isLastPage;
  final bool isForYouLastPage;

  int counter;

  final bool newsRefreshing;
  final bool forYouNewsRefreshing;
  final bool transferNewsRefreshing;
  final bool trendingNewsRefreshing; // Refresh flag for trending news

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
    List<TransferModel>? TransferNews,
    List<TransferModel>? topTransferNews,
    List<News>? trendingNews, // Add trending news field
    NewsRequest? newsStatus,
    NewsRequest? transfernewsStatus,
    NewsRequest? forYouNewsStatus,
    NewsRequest? leagueNewsStatus,
    NewsRequest? topTransfernewsStatus,
    NewsRequest? trendingNewsStatus, // Add trending news status
    Set<String>? ids,
    Map? detail,
    int? currentPage,
    int? forYouCurrentPage,
    int? leaguesCurrentPage,
    int? topTransferCurrentPage,
    int? transferCurrentPage,
    int? trendingCurrentPage, // Add trending news current page
    bool? isNextPageLoading,
    bool? isForYouNextPageLoading,
    bool? isLeaguesNextPageLoading,
    bool? isTransferNextPageLoading,
    bool? isTopTransferNextPageLoading,
    bool? isTrendingNextPageLoading, // Add trending news loading flag
    bool? isLastPage,
    bool? isForYouLastPage,
    bool? isTrendingLastPage,
    int? counter,
    bool? newsRefreshing,
    bool? forYouNewsRefreshing,
    bool? transferNewsRefreshing,
    bool? trendingNewsRefreshing, // Add trending news refresh flag
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
        TransferNews: TransferNews ?? this.TransferNews,
        topTransferNews: topTransferNews ?? this.topTransferNews,
        trendingNews:
            trendingNews ?? this.trendingNews, // Add trending news to copyWith
        newsStatus: newsStatus ?? this.newsStatus,
        transfernewsStatus: transfernewsStatus ?? this.transfernewsStatus,
        forYouNewsStatus: forYouNewsStatus ?? this.forYouNewsStatus,
        leagueNewsStatus: leagueNewsStatus ?? this.leagueNewsStatus,
        topTransfernewsStatus:
            topTransfernewsStatus ?? this.topTransfernewsStatus,
        trendingNewsStatus: trendingNewsStatus ??
            this.trendingNewsStatus, // Add trending news status to copyWith
        ids: ids ?? this.ids,
        detail: detail ?? this.detail,
        currentPage: currentPage ?? this.currentPage,
        forYouCurrentPage: forYouCurrentPage ?? this.forYouCurrentPage,
        leaguesCurrentPage: leaguesCurrentPage ?? this.leaguesCurrentPage,
        topTransferCurrentPage:
            topTransferCurrentPage ?? this.topTransferCurrentPage,
        transferCurrentPage: transferCurrentPage ?? this.transferCurrentPage,
        trendingCurrentPage: trendingCurrentPage ?? this.trendingCurrentPage,
        isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
        isForYouNextPageLoading:
            isForYouNextPageLoading ?? this.isForYouNextPageLoading,
        isLeaguesNextPageLoading:
            isLeaguesNextPageLoading ?? this.isLeaguesNextPageLoading,
        isTransferNextPageLoading:
            isTransferNextPageLoading ?? this.isTransferNextPageLoading,
        isTopTransferNextPageLoading:
            isTopTransferNextPageLoading ?? this.isTopTransferNextPageLoading,
        isTrendingNextPageLoading:
            isTrendingNextPageLoading ?? this.isTrendingNextPageLoading,
        isTrendingLastPage: isTrendingLastPage ?? this.isTrendingLastPage,
        isLastPage: isLastPage ?? this.isLastPage,
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
