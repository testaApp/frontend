import 'package:blogapp/models/leagues_page/top_scorer.model.dart';

enum RedStatus {
  requestInProgress,
  requestFailure,
  requestSuccessed,
  unknown,
  initial
}

enum StatKind { topScorer, topAssist, initial }

class TopRedState {
  List<TopScorerModel> topRed;
  RedStatus status;
  StatKind statKind;
  List<TopScorerModel> previousTopReds;

  TopRedState({
    this.topRed = const [],
    this.previousTopReds = const [],
    this.status = RedStatus.initial,
    this.statKind = StatKind.initial,
  });

  TopRedState copyWith({
    List<TopScorerModel>? topRed,
    RedStatus? status,
    StatKind? statKind,
    List<TopScorerModel>? previousTopReds,
  }) =>
      TopRedState(
        topRed: topRed ?? this.topRed,
        status: status ?? this.status,
        statKind: statKind ?? this.statKind,
        previousTopReds: previousTopReds ?? this.previousTopReds,
      );
}
