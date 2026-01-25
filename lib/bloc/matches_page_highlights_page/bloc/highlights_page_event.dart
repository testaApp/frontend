abstract class HighlightsPageEvent {}

class HighlightsRequested extends HighlightsPageEvent {
  int pageNumber;
  HighlightsRequested({this.pageNumber = 0});
}

class VideosRequested extends HighlightsPageEvent {
  int pageNumber;
  VideosRequested({this.pageNumber = 0});
}

class premierleaguevideoRequested extends HighlightsPageEvent {
  int pageNumber;
  premierleaguevideoRequested({this.pageNumber = 0});
}

class laligavideoRequested extends HighlightsPageEvent {
  int pageNumber;
  laligavideoRequested({this.pageNumber = 0});
}

class championsleaguevideoRequested extends HighlightsPageEvent {
  int pageNumber;
  championsleaguevideoRequested({this.pageNumber = 0});
}

class HighlightsNextPageRequested extends HighlightsPageEvent {}
