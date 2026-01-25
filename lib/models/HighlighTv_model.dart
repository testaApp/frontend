import '../main.dart'; // Assuming this has localLanguageNotifier

class Highlight {
  final String? id;
  final String? video;
  final int? position;
  final String? descriptionEn;
  final String? descriptionAm;
  final String? descriptionOr;
  final String? descriptionSo;
  final League? league; // Full league details (replaces playlist)

  // Computed: current language description
  String? get description {
    final language = localLanguageNotifier.value;
    switch (language) {
      case 'am':
        return descriptionAm;
      case 'or':
        return descriptionOr;
      case 'so':
        return descriptionSo;
      default:
        return descriptionEn;
    }
  }

  Highlight({
    this.id,
    this.video,
    this.position,
    this.descriptionEn,
    this.descriptionAm,
    this.descriptionOr,
    this.descriptionSo,
    this.league,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['_id']?.toString(),
      video: json['video'],
      position: json['position'],
      descriptionEn: json['descriptionEn'],
      descriptionAm: json['descriptionAm'],
      descriptionOr: json['descriptionOr'],
      descriptionSo: json['descriptionSo'],
      league: json['league'] != null ? League.fromJson(json['league']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'video': video,
      'position': position,
      'descriptionEn': descriptionEn,
      'descriptionAm': descriptionAm,
      'descriptionOr': descriptionOr,
      'descriptionSo': descriptionSo,
      'league': league?.toJson(),
    };
  }
}

class League {
  final String? id;
  final String? photo;
  final int? leagueId;
  final String? leagueName; // Main name (fallback)
  final String? leagueNameEn;
  final String? leagueNameAm;
  final String? leagueNameOr;
  final String? leagueNameSo;
  final String? leagueNameTr;

  League({
    this.id,
    this.photo,
    this.leagueId,
    this.leagueName,
    this.leagueNameEn,
    this.leagueNameAm,
    this.leagueNameOr,
    this.leagueNameSo,
    this.leagueNameTr,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['_id']?.toString(),
      photo: json['photo'],
      leagueId: json['LeagueId'],
      leagueName: json['LeagueName'],
      leagueNameEn: json['LeagueName_en'],
      leagueNameAm: json['LeagueName_am'],
      leagueNameOr: json['LeagueName_or'],
      leagueNameSo: json['LeagueName_so'],
      leagueNameTr: json['LeagueName_tr'],
    );
  }

  /// Returns league name in the user's current language
  String? getName(String language) {
    switch (language) {
      case 'am':
        return leagueNameAm?.isNotEmpty == true ? leagueNameAm : leagueNameEn;
      case 'or':
        return leagueNameOr?.isNotEmpty == true ? leagueNameOr : leagueNameEn;
      case 'so':
        return leagueNameSo?.isNotEmpty == true ? leagueNameSo : leagueNameEn;
      case 'tr':
        return leagueNameTr?.isNotEmpty == true ? leagueNameTr : leagueNameEn;
      default:
        return leagueNameEn;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'photo': photo,
      'LeagueId': leagueId,
      'LeagueName': leagueName,
      'LeagueName_en': leagueNameEn,
      'LeagueName_am': leagueNameAm,
      'LeagueName_or': leagueNameOr,
      'LeagueName_so': leagueNameSo,
      'LeagueName_tr': leagueNameTr,
    };
  }
}
