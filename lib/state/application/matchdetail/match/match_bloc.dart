import 'package:bloc/bloc.dart';

import 'package:blogapp/data/repositories/matches_repository.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  MatchBloc() : super(MatchState()) {
    on<MatchEvent>((event, emit) {});
    on<GetMatchById>((event, emit) => _handleFixtureRequested(event, emit));
    on<RefreshMatch>((event, emit) => _handleRefreshRequested(event, emit));
  }

  _handleFixtureRequested(GetMatchById event, Emitter<MatchState> emit) async {
    emit(state.copyWith(
      stat: null,
    ));
    try {
      final response =
          await MatchApiDataSource().getFixtureById(fixtureId: event.fixtureId);
      response.fold(
          (l) => emit(state.copyWith(status: matchStatus.requestFailed)),
          (r) => emit(
              state.copyWith(status: matchStatus.requestSuccessed, stat: r)));
    } catch (e) {
      print(e);
    }
  }

  _handleRefreshRequested(RefreshMatch event, Emitter<MatchState> emit) async {
    emit(state.copyWith(status: matchStatus.refreshing));
    try {
      final response =
          await MatchApiDataSource().getFixtureById(fixtureId: event.fixtureId);
      response.fold(
          (l) => emit(state.copyWith(status: matchStatus.requestFailed)),
          (r) => emit(
              state.copyWith(status: matchStatus.requestSuccessed, stat: r)));
    } catch (e) {
      print(e);
    }
  }
}
