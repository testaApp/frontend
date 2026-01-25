class TeamInfo {
  final Team? team;
  final Venue? venue;

  TeamInfo({this.team, this.venue});

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      team: Team.fromJson(json['team'] as Map<String, dynamic>),
      venue: Venue.fromJson(json['venue'] as Map<String, dynamic>),
    );
  }
}

class Team {
  final int? id;
  final String? name;
  final String? code;
  final String? country;
  final int? founded;
  final bool? national;
  final String? logo;

  Team({
    this.id,
    this.name,
    this.code,
    this.country,
    this.founded,
    this.national,
    this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      country: json['country'] as String?,
      founded: json['founded'] as int?,
      national: json['national'] as bool?,
      logo: json['logo'] as String?,
    );
  }
}

class Venue {
  final int? id;
  final String? name;
  final String? address;
  final String? city;
  final int? capacity;
  final String? surface;
  final String? image;

  Venue({
    this.id,
    this.name,
    this.address,
    this.city,
    this.capacity,
    this.surface,
    this.image,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      capacity: json['capacity'] as int?,
      surface: json['surface'] as String?,
      image: json['image'] as String?,
    );
  }
}
