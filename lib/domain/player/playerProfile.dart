import 'package:intl/intl.dart';

class Profile {
  int? playerId;
  String? firstname;
  String? name;
  String? lastname;
  int? age;
  int? leagueid;
  String? season;
  Birth? birth;
  String? nationality;
  String? height;
  String? weight;
  bool? injured;
  String? photo;
  Team? team;
  League? league;
  int? appearences;
  int? goals;
  int? assists;
  String? rating;
  String? position;
  Stats? stats;

  Profile({
    this.playerId,
    this.firstname,
    this.name,
    this.lastname,
    this.age,
    this.leagueid,
    this.season,
    this.birth,
    this.nationality,
    this.height,
    this.team,
    this.weight,
    this.injured,
    this.photo,
    this.league,
    this.appearences,
    this.goals,
    this.assists,
    this.rating,
    this.position,
    this.stats,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      playerId: json['playerId'],
      firstname: json['firstname'],
      name: json['name'],
      lastname: json['lastname'],
      age: json['age'],
      leagueid: json['leagueid'],
      team: Team.fromJson(json['team'] as Map<String, dynamic>),
      season: json['season'],
      birth: Birth.fromJson(json['birth'] as Map<String, dynamic>),
      nationality: json['nationality'],
      height: json['height'],
      weight: json['weight'],
      injured: json['injured'],
      photo: json['photo'],
      league: League.fromJson(json['league'] as Map<String, dynamic>),
      appearences: json['appearences'],
      goals: json['goals'],
      assists: json['assists'],
      rating: json['rating'],
      position: json['position'],
      stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }
}

class Birth {
  String? date;
  String? place;
  String? country;

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

  String getFormattedDate() {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date!);
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
    return '';
  }
}

class League {
  int? id;
  String? name;
  String? country;
  String? logo;
  String? flag;
  int? season;

  League({
    this.id,
    this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      logo: json['logo'],
      flag: json['flag'],
      season: json['season'],
    );
  }
}

class Team {
  int? id;
  String? name;
  String? logo;
  String? shortName;

  Team({this.id, this.name = '', this.logo = '', this.shortName = ''});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
        id: json['id'],
        name: json['name'],
        logo: json['logo'],
        shortName: json['shortName']);
  }
}

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
    return Stats(
      minutes: json['minutes'],
      captain: json['captain'],
      goals: Goals?.fromJson(json['goals'] as Map<String, dynamic>),
      tackles: Tackles?.fromJson(json['tackles'] as Map<String, dynamic>),
      shots: Shots?.fromJson(json['shots'] as Map<String, dynamic>),
      dribbles: Dribbles?.fromJson(json['dribbles'] as Map<String, dynamic>),
      fouls: Fouls?.fromJson(json['fouls'] as Map<String, dynamic>),
      cards: Cards?.fromJson(json['cards'] as Map<String, dynamic>),
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
    return Cards(
      yellow: json['yellow'],
      yellowred: json['yellowred'],
      red: json['red'],
    );
  }
}
