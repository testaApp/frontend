import 'playerStatisticsModel.dart';

class PlayerProfileNew {
  final int id;
  final PlayerName player;
  final Country birthCountry;
  final Country nationality;
  final int age;
  final String birthDate;
  final String birthPlace;
  final String height;
  final String weight;
  final bool injured;
  final List<PlayerStatistics> statistics;

  PlayerProfileNew({
    required this.id,
    required this.player,
    required this.birthCountry,
    required this.nationality,
    required this.age,
    required this.birthDate,
    required this.birthPlace,
    required this.height,
    required this.weight,
    required this.injured,
    required this.statistics,
  });

  factory PlayerProfileNew.fromJson(Map<String, dynamic> json) {
    return PlayerProfileNew(
      id: json['id'] ?? 0,
      player: PlayerName.fromJson(json['player'] ?? {}),
      birthCountry: Country.fromJson(json['birthCountry'] ?? {}),
      nationality: Country.fromJson(json['nationality'] ?? {}),
      age: json['age'] ?? 0,
      birthDate: json['birthDate'] ?? '',
      birthPlace: json['birthPlace'] ?? '',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      injured: json['injured'] ?? false,
      statistics: (json['statistics'] as List<dynamic>?)
              ?.map((stat) => PlayerStatistics.fromJson(stat))
              .toList() ??
          [],
    );
  }
}

class PlayerName {
  final String amharicName;
  final String englishName;
  final String oromoName;
  final String somaliName;
  final String photo;

  PlayerName({
    required this.amharicName,
    required this.englishName,
    required this.oromoName,
    required this.somaliName,
    required this.photo,
  });

  factory PlayerName.fromJson(Map<String, dynamic> json) {
    return PlayerName(
      amharicName: json['amharicName'] ?? '',
      englishName: json['englishName'] ?? '',
      oromoName: json['oromoName'] ?? '',
      somaliName: json['somaliName'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class Country {
  final String amharicName;
  final String englishName;
  final String oromoName;
  final String somaliName;

  Country({
    required this.amharicName,
    required this.englishName,
    required this.oromoName,
    required this.somaliName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      amharicName: json['amharicName'] ?? '',
      englishName: json['englishName'] ?? '',
      oromoName: json['oromoName'] ?? '',
      somaliName: json['somaliName'] ?? '',
    );
  }
}
