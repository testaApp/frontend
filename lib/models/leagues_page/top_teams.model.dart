class TopScorerModel {
  String name;
  String pic;
  int goal;

  TopScorerModel({required this.name, required this.pic, required this.goal});

  // This factory constructor is modified to correctly parse a single player's JSON data.
  factory TopScorerModel.fromJson(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  // A helper method to parse the list of players from the 'goals' list in the JSON.
  static List<TopScorerModel> fromJsonList(Map<String, dynamic> json) {
    var list = json['stats']['goals'] as List;
    List<TopScorerModel> playersList =
        list.map((playerJson) => TopScorerModel.fromJson(playerJson)).toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonForAssist(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonAssistList(Map<String, dynamic> json) {
    var list = json['stats']['assists'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonForAssist(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonForPass(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonPassList(Map<String, dynamic> json) {
    var list = json['stats']['passes'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonForAssist(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonMinutes(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonMinutesList(Map<String, dynamic> json) {
    var list = json['stats']['minutesPlayed'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonMinutes(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonShots(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonShotsList(Map<String, dynamic> json) {
    var list = json['stats']['Shots'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonShots(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonWoodwork(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonWoodworkList(Map<String, dynamic> json) {
    var list = json['stats']['Hit woodwork'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonWoodwork(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonThroughball(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonThroughballList(
      Map<String, dynamic> json) {
    var list = json['stats']['Through balls'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonThroughball(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonCrosses(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonCrossesList(Map<String, dynamic> json) {
    var list = json['stats']['Crosses'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonCrosses(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonTackles(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonTacklesList(Map<String, dynamic> json) {
    var list = json['stats']['Tackles'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonTackles(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonBloacks(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonBloacksList(Map<String, dynamic> json) {
    var list = json['stats']['Blocks'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonBloacks(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonClearance(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonClearanceList(Map<String, dynamic> json) {
    var list = json['stats']['Clearances'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonClearance(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonHeaded(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonHeadedList(Map<String, dynamic> json) {
    var list = json['stats']['Headed clearances'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonHeaded(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonCleenSheet(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonCleenSheetList(
      Map<String, dynamic> json) {
    var list = json['stats']['Clean sheets'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonCleenSheet(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonSaves(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonSavesList(Map<String, dynamic> json) {
    var list = json['stats']['Saves'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonSaves(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonPunches(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonPunchesList(Map<String, dynamic> json) {
    var list = json['stats']['Punches'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonPunches(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonGoalsConceded(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonGoalsConcededList(
      Map<String, dynamic> json) {
    var list = json['stats']['Goal Conceded'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonGoalsConceded(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonForCards(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonYellowList(Map<String, dynamic> json) {
    var list = json['stats']['assists'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonForAssist(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonForredCards(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonRedList(Map<String, dynamic> json) {
    var list = json['stats']['Red cards'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonForAssist(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonFouls(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonFoulsList(Map<String, dynamic> json) {
    var list = json['stats']['Fouls'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonFouls(playerJson))
        .toList();
    return playersList;
  }

  factory TopScorerModel.fromJsonoffsides(Map<String, dynamic> json) {
    return TopScorerModel(
      // Accessing the integer value correctly from the structured JSON.
      goal: json['goals'] ?? 0,
      name: json['englishName'] ?? '',
      pic: json['teamLogo'] ?? '',
    );
  }

  static List<TopScorerModel> fromJsonoffsidesList(Map<String, dynamic> json) {
    var list = json['stats']['offsides'] as List;
    List<TopScorerModel> playersList = list
        .map((playerJson) => TopScorerModel.fromJsonoffsides(playerJson))
        .toList();
    return playersList;
  }
}
