import 'package:blogapp/models/favourites_page/teams/teamstas/teamProfileStat.dart';

enum teamProfileStatus {
  requested,
  networkFailed,
  success,
  failure,
  initial,
  notFound
}

class TeamProfileStatisticsState {
  List<TeamStats> teamStats;
  teamProfileStatus status;
  TeamProfileStatisticsState(
      {this.teamStats = const [], this.status = teamProfileStatus.initial});

  TeamProfileStatisticsState copyWith(
          {List<TeamStats>? teamStats, teamProfileStatus? status}) =>
      TeamProfileStatisticsState(
          teamStats: teamStats ?? this.teamStats,
          status: status ?? this.status);
}
