import 'package:blogapp/domain/team/team.dart';

enum BestTeamRequest {
  unknown,
  requestInProgress,
  requestSuccess,
  requestFailure,
}

class TeamState {
  const TeamState({
    this.bestTeamRequestStatus,
    this.bestTeams = const [],
    this.bestTeamIDs = const [],
    this.selectedTeam,
  });

  final BestTeamRequest? bestTeamRequestStatus;
  final List<TeamInfo> bestTeams;
  final List<int> bestTeamIDs;
  final TeamInfo? selectedTeam;

  TeamState copyWith({
    BestTeamRequest? bestTeamRequestStatus,
    List<TeamInfo>? bestTeams,
    List<int>? bestTeamIDs,
    TeamInfo? selectedTeam,
  }) =>
      TeamState(
        bestTeamRequestStatus:
            bestTeamRequestStatus ?? this.bestTeamRequestStatus,
        bestTeams: bestTeams ?? this.bestTeams,
        bestTeamIDs: bestTeamIDs ?? this.bestTeamIDs,
        selectedTeam: selectedTeam ?? this.selectedTeam,
      );
}
