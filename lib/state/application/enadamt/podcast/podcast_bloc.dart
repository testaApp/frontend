import 'package:bloc/bloc.dart';

import 'package:blogapp/data/repositories/podcasts_repository.dart';
import 'package:blogapp/models/program_card/PodcastModel.dart';
import 'podcast_cache_manager.dart';
import 'podcast_state.dart';
import 'podcast_event.dart';

class PodcastsBloc extends Bloc<PodcastsEvent, PodcastsState> {
  final PodcastCacheManager _cacheManager = PodcastCacheManager();
  static const int _defaultLimit = 20;

  PodcastsBloc() : super(PodcastsState()) {
    on<PodcastsEvent>((event, emit) {});
    on<PodcastsRequested>(_handlePodcastsRequested);
    on<PodcastsLoadMore>(_handlePodcastsLoadMore);
    on<PodcastsRefresh>(_handlePodcastsRefresh);
  }

  Future<void> _handlePodcastsRequested(
      PodcastsRequested event, Emitter<PodcastsState> emit) async {
    emit(state.copyWith(status: podcastStatus.requested));

    try {
      final cached = await _cacheManager.getPodcastsCache();
      if (cached != null && cached.items.isNotEmpty) {
        emit(state.copyWith(
          status: podcastStatus.requestSuccess,
          podcasts: cached.items,
          page: cached.page,
          hasNextPage: cached.hasNext,
          isLoadingMore: false,
        ));
        return;
      }

      await _fetchPage(emit, page: 1, append: false);
    } catch (e) {
      emit(state.copyWith(status: podcastStatus.requestFailed));
    }
  }

  Future<void> _handlePodcastsRefresh(
      PodcastsRefresh event, Emitter<PodcastsState> emit) async {
    emit(state.copyWith(status: podcastStatus.requested));
    await _fetchPage(emit, page: 1, append: false);
  }

  Future<void> _handlePodcastsLoadMore(
      PodcastsLoadMore event, Emitter<PodcastsState> emit) async {
    if (state.isLoadingMore || !state.hasNextPage) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetchPage(emit, page: state.page + 1, append: true);
  }

  Future<void> _fetchPage(
    Emitter<PodcastsState> emit, {
    required int page,
    required bool append,
  }) async {
    try {
      final api = PodcastsApiDataSource();
      final result =
          await api.getPodcastsPage(page: page, limit: _defaultLimit);

      await result.fold<Future<void>>(
        (l) async {
          emit(state.copyWith(
            status: append ? state.status : podcastStatus.requestFailed,
            isLoadingMore: false,
          ));
        },
        (r) async {
          final merged = append
              ? (List<PodcastModel>.from(state.podcasts)..addAll(r.items))
              : r.items;

          await _cacheManager.cachePodcasts(
            merged,
            page: r.page,
            hasNext: r.hasNext,
            limit: r.limit,
          );

          emit(state.copyWith(
            status: podcastStatus.requestSuccess,
            podcasts: merged,
            page: r.page,
            hasNextPage: r.hasNext,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: append ? state.status : podcastStatus.requestFailed,
        isLoadingMore: false,
      ));
    }
  }
}
