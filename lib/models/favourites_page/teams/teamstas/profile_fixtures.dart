class ProfileFixtures {
  final int? playedHome;
  final int? playedAway;
  final int? playedTotal;
  final int? winsHome;
  final int? winsAway;
  final int? winsTotal;
  final int? drawsHome;
  final int? drawsAway;
  final int? drawsTotal;
  final int? losesHome;
  final int? losesAway;
  final int? losesTotal;

  ProfileFixtures({
    this.playedHome,
    this.playedAway,
    this.playedTotal,
    this.winsHome,
    this.winsAway,
    this.winsTotal,
    this.drawsHome,
    this.drawsAway,
    this.drawsTotal,
    this.losesHome,
    this.losesAway,
    this.losesTotal,
  });

  factory ProfileFixtures.fromJson(Map<String, dynamic> json) {
    return ProfileFixtures(
      playedHome: json['played']['home'],
      playedAway: json['played']['away'],
      playedTotal: json['played']['total'],
      winsHome: json['wins']['home'],
      winsAway: json['wins']['away'],
      winsTotal: json['wins']['total'],
      drawsHome: json['draws']['home'],
      drawsAway: json['draws']['away'],
      drawsTotal: json['draws']['total'],
      losesHome: json['loses']['home'],
      losesAway: json['loses']['away'],
      losesTotal: json['loses']['total'],
    );
  }
}
