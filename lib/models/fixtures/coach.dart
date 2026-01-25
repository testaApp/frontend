class Coach {
  Coach({
    required this.name,
    required this.id,
    required this.photo,
  });

  final String name;
  final int id;
  final String photo;

  factory Coach.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Coach(
        id: 0,
        name: 'Unknown',
        photo: '',
      );
    }
    return Coach(
      name: json['name'] ?? 'Unknown',
      photo: json['photo'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
