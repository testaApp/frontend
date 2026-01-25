import 'package:bloc/bloc.dart';

import '../../../../repository/podcasts_repository.dart';
import 'podcast_state.dart';
import 'podcast_event.dart';

class PodcastsBloc extends Bloc<PodcastsEvent, PodcastsState> {
  PodcastsBloc() : super(PodcastsState()) {
    on<PodcastsEvent>((event, emit) {});
    on<PodcastsRequested>(_handlePodcastsRequested);
  }

  Future<void> _handlePodcastsRequested(
      PodcastsRequested event, Emitter<PodcastsState> emit) async {
    emit(state.copyWith(status: podcastStatus.requested));

    try {
      PodcastsApiDataSource api = PodcastsApiDataSource();
      final result = await api.getAllPodcasts();

      result.fold(
        (l) => emit(state.copyWith(status: podcastStatus.requestFailed)),
        (r) => emit(
            state.copyWith(status: podcastStatus.requestSuccess, podcasts: r)),
      );
    } catch (e) {
      // This catches the SocketException/Connection Abort
      emit(state.copyWith(status: podcastStatus.requestFailed));
    }
  }
}
