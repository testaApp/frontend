import '../../../models/Matches_model.dart';

enum highlightsPageStatus {
  requested,
  serverError,
  requestSuccess,
  networkFailure,
  initial
}

enum NextPageStatus {
  requested,
  serverError,
  requestSuccess,
  networkFailure,
  initial
}

class HighlightsPageState {
  List<Matches_model> highlights;
  highlightsPageStatus status;
  NextPageStatus nextPageStatus;
  int pageCounter;
  HighlightsPageState(
      {this.highlights = const [],
      this.status = highlightsPageStatus.initial,
      this.pageCounter = 1,
      this.nextPageStatus = NextPageStatus.initial});
  HighlightsPageState copyWith(
          {List<Matches_model>? highlights,
          highlightsPageStatus? status,
          NextPageStatus? nextPageStatus,
          int? pageCounter}) =>
      HighlightsPageState(
        highlights: highlights ?? this.highlights,
        status: status ?? this.status,
        pageCounter: pageCounter ?? this.pageCounter,
        nextPageStatus: nextPageStatus ?? this.nextPageStatus,
      );
}
