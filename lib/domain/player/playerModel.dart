import 'playerName.dart';

import 'playerStatisticsModel.dart';

class PlayerProfile {
  PlayerName? playerName;

  String? amharicCountryName;

  String? oromoCountryName;

  String? somaliCountryName;

  String? englishCountryName;

  String? amharicNationality;

  String? oromoNationality;

  String? somaliNationality;

  String? englishNationality;

  String? currentTeamLogo;

  int id;

  int? age;

  String? birthDate;

  String? birthPlace;

  String? height;

  String? weight;

  bool? injured;

  String? idteam;

  List<PlayerStatistics> statistics;

  String? photo;

  PlayerProfile(
      {required this.id,
      this.age,
      this.birthDate,
      this.birthPlace,
      this.height,
      this.weight,
      this.injured,
      this.idteam,
      required this.statistics,
      required this.amharicCountryName,
      required this.englishCountryName,
      required this.oromoCountryName,
      required this.somaliCountryName,
      required this.amharicNationality,
      required this.englishNationality,
      required this.oromoNationality,
      required this.somaliNationality,
      required this.photo,
      required this.currentTeamLogo,
      required this.playerName});

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final birthCountry = json['birthCountry'] ?? {};

    final nationality = json['nationality'] ?? {};

    final stats = (json['statistics'] as List? ?? []);

    return PlayerProfile(
      id: json['id'],
      playerName: json['player'] != null
          ? PlayerName(
              amharicName: json['player']['amharicName'],
              oromoName: json['player']['oromoName'],
              somaliName: json['player']['somaliName'],
              englishName: json['player']['englishName'],
              englishFirstName: json['player']['englishFirstName'],
              englishLastName: json['player']['englishLastName'],
              amharicFirstName: json['player']['amharicFirstName'],
              amharicLastName: json['player']['amharicLastName'],
              afanOromoFirstName: json['player']['afanOromoFirstName'],
              afanOromoLastName: json['player']['afanOromoLastName'],
              somaliFirstName: json['player']['somaliFirstName'],
              somaliLastName: json['player']['somaliLastName'],
              photo: json['player']['photo'],
              id: json['id'],
            )
          : null,
      amharicCountryName: birthCountry['AmharicName'],
      oromoCountryName: birthCountry['OromoName'],
      somaliCountryName: birthCountry['SomaliName'],
      englishCountryName: birthCountry['EnglishName'],
      amharicNationality: nationality['AmharicName'],
      oromoNationality: nationality['OromoName'],
      somaliNationality: nationality['SomaliName'],
      englishNationality: nationality['EnglishName'],
      age: json['age'],
      birthDate: json['birthDate'],
      birthPlace: json['birthPlace'],
      height: json['height'],
      weight: json['weight'],
      injured: json['injured'],
      statistics: stats.map((e) => PlayerStatistics.fromJson(e)).toList(),
      photo: json['player'] != null ? json['player']['photo'] : null,
      currentTeamLogo: stats.isNotEmpty && stats[0]['team'] != null
          ? stats[0]['team']['logo']
          : null,
      idteam: stats.isNotEmpty && stats[0]['team'] != null
          ? stats[0]['team']['id'].toString()
          : null,
    );
  }
}
