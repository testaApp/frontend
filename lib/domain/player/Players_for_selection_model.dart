class PlayerSelectionModel {
  final int id;
  final String photo;
  final String gameRating;
  final String amharicName;
  final String englishName;
  final String somaliName;
  final String oromoName;
  final PlayerSelectionTeam team;
  final bool popular;

  PlayerSelectionModel({
    required this.id,
    required this.photo,
    required this.gameRating,
    required this.amharicName,
    required this.englishName,
    required this.somaliName,
    required this.oromoName,
    required this.team,
    required this.popular,
  });

  factory PlayerSelectionModel.fromJson(Map<String, dynamic> json) {
    return PlayerSelectionModel(
      id: json['id'] ?? 0,
      photo: json['photo'] ?? '',
      gameRating: json['gameRating'] ?? '0.0',
      amharicName: json['amharicName'] ?? '',
      englishName: json['englishName'] ?? '',
      somaliName: json['somaliName'] ?? '',
      oromoName: json['oromoName'] ?? '',
      team: PlayerSelectionTeam.fromJson(json['team'] ?? {}),
      popular:
          json['popular'] == true, // Handles null, false, or missing → false
    );
  }

  @override
  String toString() {
    return 'PlayerSelectionModel(id: $id, englishName: "$englishName", popular: $popular)';
  }

  // Optional: Helpful when debugging lists
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerSelectionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PlayerSelectionTeam {
  final int id;
  final String logo;
  final String amharicName;
  final String englishName;
  final String somaliName;
  final String oromoName;

  PlayerSelectionTeam({
    required this.id,
    required this.logo,
    required this.amharicName,
    required this.englishName,
    required this.somaliName,
    required this.oromoName,
  });

  factory PlayerSelectionTeam.fromJson(Map<String, dynamic> json) {
    return PlayerSelectionTeam(
      id: json['id'] ?? 0,
      logo: json['logo'] ?? '',
      amharicName: json['amharicName'] ?? '',
      englishName: json['englishName'] ?? '',
      somaliName: json['somaliName'] ?? '',
      oromoName: json['oromoName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PlayerSelectionTeam(id: $id, englishName: "$englishName")';
  }
}
