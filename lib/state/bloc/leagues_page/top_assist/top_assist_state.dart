import 'package:blogapp/models/leagues_page/top_scorer.model.dart';

enum AssistStatus {
  requestInProgress,
  requestFailure,
  requestSuccessed,
  unknown,
  initial
}

enum AssistStatKind { topScorer, topAssist, initial }

class TopAssistState {
  List<TopScorerModel> topAssistors;
  AssistStatus status;
  AssistStatKind statKind;
  List<TopScorerModel> previousTopAssistors;

  TopAssistState({
    this.topAssistors = const [],
    this.previousTopAssistors = const [],
    this.status = AssistStatus.initial,
    this.statKind = AssistStatKind.initial,
  });

  TopAssistState copyWith({
    List<TopScorerModel>? topAssistors,
    AssistStatus? status,
    AssistStatKind? statKind,
    List<TopScorerModel>? previousTopAssistors,
  }) =>
      TopAssistState(
        topAssistors: topAssistors ?? this.topAssistors,
        status: status ?? this.status,
        statKind: statKind ?? this.statKind,
        previousTopAssistors: previousTopAssistors ?? this.previousTopAssistors,
      );
}
