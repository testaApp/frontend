class TeamName {
  String amharicName;
  String oromoName;
  String englishName;
  String somaliName;
  String logo;
  int id;
  String? shortName;
  String? id_;
  String? venuename;
  String? venueimage;
  String? venueaddress;
  String? venuecapacity;
  String? venuecity;
  String? founded;
  String? venuesurface;

  TeamName({
    required this.amharicName,
    required this.englishName,
    required this.oromoName,
    required this.somaliName,
    required this.logo,
    required this.id,
    this.shortName,
    this.id_,
    this.venuename,
    this.venueimage,
    this.venueaddress,
    this.venuecapacity,
    this.venuecity,
    this.founded,
    this.venuesurface,
  });

  factory TeamName.fromJson(Map<String, dynamic> json) {
    return TeamName(
      id_: json['_id'],
      id: json['id'] ?? 0,
      amharicName: json['AmharicName'] ?? '',
      oromoName: json['OromoName'] ?? '',
      somaliName: json['SomaliName'] ?? '',
      englishName: json['EnglishName'] ?? '',
      logo: json['logo'] ?? 'assets/club-icon.png',
      shortName: json['shortName'],
      venuename: json['venuename'],
      venueimage: json['venueimage'],
      venueaddress: json['venueaddress'],
      venuecapacity: json['venuecapacity'],
      venuecity: json['venuecity'],
      founded: json['founded'],
      venuesurface: json['venuesurface'],
    );
  }
}
