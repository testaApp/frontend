class TopScorerModel {
  PlayerName name;
  String pic;
  int value;
  int? goals;
  int? assists;
  int? yellow;
  int? red;
  int? penality;
  String teamLogo;

  int get goal => goals ?? value;

  TopScorerModel({
    required this.name,
    required this.pic,
    required this.value,
    this.goals,
    this.assists,
    this.yellow,
    this.red,
    this.penality,
    required this.teamLogo,
  });

  factory TopScorerModel.fromJson(Map<String, dynamic> json,
      {String valueKey = 'goals'}) {
    return TopScorerModel(
      value: valueKey == 'assists'
          ? int.tryParse(json['assists']?.toString() ?? '0') ?? 0
          : int.tryParse(json[valueKey]?.toString() ?? '0') ?? 0,
      name: PlayerName(
        amharicName: json['amharicName'] ?? '',
        englishName: json['englishName'] ?? json['playerName'] ?? '',
        oromoName: json['oromoName'] ?? '',
        somaliName: json['somaliName'] ?? '',
        tigrignaName: json['tigrignaName'] ?? '',
      ),
      pic: json['photo'] ?? '',
      goals: int.tryParse(json['goals']?.toString() ?? '0'),
      assists: int.tryParse(json['assists']?.toString() ?? '0'),
      yellow: int.tryParse(json['yellow']?.toString() ?? '0'),
      red: int.tryParse(json['red']?.toString() ?? '0'),
      penality: int.tryParse(json['penality']?.toString() ?? '0'),
      teamLogo: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonList(
      Map<String, dynamic> json, String statKey,
      {String valueKey = 'goals'}) {
    try {
      // First try to get from scorers array
      final scorers = json['scorers'] as List?;
      if (scorers != null) {
        var players = scorers
            .map((playerJson) =>
                TopScorerModel.fromJson(playerJson, valueKey: valueKey))
            .toList();

        // Sort by the specified valueKey in descending order
        players.sort((a, b) {
          if (valueKey == 'assists') {
            return (b.assists ?? 0).compareTo(a.assists ?? 0);
          }
          return (b.value).compareTo(a.value);
        });

        return players;
      }

      // Fallback to stats structure if scorers is not available
      final stats = json['stats'];
      if (stats == null) return [];

      final list = stats[statKey] as List?;
      if (list == null) return [];

      return list
          .map((playerJson) =>
              TopScorerModel.fromJson(playerJson, valueKey: valueKey))
          .toList();
    } catch (e) {
      print('Error parsing $statKey list: $e');
      return [];
    }
  }

  // Predefined methods for specific stats
  static List<TopScorerModel> fromJsonGoalList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Goals', valueKey: 'goals');

  static List<TopScorerModel> fromJsonAssistList(Map<String, dynamic> json) =>
      fromJsonList(json, 'assists', valueKey: 'assists');

  static List<TopScorerModel> fromJsonPassList(Map<String, dynamic> json) =>
      fromJsonList(json, 'passes', valueKey: 'passes');

  static List<TopScorerModel> fromJsonMinutesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'minutesPlayed');
  static List<TopScorerModel> fromJsonShotsList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Shots');
  static List<TopScorerModel> fromJsonWoodworkList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Hit woodwork');
  static List<TopScorerModel> fromJsonThroughballList(
          Map<String, dynamic> json) =>
      fromJsonList(json, 'Through balls');
  static List<TopScorerModel> fromJsonCrossesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Crosses');
  static List<TopScorerModel> fromJsonTacklesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Tackles');
  static List<TopScorerModel> fromJsonBlocksList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Blocks');
  static List<TopScorerModel> fromJsonClearanceList(
          Map<String, dynamic> json) =>
      fromJsonList(json, 'Clearances');
  static List<TopScorerModel> fromJsonHeadedList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Headed clearances');
  static List<TopScorerModel> fromJsonCleanSheetsList(
          Map<String, dynamic> json) =>
      fromJsonList(json, 'Clean sheets');
  static List<TopScorerModel> fromJsonSavesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Saves');
  static List<TopScorerModel> fromJsonPunchesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Punches');
  static List<TopScorerModel> fromJsonGoalsConcededList(
          Map<String, dynamic> json) =>
      fromJsonList(json, 'Goal conceded');
  static List<TopScorerModel> fromJsonYellowcardList(
          Map<String, dynamic> json) =>
      fromJsonList(json, 'Yellow cards');
  static List<TopScorerModel> fromJsonRedList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Red cards');
  static List<TopScorerModel> fromJsonFoulsList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Fouls');
  static List<TopScorerModel> fromJsonOffsidesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Offsides');
  static List<TopScorerModel> fromJsonWinsList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Wins', valueKey: 'goals');
  static List<TopScorerModel> fromJsonLossesList(Map<String, dynamic> json) =>
      fromJsonList(json, 'Losses', valueKey: 'goals');
}

class PlayerName {
  final String? amharicName;
  final String? englishName;
  final String? oromoName;
  final String? somaliName;
  final String? tigrignaName;

  PlayerName({
    this.amharicName,
    this.englishName,
    this.oromoName,
    this.somaliName,
    this.tigrignaName,
  });
}
