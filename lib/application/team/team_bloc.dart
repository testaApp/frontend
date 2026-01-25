import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/team/teamRepository.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRepository repository = TeamRepository();
  late Box<int> TeamBox;

  TeamBloc() : super(const TeamState()) {
    _initHive();
    on<FetchTeamsEvent>(_onFetchAll);
    on<AddToHiveEvent>(_onAddToTeamChoose);
    on<RemoveFromHiveEvent>(_onRemoveFromTeamChoose);
    on<GetAllIdsFromHiveEvent>(_onGetTeamChoose);
    on<GetTeamByIdEvent>(_onGetTeamById);
  }

  Future<void> _initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    TeamBox = await Hive.openBox<int>('team');
  }

  Future<void> _onFetchAll(
      FetchTeamsEvent event, Emitter<TeamState> emit) async {
    emit(state.copyWith(
        bestTeamRequestStatus: BestTeamRequest.requestInProgress));
    final result = await repository.getTeams();
    emit(result.fold(
      (error) =>
          state.copyWith(bestTeamRequestStatus: BestTeamRequest.requestFailure),
      (Teams) => state.copyWith(
          bestTeamRequestStatus: BestTeamRequest.requestSuccess,
          bestTeams: Teams),
    ));
  }

  Future<void> _onAddToTeamChoose(
      AddToHiveEvent event, Emitter<TeamState> emit) async {
    await repository.addToHive(event.teamId);
    await TeamBox.add(event.teamId);
    emit(state.copyWith(
      bestTeamIDs: [...state.bestTeamIDs, event.teamId],
    ));
  }

  Future<void> _onRemoveFromTeamChoose(
      RemoveFromHiveEvent event, Emitter<TeamState> emit) async {
    await repository.removeFromHive(event.teamId);
    await TeamBox.delete(event.teamId);
    emit(state.copyWith(
      bestTeamIDs: state.bestTeamIDs.where((id) => id != event.teamId).toList(),
    ));
  }

  Future<void> _onGetTeamChoose(
      GetAllIdsFromHiveEvent event, Emitter<TeamState> emit) async {
    final TeamIDs = TeamBox.values.toList();
    emit(state.copyWith(bestTeamIDs: TeamIDs));
  }

  Future<void> _onGetTeamById(
      GetTeamByIdEvent event, Emitter<TeamState> emit) async {
    emit(state.copyWith(selectedTeam: null));
    final result = await repository.getTeamById(event.teamId);
    emit(result.fold(
      (error) => state.copyWith(selectedTeam: null),
      (team) => state.copyWith(selectedTeam: team),
    ));
  }

  @override
  Future<void> close() async {
    if (TeamBox.isOpen) {
      await TeamBox.close();
    }
    return super.close();
  }
}
