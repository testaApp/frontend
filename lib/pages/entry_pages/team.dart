class FavTeamsData {
  final int leagueId;
  final int teamId;
  final String name;
  final String Amharicname;
  final String Oromoname;
  final String Somaliname;
  final String Tigrignaname;
  final String logo;
  final int rank;

  FavTeamsData({
    required this.Amharicname,
    required this.Oromoname,
    required this.Somaliname,
    required this.Tigrignaname,
    required this.teamId,
    required this.name,
    required this.logo,
    required this.leagueId,
    required this.rank,
  });

  factory FavTeamsData.fromJson(Map<String, dynamic> json) {
    return FavTeamsData(
      teamId: json['teamData']['id'] ?? 0,
      name: json['teamData']['EnglishName'] ?? '',
      Amharicname: json['teamData']['AmharicName'] ?? '',
      Oromoname: json['teamData']['OromoName'] ?? '',
      Somaliname: json['teamData']['SomaliName'] ?? '',
      Tigrignaname:
          json['teamData']['TigrignaName'] ?? '', // Ensure correct key
      logo: json['teamData']['logo'] ?? '',
      rank: json['rank'] ?? 0,
      leagueId: json['leagueId'] ?? 0,
    );
  }
}
