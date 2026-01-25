import 'content_state.dart';

abstract class ContentEvent {}

class StandingRequested extends ContentEvent {
  StandingRequested({required this.leagueId, this.season});
  final int leagueId;
  final String? season;
}

class ChangePageRequested extends ContentEvent {
  ChangePageRequested({
    required this.pagename,
  });
  final ContentStatus pagename;
}

class FetchLeagueFixture extends ContentEvent {
  FetchLeagueFixture({required this.leagueId, this.season});
  final int leagueId;
  final String? season; // Add season as an optional parameter
}

class FetchFixtureByDate extends ContentEvent {
  FetchFixtureByDate({
    required this.pickedDate,
    required this.leagueId,
  });
  String pickedDate;
  int leagueId;
}

class PlayerStatRequested extends ContentEvent {
  PlayerStatRequested({required this.leagueId});

  int leagueId;
}

class SeasonRequested extends ContentEvent {
  SeasonRequested({required this.leagueId});

  int leagueId;
}

class KnockOutRequested extends ContentEvent {
  KnockOutRequested({required this.leagueId});

  int leagueId;
}

class RequestFixtureListByLeagueId extends ContentEvent {
  final int leagueId;
  final int season; // Add season parameter

  RequestFixtureListByLeagueId({required this.leagueId, required this.season});

  @override
  List<Object?> get props => [leagueId, season];
}

class FetchTodaysLeagueMatches extends ContentEvent {
  // No parameters needed as it will fetch all today's matches
}
