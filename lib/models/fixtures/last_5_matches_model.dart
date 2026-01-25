class LastFiveMatchesByLeague {
  final int leagueId;
  final String leagueName;
  final List<LastFiveMatch> matches;

  LastFiveMatchesByLeague({
    required this.leagueId,
    required this.leagueName,
    required this.matches,
  });

  factory LastFiveMatchesByLeague.fromJson(Map<String, dynamic> json) {
    return LastFiveMatchesByLeague(
      leagueId: json['leagueId'] is int ? json['leagueId'] : 0,
      leagueName: json['leagueName']?.toString() ?? '',
      matches: (json['matches'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LastFiveMatch.fromJson)
          .toList(),
    );
  }
}

class LastFiveMatch {
  final String id;
  final String date;
  final String venue;
  final String leagueName;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int? scoreHome;
  final int? scoreAway;

  LastFiveMatch({
    required this.id,
    required this.date,
    required this.venue,
    required this.leagueName,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    this.scoreHome,
    this.scoreAway,
  });

  factory LastFiveMatch.fromJson(Map<String, dynamic> json) {
    return LastFiveMatch(
      id: json['_id']?.toString() ?? '',
      date: json['dateOnly']?.toString() ?? '',
      venue: json['venue']?['name']?.toString() ?? '',
      leagueName: json['league']?['name']?.toString() ?? '',
      homeTeamId: json['homeTeam']?['id']?.toString() ?? '', // Use numeric ID
      awayTeamId: json['awayTeam']?['id']?.toString() ?? '', // Use numeric ID
      homeTeam: json['homeTeam']?['EnglishName']?.toString() ?? '',
      awayTeam: json['awayTeam']?['EnglishName']?.toString() ?? '',
      homeTeamLogo: json['homeTeam']?['logo']?.toString() ?? '',
      awayTeamLogo: json['awayTeam']?['logo']?.toString() ?? '',
      scoreHome: json['goals']?['home'] is int ? json['goals']['home'] : null,
      scoreAway: json['goals']?['away'] is int ? json['goals']['away'] : null,
    );
  }
}
