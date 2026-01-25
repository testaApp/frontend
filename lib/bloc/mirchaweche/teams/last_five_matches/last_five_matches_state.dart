import '../../../../models/fixtures/last_5_matches_model.dart';

enum fiveMatchesStatus {
  initial,
  requestInProgress,
  requestSuccess,
  requestFailure,
  notFound,
}

class LastFiveMatchesState {
  final fiveMatchesStatus status;
  final List<LastFiveMatchesByLeague> matchesByLeague;
  final String? errorMessage;

  const LastFiveMatchesState({
    this.status = fiveMatchesStatus.initial,
    this.matchesByLeague = const [], // ✅ NEVER NULL
    this.errorMessage,
  });

  LastFiveMatchesState copyWith({
    fiveMatchesStatus? status,
    List<LastFiveMatchesByLeague>? matchesByLeague,
    String? errorMessage,
  }) {
    return LastFiveMatchesState(
      status: status ?? this.status,
      matchesByLeague: matchesByLeague ?? this.matchesByLeague, // ✅ SAFE
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
