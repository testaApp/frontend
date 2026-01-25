class PlayerPreference {
  final String name;
  final String imageUrl;
  final int league;
  final int season;

  PlayerPreference({
    required this.name,
    required this.imageUrl,
    required this.league,
    required this.season,
  });

  factory PlayerPreference.fromJson(Map<String, dynamic> json) {
    return PlayerPreference(
      name: json['name'],
      imageUrl: json['image'],
      league: json['league'],
      season: json['season'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': imageUrl,
      'league': league,
      'season': season,
    };
  }
}
