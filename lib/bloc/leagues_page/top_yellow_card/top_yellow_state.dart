import '../../../models/leagues_page/top_scorer.model.dart';

enum CardScorerStatus {
  requestInProgress,
  requestFailure,
  requestSuccessed,
  unknown,
  initial
}

enum StatKind { topScorer, topAssist, initial }

class TopYellowCardsState {
  List<TopScorerModel> topYellowCards;
  CardScorerStatus status;
  StatKind statKind;
  List<TopScorerModel> previousTopYellowCards;

  TopYellowCardsState(
      {this.topYellowCards = const [],
      this.previousTopYellowCards = const [],
      this.status = CardScorerStatus.initial,
      this.statKind = StatKind.initial});

  TopYellowCardsState copyWith(
          {List<TopScorerModel>? topYellowCards,
          CardScorerStatus? status,
          StatKind? statKind,
          List<TopScorerModel>? previousTopYellowCards}) =>
      TopYellowCardsState(
          status: status ?? this.status,
          topYellowCards: topYellowCards ?? this.topYellowCards,
          statKind: statKind ?? this.statKind,
          previousTopYellowCards:
              previousTopYellowCards ?? this.previousTopYellowCards);
}
