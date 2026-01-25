class League {
  League({required this.id, this.name, this.country, this.logo});
  final int id;
  final String? name;
  final String? country;
  final String? logo;

  factory League.fromJson(json) => League(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      logo: json['logo']);
}
