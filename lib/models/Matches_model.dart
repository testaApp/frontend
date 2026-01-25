class Matches_model {
  final String date;
  final String venue;
  final String status;
  final String league;
  final int? leagueId; // ADD THIS
  final int scoreHome;
  final int scoreAway;
  final int id;
  final String logo;
  final String homeTeam;
  final String awayTeam;
  final String homeTeam_am;
  final String awayTeam_am;
  final String homeTeam_or;
  final String awayTeam_or;
  final String homeTeam_ti;
  final String awayTeam_ti;
  final String homeTeam_so;
  final String awayTeam_so;
  final String youtubeHighlightVtitle;
  final String youtubeHighlightVid;
  final String youtubeHighlightThumbnail;
  String? hometeamlogo;
  String? awayteamlogo;
  final int hometeamId;
  final int awayteamId;
  final String? extraTime;

  Matches_model({
    required this.homeTeam_am,
    required this.awayTeam_am,
    required this.homeTeam_or,
    required this.awayTeam_or,
    required this.homeTeam_ti,
    required this.awayTeam_ti,
    required this.homeTeam_so,
    required this.awayTeam_so,
    required this.date,
    required this.venue,
    required this.status,
    required this.league,
    this.leagueId, // ADD THIS
    required this.id,
    required this.logo,
    required this.homeTeam,
    required this.scoreHome,
    required this.scoreAway,
    required this.awayTeam,
    required this.youtubeHighlightVtitle,
    required this.youtubeHighlightVid,
    required this.youtubeHighlightThumbnail,
    this.hometeamlogo,
    this.awayteamlogo,
    required this.hometeamId,
    required this.awayteamId,
    this.extraTime,
  });

  factory Matches_model.fromJson(json) => Matches_model(
        id: json['id'] ?? 0,
        date: json['date'] ?? '',
        venue: json['venue']['name'] ?? '',
        status: json['status']['short'] ?? '',
        league: json['league']['name'] ?? '',
        leagueId: json['league']['id'], // ADD THIS LINE
        logo: json['league']['logo'] ?? '',
        scoreHome: json['goals']['home'] ?? 0,
        scoreAway: json['goals']['away'] ?? 0,
        homeTeam: json['homeTeam']['EnglishName'] ?? '',
        awayTeam: json['awayTeam']['EnglishName'] ?? '',
        homeTeam_am: json['homeTeam']['AmharicName'] ?? '',
        homeTeam_or: json['homeTeam']['OromoName'] ?? '',
        homeTeam_so: json['homeTeam']['SomaliName'] ?? '',
        homeTeam_ti: json['homeTeam']['AmharicName'] ?? '',
        hometeamlogo: json['homeTeam']['logo'] ?? '',
        awayTeam_am: json['awayTeam']['AmharicName'] ?? '',
        awayTeam_or: json['awayTeam']['OromoName'] ?? '',
        awayTeam_so: json['awayTeam']['SomaliName'] ?? '',
        awayTeam_ti: json['awayTeam']['AmharicName'] ?? '',
        awayteamlogo: json['awayTeam']['logo'] ?? '',
        youtubeHighlightVtitle: json['youtubeHighlight']?['VideoTitle'] ?? '',
        youtubeHighlightVid: json['youtubeHighlight']?['VideoId'] ?? '',
        youtubeHighlightThumbnail: json['youtubeHighlight']?['Thumbnail'] ?? '',
        hometeamId: json['homeTeam']['id'] ?? 0,
        awayteamId: json['awayTeam']['id'] ?? 0,
        extraTime: json['extraTime'],
      );
}
