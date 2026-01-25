import 'league.dart';
import 'match_status.dart';
import 'score.dart';
import 'team.dart';
import 'venue.dart';

class Fixture {
  int id;
  String referee;
  DateTime? date;
  Venue? venue;
  MatchStatus status;
  League league;
  Team homeTeam;
  Team awayTeam;
  Score? score;

  Fixture({
    required this.id,
    this.referee = '',
    this.date,
    required this.venue,
    required this.status,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    this.score,
  });
}
