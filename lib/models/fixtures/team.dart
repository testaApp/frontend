class Team {
  int id;
  String? name;
  String? logo;
  bool? winner;
  int? goal;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    this.winner,
    this.goal,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    //print(json);
    return Team(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      winner: json['winner'],
      goal: json['goal'],
    );
  }
}
