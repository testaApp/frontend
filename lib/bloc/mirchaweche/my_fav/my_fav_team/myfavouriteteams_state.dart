import '../../../../models/teamName.dart';

enum favTeamStatus { initial, requested, success, failure, notFound }

class MyfavouriteteamsState {
  favTeamStatus status;
  List<TeamName> teams;
  MyfavouriteteamsState({
    this.status = favTeamStatus.initial,
    this.teams = const [],
  });

  MyfavouriteteamsState copyWith({
    favTeamStatus? status,
    List<TeamName>? teams,
  }) {
    return MyfavouriteteamsState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
    );
  }
}
