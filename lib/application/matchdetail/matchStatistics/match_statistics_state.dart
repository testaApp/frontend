import '../../../models/fixtures/match_statistics.dart';

enum matchesStatsStatus {
  requestInProgess,
  networkProblem,
  requestSuccessed,
  unknown,
  initial
}

class MatchStatisticsState {
  TeamsMatchStat? teamsMatchStat;
  matchesStatsStatus status;
  MatchStatisticsState(
      {this.teamsMatchStat, this.status = matchesStatsStatus.initial});
  MatchStatisticsState copyWith(
          {TeamsMatchStat? teamsMatchStat, matchesStatsStatus? status}) =>
      MatchStatisticsState(
          teamsMatchStat: teamsMatchStat ?? this.teamsMatchStat,
          status: status ?? this.status);
}
