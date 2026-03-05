abstract class TeamEvent {}

class FetchTeamsEvent extends TeamEvent {}

class AddToHiveEvent extends TeamEvent {
  final int teamId;

  AddToHiveEvent(this.teamId);
}

class RemoveFromHiveEvent extends TeamEvent {
  final int teamId;

  RemoveFromHiveEvent(this.teamId);
}

class GetAllIdsFromHiveEvent extends TeamEvent {}

class GetTeamByIdEvent extends TeamEvent {
  final int teamId;

  GetTeamByIdEvent(this.teamId);
}
