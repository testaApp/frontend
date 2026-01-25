import '../../models/program_card/PodcastModel.dart';

enum podcastStatus {
  requested,
  requestFailed,
  requestSuccess,
  unknown,
  requestFailure
}

class PodcastsState {
  PodcastsState(
      {this.podcasts = const [], this.status = podcastStatus.unknown});

  List<PodcastModel> podcasts;
  podcastStatus status;
  PodcastsState copyWith(
          {List<PodcastModel>? podcasts, podcastStatus? status}) =>
      PodcastsState(
          podcasts: podcasts ?? this.podcasts, status: status ?? this.status);
}
