import '../../../models/program_card/PodcastModel.dart';

enum podcastStatus {
  requested,
  requestFailed,
  requestSuccess,
  unknown,
  requestFailure
}

class PodcastsState {
  final List<PodcastModel> podcasts;
  final podcastStatus status;
  final int page;
  final bool hasNextPage;
  final bool isLoadingMore;

  PodcastsState({
    this.podcasts = const [],
    this.status = podcastStatus.unknown,
    this.page = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
  });

  PodcastsState copyWith({
    List<PodcastModel>? podcasts,
    podcastStatus? status,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) =>
      PodcastsState(
        podcasts: podcasts ?? this.podcasts,
        status: status ?? this.status,
        page: page ?? this.page,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}
