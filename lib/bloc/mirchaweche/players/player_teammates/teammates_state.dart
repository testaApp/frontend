import '../../../../domain/player/team_leaders_model.dart';
import '../../../../models/favourites_page/squadModel.dart';

enum TeammatesStatus {
  requested,
  requestInProgress,
  requestFailure,
  requestSuccess,
  initial,
  notFound
}

class TeammatesState {
  final TeammatesStatus status;
  final List<SquadModel> squads;
  final SquadModel? squad;
  final int? playerId;

  final List<TeamLeader> topScorers;
  final List<TeamLeader> topAssisters;
  final List<TeamLeader> topRedCards;
  final List<TeamLeader> topYellowCards;

  TeammatesState({
    this.status = TeammatesStatus.initial,
    this.playerId,
    this.squads = const [],
    this.squad,
    this.topScorers = const [],
    this.topAssisters = const [],
    this.topRedCards = const [],
    this.topYellowCards = const [],
  });

  TeammatesState copyWith({
    TeammatesStatus? status,
    List<SquadModel>? squads,
    int? playerId,
    SquadModel? squad,
    bool clearSquad = false, // Add this flag
    List<TeamLeader>? topScorers,
    List<TeamLeader>? topAssisters,
    List<TeamLeader>? topRedCards,
    List<TeamLeader>? topYellowCards,
  }) {
    return TeammatesState(
      status: status ?? this.status,
      squads: squads ?? this.squads,
      playerId: playerId ?? this.playerId,
      squad: clearSquad
          ? null
          : (squad ?? this.squad), // Clear squad if flag is set
      topScorers: topScorers ?? this.topScorers,
      topAssisters: topAssisters ?? this.topAssisters,
      topRedCards: topRedCards ?? this.topRedCards,
      topYellowCards: topYellowCards ?? this.topYellowCards,
    );
  }
}
