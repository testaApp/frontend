enum Status {
  initial,
  requested,
  following,
  success,
  networkError,
  serverError,
  unknownError,
  notFollowing,
  followRequested,
  unfollowRequested,
  error,
  loading
}

class FollowingState {
  final Status status;
  List<int> favouriteMatches;
  List<String> followedPodcasts;

  FollowingState(
      {this.status = Status.initial,
      this.favouriteMatches = const [],
      this.followedPodcasts = const []});

  FollowingState copyWith(
      {Status? status,
      List<int>? favouriteMatches,
      List<String>? followedPodcasts}) {
    return FollowingState(
        status: status ?? this.status,
        favouriteMatches: favouriteMatches ?? this.favouriteMatches,
        followedPodcasts: followedPodcasts ?? this.followedPodcasts);
  }
}
