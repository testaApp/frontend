abstract class TeamProfileStatisticsEvent {
  const TeamProfileStatisticsEvent();
}

class TeamProfileStatisticsRequested extends TeamProfileStatisticsEvent {
  final int teamId;

  const TeamProfileStatisticsRequested({required this.teamId});
}
