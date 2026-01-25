import '../../../models/leagues_page/top_scorer.model.dart';

enum ScorerStatus {
  requestInProgress,
  requestFailure,
  requestSuccessed,
  unknown,
  initial
}

enum StatKind { topScorer, topAssist, initial }

class TopScorersState {
  List<TopScorerModel> topScorers;
  ScorerStatus status;
  StatKind statKind;
  List<TopScorerModel> previousTopScorers;

  TopScorersState({
    this.topScorers = const [],
    this.previousTopScorers = const [],
    this.status = ScorerStatus.initial,
    this.statKind = StatKind.initial,
  });

  TopScorersState copyWith({
    List<TopScorerModel>? topScorers,
    ScorerStatus? status,
    StatKind? statKind,
    List<TopScorerModel>? previousTopScorers,
  }) =>
      TopScorersState(
        topScorers: topScorers ?? this.topScorers,
        status: status ?? this.status,
        statKind: statKind ?? this.statKind,
        previousTopScorers: previousTopScorers ?? this.previousTopScorers,
      );
}
