import '../../../../models/favourites_page/teams/standing_model.dart';

enum teamProfileStandingStatus {
  initial,
  requested,
  success,
  notFound,
  networkError,
}

class TeamProfileStandingState {
  final List<TeamProfileStandingModel> standings;
  final teamProfileStandingStatus status;

  const TeamProfileStandingState({
    this.standings = const [],
    this.status = teamProfileStandingStatus.initial,
  });

  TeamProfileStandingState copyWith({
    List<TeamProfileStandingModel>? standings,
    teamProfileStandingStatus? status,
  }) {
    return TeamProfileStandingState(
      standings: standings ?? this.standings,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamProfileStandingState &&
        listEquals(standings, other.standings) &&
        status == other.status;
  }

  @override
  int get hashCode => standings.hashCode ^ status.hashCode;
}

// Helper for list equality (optional but recommended for Bloc states)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
