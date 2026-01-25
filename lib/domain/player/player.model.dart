import '../../models/fixtures/team.dart';
import 'league.dart';

class Player {
  final int? id;
  final String? name;
  final String? firstname;
  final String? lastname;
  final int? age;
  final Birth? birth;
  final String? nationality;
  final String? height;
  final String? weight;
  final bool? injured;
  final String? photo;
  final Team? team;
  final List<dynamic> grid;
  final String? rating;
  final League? league;
  final int? goals;
  final int? appearences;
  final int? assists;
  final Stats? stats;
  final String? season;
  final String? position;
  final int? number;

  // ── NEW FIELD ────────────────────────────────────────────────────────────────
  final Map<String, String>? localized;

  Player({
    this.id,
    this.name,
    this.firstname,
    this.lastname,
    this.age,
    this.birth,
    this.nationality,
    this.height,
    this.weight,
    this.injured,
    this.photo,
    this.team,
    this.grid = const [-1, -1],
    this.rating,
    this.league,
    this.goals,
    this.appearences,
    this.assists,
    this.stats,
    this.season,
    this.position,
    this.number,
    this.localized, // ← optional, safe to omit
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? json['playerId'] ?? 0,
      name: json['name'] ?? json['englishName'] ?? '',
      firstname: json['firstname'],
      lastname: json['lastname'],
      appearences: json['appearences'],
      goals: json['goals'],
      assists: json['assists'],
      age: json['age'],
      birth: json['birth'] != null ? Birth.fromJson(json['birth']) : null,
      nationality: json['nationality'],
      height: json['height'],
      weight: json['weight'],
      number: json['number'],
      injured: json['injured'] ?? false,
      photo: json['photo'],
      grid: json['grid'] != null
          ? json['grid'].split(':').map(int.parse).toList()
          : [-1, -1],
      rating: json['rating'],
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
      league: json['league'] != null ? League.fromJson(json['league']) : null,
      stats: json['stats'] != null ? Stats.fromJson(json['stats']) : null,
      season: json['season'],
      position: json['pos'],

      // ── NEW: Parse localized map if present ───────────────────────────────
      localized: json['localized'] != null
          ? Map<String, String>.from(json['localized'])
          : null,
    );
  }
}

class Birth {
  final String? date;
  final String? place;
  final String? country;

  Birth({
    this.date,
    this.place,
    this.country,
  });

  factory Birth.fromJson(Map<String, dynamic> json) {
    return Birth(
      date: json['date'],
      place: json['place'],
      country: json['country'],
    );
  }
}

// ===========================================

class Stats {
  int? minutes;
  bool? captain;
  Goals? goals;
  Tackles? tackles;
  Shots? shots;
  Dribbles? dribbles;
  Fouls? fouls;
  Cards? cards;

  Stats({
    this.minutes,
    this.captain,
    this.goals,
    this.tackles,
    this.shots,
    this.dribbles,
    this.fouls,
    this.cards,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    print(json);
    // print("==1=1-2-2-2-2-22-2-23-3- for stat");
    return Stats(
      minutes: json['minutes'],
      captain: json['captain'] ?? false,
      goals: json['goals'] == null
          ? null
          : Goals?.fromJson(json['goals'] as Map<String, dynamic>),
      tackles: json['tackles'] == null
          ? null
          : Tackles?.fromJson(json['tackles'] as Map<String, dynamic>),
      shots: json['shots'] == null
          ? null
          : Shots?.fromJson(json['shots'] as Map<String, dynamic>),
      dribbles: json['dribbles'] == null
          ? null
          : Dribbles?.fromJson(json['dribbles'] as Map<String, dynamic>),
      cards: json['cards'] == null
          ? null
          : Cards?.fromJson(json['cards'] as Map<String, dynamic>),
      fouls: json['fouls'] == null
          ? null
          : Fouls?.fromJson(json['fouls'] as Map<String, dynamic>),
    );
  }
}

class Goals {
  int? total;
  int? conceded;
  int? assists;
  int? saves;

  Goals({
    this.total,
    this.conceded,
    this.assists,
    this.saves,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    //print(json);

    //print("-  -  - -  - - -Goooooaaalls");
    return Goals(
      total: json['total'],
      conceded: json['conceded'],
      assists: json['assists'],
      saves: json['saves'],
    );
  }
}

class Tackles {
  int? total;
  int? blocks;
  int? interceptions;

  Tackles({
    this.total,
    this.blocks,
    this.interceptions,
  });

  factory Tackles.fromJson(Map<String, dynamic> json) {
    //print(json);

    //print("-  -  - -  - - -Tackels");
    return Tackles(
      total: json['total'],
      blocks: json['blocks'],
      interceptions: json['interceptions'],
    );
  }
}

class Shots {
  int? total;
  int? on;

  Shots({
    this.total,
    this.on,
  });

  factory Shots.fromJson(Map<String, dynamic> json) {
    //print(json);

    //print("-  -  - -  - - Shots = = = = =");
    return Shots(
      total: json['total'],
      on: json['on'],
    );
  }
}

class Dribbles {
  int? attempts;
  int? success;
  int? past;

  Dribbles({
    this.attempts,
    this.success,
    this.past,
  });

  factory Dribbles.fromJson(Map<String, dynamic> json) {
    //print(json);

    //print("-  -  - -  - - Drivvles");
    return Dribbles(
      attempts: json['attempts'],
      success: json['success'],
      past: json['past'],
    );
  }
}

class Fouls {
  int? drawn;
  int? committed;

  Fouls({
    this.drawn,
    this.committed,
  });

  factory Fouls.fromJson(Map<String, dynamic> json) {
    //print(json);

    //print("-  -  - -  - - -Fouls");
    return Fouls(
      drawn: json['drawn'],
      committed: json['committed'],
    );
  }
}

class Cards {
  int? yellow;
  int? yellowred;
  int? red;

  Cards({
    this.yellow,
    this.yellowred,
    this.red,
  });

  factory Cards.fromJson(Map<String, dynamic> json) {
    //print(json);
    //print("8888888888888888888888888  card -----------");

    return Cards(
      yellow: json['yellow'],
      yellowred: json['yellowred'],
      red: json['red'],
    );
  }
}
