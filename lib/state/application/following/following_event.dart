abstract class FollowingEvent {}

// ========== MATCHES ==========

class AddFavouriteMatchEvent extends FollowingEvent {
  final int? matchId;  // nullable to match original
  final String? leagueName;
  final String? homeTeam;
  final String? awayTeam;

  AddFavouriteMatchEvent({
    required this.matchId,
    this.leagueName,
    this.homeTeam,
    this.awayTeam,
  });
}

class RemoveFavouriteMatchEvent extends FollowingEvent {
  final int? matchId;  // nullable to match original
  final String? leagueName;
  final String? homeTeam;
  final String? awayTeam;

  RemoveFavouriteMatchEvent({
    required this.matchId,
    this.leagueName,
    this.homeTeam,
    this.awayTeam,
  });
}

class CheckFollowingMatch extends FollowingEvent {
  final int? matchId;  // nullable to match original
  final bool checkOnly;

  CheckFollowingMatch({
    required this.matchId,
    this.checkOnly = false,
  });
}

// ========== TEAMS ==========

class FollowTeamRequested extends FollowingEvent {
  final int? teamId;  // nullable to match original
  final String? teamName;

  FollowTeamRequested({
    required this.teamId,
    this.teamName,
  });
}

class RemoveFollowingTeam extends FollowingEvent {
  final int? teamId;  // nullable to match original
  final String? teamName;

  RemoveFollowingTeam({
    required this.teamId,
    this.teamName,
  });
}

class CheckFollowingTeam extends FollowingEvent {
  final int? teamId;  // nullable to match original

  CheckFollowingTeam({required this.teamId});
}

class LoadFollowedTeams extends FollowingEvent {}

// ========== PLAYERS ==========

class FollowPlayerRequested extends FollowingEvent {
  final int? playerId;  // nullable to match original
  final String? playerName;

  FollowPlayerRequested({
    required this.playerId,
    this.playerName,
  });
}

class RemoveFollowingPlayer extends FollowingEvent {
  final int? playerId;  // nullable to match original
  final String? playerName;

  RemoveFollowingPlayer({
    required this.playerId,
    this.playerName,
  });
}

class CheckFollowingPlayer extends FollowingEvent {
  final int? playerId;  // nullable to match original

  CheckFollowingPlayer({required this.playerId});
}

class ToggleFollowPlayer extends FollowingEvent {
  final int? playerId;  // nullable to match original
  final String? playerName;

  ToggleFollowPlayer({
    required this.playerId,
    this.playerName,
  });
}

class LoadFollowedPlayers extends FollowingEvent {}

// ========== PODCASTS ==========

class FollowPodcastRequested extends FollowingEvent {
  final String podcastId;
  final String? programId;
  final String? podcastName;

  FollowPodcastRequested({
    required this.podcastId,
    this.programId,
    this.podcastName,
  });
}

class RemoveFollowingPodcast extends FollowingEvent {
  final String podcastId;
  final String? programId;
  final String? podcastName;

  RemoveFollowingPodcast({
    required this.podcastId,
    this.programId,
    this.podcastName,
  });
}

class CheckFollowingPodcast extends FollowingEvent {
  final String podcastId;

  CheckFollowingPodcast({required this.podcastId});
}

class FetchAndSaveFavoritePodcasts extends FollowingEvent {}

class LoadFollowedPodcasts extends FollowingEvent {}

// ========== SYNC ==========

class SyncPendingOperations extends FollowingEvent {}
