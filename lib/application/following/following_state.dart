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
  List<int> followedPlayers;
  List<int> followedTeams;

  FollowingState(
      {this.status = Status.initial,
      this.favouriteMatches = const [],
      this.followedPodcasts = const [],
      this.followedPlayers = const [],
      this.followedTeams = const []});

  FollowingState copyWith(
      {Status? status,
      List<int>? favouriteMatches,
      List<String>? followedPodcasts,
      List<int>? followedPlayers,
      List<int>? followedTeams}) {
    return FollowingState(
        status: status ?? this.status,
        favouriteMatches: favouriteMatches ?? this.favouriteMatches,
        followedPodcasts: followedPodcasts ?? this.followedPodcasts,
        followedPlayers: followedPlayers ?? this.followedPlayers,
        followedTeams: followedTeams ?? this.followedTeams);
  }
}
