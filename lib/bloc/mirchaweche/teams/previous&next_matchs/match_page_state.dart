import '../../../../models/Matches_model.dart';

enum matchpageStatus {
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

class MatchPageState {
  List<Matches_model> nextMatches; // For future matches
  List<Matches_model> previousMatches; // For past matches
  List<Matches_model>
      matchs; // Keep for backwards compatibility if needed elsewhere
  matchpageStatus status;
  matchpageStatus nextMatchesStatus; // Separate status for next matches
  matchpageStatus previousMatchesStatus; // Separate status for previous matches
  NextPageStatus nextPageStatus;
  int pageCounter;

  MatchPageState({
    this.nextMatches = const [],
    this.previousMatches = const [],
    this.matchs = const [],
    this.status = matchpageStatus.initial,
    this.nextMatchesStatus = matchpageStatus.initial,
    this.previousMatchesStatus = matchpageStatus.initial,
    this.pageCounter = 1,
    this.nextPageStatus = NextPageStatus.initial,
  });

  MatchPageState copyWith({
    List<Matches_model>? nextMatches,
    List<Matches_model>? previousMatches,
    List<Matches_model>? matchs,
    matchpageStatus? status,
    matchpageStatus? nextMatchesStatus,
    matchpageStatus? previousMatchesStatus,
    NextPageStatus? nextPageStatus,
    int? pageCounter,
  }) =>
      MatchPageState(
        nextMatches: nextMatches ?? this.nextMatches,
        previousMatches: previousMatches ?? this.previousMatches,
        matchs: matchs ?? this.matchs,
        status: status ?? this.status,
        nextMatchesStatus: nextMatchesStatus ?? this.nextMatchesStatus,
        previousMatchesStatus:
            previousMatchesStatus ?? this.previousMatchesStatus,
        pageCounter: pageCounter ?? this.pageCounter,
        nextPageStatus: nextPageStatus ?? this.nextPageStatus,
      );
}
