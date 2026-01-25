abstract class NewsEvent {}

class NewsRequested extends NewsEvent {
  NewsRequested({required this.language});
  String language;
}

class ForYouNewsRequested extends NewsEvent {
  ForYouNewsRequested({required this.language});
  String language;
}

class TransferNewsRequested extends NewsEvent {
  TransferNewsRequested({required this.language});
  String language;
}

class TransferLoadnextNewsRequested extends NewsEvent {
  TransferLoadnextNewsRequested({required this.language});
  String language;
}

class TransferNewsRefreshRequested extends NewsEvent {
  TransferNewsRefreshRequested({required this.language});
  String language;
}

class RefreshRequested extends NewsEvent {
  RefreshRequested({required this.language});
  String language;
}

class LoadNextPage extends NewsEvent {
  LoadNextPage({required this.language});
  String language;
}

class ForYouLoadNextPage extends NewsEvent {
  ForYouLoadNextPage({required this.language});
  String language;
}

class ForYouRefreshRequested extends NewsEvent {
  ForYouRefreshRequested({required this.language});
  String language;
}

class LeagueNewsRequested extends NewsEvent {
  LeagueNewsRequested({required this.language, required this.leagueId});
  String language;
  int leagueId;
}

class LeagueNewsNextPageRequested extends NewsEvent {
  LeagueNewsNextPageRequested({required this.language, required this.leagueId});
  String language;
  int leagueId;
}

class TopTransferRequested extends NewsEvent {
  String RssLink;
  TopTransferRequested({this.RssLink = ''});
}

class TrendingNewsRequested extends NewsEvent {
  final String language;

  TrendingNewsRequested({required this.language});
}

class TrendingNewsRefreshRequested extends NewsEvent {
  final String language;

  TrendingNewsRefreshRequested({required this.language});
}

class TrendingNewsLoadNextPage extends NewsEvent {
  final String language;

  TrendingNewsLoadNextPage({required this.language});
}

class TopLoadNextTransferPage extends NewsEvent {}
