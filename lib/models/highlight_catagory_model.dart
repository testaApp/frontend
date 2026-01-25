class Category {
  final String name;
  final String photo;

  Category({required this.name, required this.photo});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}
