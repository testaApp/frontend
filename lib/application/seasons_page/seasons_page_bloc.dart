import 'package:bloc/bloc.dart';

import '../../repository/standing_repo.dart';
import '../../util/baseUrl.dart';
import 'seasons_page_event.dart';
import 'seasons_page_state.dart';

class SeasonsPageBloc extends Bloc<SeasonsPageEvent, SeasonsPageState> {
  SeasonsPageBloc() : super(SeasonsPageState()) {
    on<LeagueWinnersRequested>(_handleSeasonsRequested);
  }
  String url = BaseUrl().url;

  Future<void> _handleSeasonsRequested(
      LeagueWinnersRequested event, Emitter<SeasonsPageState> emit) async {
    emit(state.copyWith(status: SeasonsPageStatus.loading));

    try {
      final data = await getLeagueWinners(leagueId: event.leagueId);

      data.fold(
        (failure) {
          print('Failed to get league winners: ${failure.hashCode}');
          emit(state.copyWith(
            winners: [],
            status: SeasonsPageStatus.error,
          ));
        },
        (winners) {
          if (winners.isEmpty) {
            emit(state.copyWith(
              winners: [],
              status: SeasonsPageStatus.error,
            ));
          } else {
            emit(state.copyWith(
              winners: winners,
              status: SeasonsPageStatus.loaded,
            ));
          }
        },
      );
    } catch (e) {
      print('Error in seasons bloc: $e');
      emit(state.copyWith(
        winners: [],
        status: SeasonsPageStatus.error,
      ));
    }
  }
}
