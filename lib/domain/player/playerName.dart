class PlayerName {
  String amharicName;
  String oromoName;
  String englishName;
  String somaliName;

  String? englishFirstName;
  String? englishLastName;
  String? amharicFirstName;
  String? amharicLastName;
  String? afanOromoFirstName;
  String? afanOromoLastName;
  String? somaliFirstName;
  String? somaliLastName;

  String? photo;
  int? number;
  int id;
  int? age;
  String? position;
  int? apperance;
  int? subdout;

  PlayerName({
    required this.amharicName,
    required this.oromoName,
    required this.somaliName,
    required this.englishName,
    required this.id,
    this.photo,
    this.number,
    this.age,
    this.position,
    this.apperance,
    this.subdout,
    this.englishFirstName,
    this.englishLastName,
    this.amharicFirstName,
    this.amharicLastName,
    this.afanOromoFirstName,
    this.afanOromoLastName,
    this.somaliFirstName,
    this.somaliLastName,
  });

  factory PlayerName.fromJson(Map<String, dynamic> json) {
    // Handle cases where the player data is nested under 'player' key (common in events)
    final playerData = json['player'] ?? json;

    // Extract the raw name from the API (this is the actual player name like "Jhon Arias")
    final String apiName = (playerData['name'] ?? '').toString().trim();

    // Fallback to 'Unknown Player' if no name at all
    final String fallbackName = apiName.isEmpty ? 'Unknown Player' : apiName;

    return PlayerName(
      id: playerData['id'] ?? 0,

      // Priority: custom translated name → otherwise use API's original name
      englishName:
          (playerData['englishName'] ?? '').toString().trim().isNotEmpty
              ? playerData['englishName'].toString().trim()
              : fallbackName,

      amharicName: (playerData['amharicName'] ?? '').toString().trim(),
      oromoName: (playerData['oromoName'] ?? '').toString().trim(),
      somaliName: (playerData['somaliName'] ?? '').toString().trim(),

      photo: (playerData['photo'] ?? json['photo'] ?? '').toString().trim(),
      number: playerData['number'] is int ? playerData['number'] : null,
      age: playerData['age'] is int ? playerData['age'] : null,
      position: (playerData['pos'] ?? playerData['player_positions'] ?? '')
          .toString()
          .trim(),
      apperance:
          playerData['apperance'] is int ? playerData['apperance'] : null,
      subdout: playerData['subdout'] is int ? playerData['subdout'] : null,

      // Optional first/last names
      englishFirstName: playerData['englishFirstName']?.toString().trim(),
      englishLastName: playerData['englishLastName']?.toString().trim(),
      amharicFirstName: playerData['amharicFirstName']?.toString().trim(),
      amharicLastName: playerData['amharicLastName']?.toString().trim(),
      afanOromoFirstName: playerData['afanOromoFirstName']?.toString().trim(),
      afanOromoLastName: playerData['afanOromoLastName']?.toString().trim(),
      somaliFirstName: playerData['somaliFirstName']?.toString().trim(),
      somaliLastName: playerData['somaliLastName']?.toString().trim(),
    );
  }

  /// Returns the appropriate name based on current app language
  String get name {
    if (amharicName.isNotEmpty) return amharicName;
    if (oromoName.isNotEmpty) return oromoName;
    if (somaliName.isNotEmpty) return somaliName;
    if (englishName.isNotEmpty) return englishName;
    return 'Unknown Player';
  }

  @override
  String toString() {
    return 'PlayerName{id: $id, name: "$name", english: "$englishName", amharic: "$amharicName", number: $number}';
  }
}
