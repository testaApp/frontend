import './fixtures/stat.dart';

class FixtureListsByLeague {
  String dateOnly;
  List<Stat> leagueMatches;
  FixtureListsByLeague({
    required this.dateOnly,
    required this.leagueMatches,
  });
}

class LeagueFixtures {
  final List<FixtureListsByLeague> previousMatches;
  final List<FixtureListsByLeague> upcomingMatches;
  const LeagueFixtures(
      {required this.previousMatches, required this.upcomingMatches});
}
