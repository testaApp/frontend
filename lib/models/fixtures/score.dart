import 'score_details.dart';

class Score {
  ScoreDetails halftime;
  ScoreDetails fulltime;
  ScoreDetails extratime;
  ScoreDetails penalty;

  Score({
    required this.halftime,
    required this.fulltime,
    required this.extratime,
    required this.penalty,
  });
}
