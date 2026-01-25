import '../../../../models/teamName.dart';

abstract class TeammatesEvent {}

class TeammatesRequested extends TeammatesEvent {
  final int playerId;
  TeammatesRequested({required this.playerId});
}

class SquadRequseted extends TeammatesEvent {
  final TeamName team;
  SquadRequseted({required this.team});
}

// --- NEW EVENT ---
class TeamLeadersRequested extends TeammatesEvent {
  final int teamId;
  TeamLeadersRequested({required this.teamId});
}
