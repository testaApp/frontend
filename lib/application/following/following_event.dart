abstract class FollowingEvent {}

class FollowPlayerRequested extends FollowingEvent {
  final int playerId;
  FollowPlayerRequested({required this.playerId});
}

class FollowPodcastRequested extends FollowingEvent {
  final String podcastId;
  final String? programId; // ADD THIS

  FollowPodcastRequested({required this.podcastId, this.programId});
}

class RemoveFollowingPlayer extends FollowingEvent {
  final int playerId;
  RemoveFollowingPlayer({required this.playerId});
}

class FollowTeamRequested extends FollowingEvent {
  final int teamId;
  FollowTeamRequested({required this.teamId});
}

class RemoveFollowingTeam extends FollowingEvent {
  final int teamId;
  RemoveFollowingTeam({required this.teamId});
}

class FollowFixtureRequested extends FollowingEvent {
  final int fixtureId;
  FollowFixtureRequested({required this.fixtureId});
}

class RemoveFollowingFixture extends FollowingEvent {
  final int fixtureId;
  RemoveFollowingFixture({required this.fixtureId});
}

class RemoveFollowingPodcast extends FollowingEvent {
  final String podcastId;
    final String? programId; // ADD THIS

  RemoveFollowingPodcast({required this.podcastId, this.programId});
}

class AddFavouriteMatchEvent extends FollowingEvent {
  final int? matchId;
  AddFavouriteMatchEvent({required this.matchId});
}

class RemoveFavouriteMatchEvent extends FollowingEvent {
  final int? matchId;
  RemoveFavouriteMatchEvent({required this.matchId});
}

class CheckFollowingMatch extends FollowingEvent {
  final int matchId;
  final bool checkOnly;

  CheckFollowingMatch({
    required this.matchId,
    this.checkOnly = false,
  });
}

class CheckFollowingPlayer extends FollowingEvent {
  final int playerId;
  CheckFollowingPlayer({required this.playerId});
}

class CheckFollowingTeam extends FollowingEvent {
  final int teamId;
  CheckFollowingTeam({required this.teamId});
}

class CheckFollowingPodcast extends FollowingEvent {
  final String podcastId;
  CheckFollowingPodcast({required this.podcastId});
}

class ToggleFollowPlayer extends FollowingEvent {
  final int playerId;
  ToggleFollowPlayer({required this.playerId});
}

class FetchAndSaveFavoritePodcasts extends FollowingEvent {}
