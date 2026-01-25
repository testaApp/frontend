class LivetvModel {
  final String id; // MongoDB automatically adds this
  final String tvgId;
  final String? tvgLogo;
  final String? groupTitle;
  final String title;
  final String url;
  final DateTime? updatedAt;

  LivetvModel({
    required this.id,
    required this.tvgId,
    this.tvgLogo,
    this.groupTitle,
    required this.title,
    required this.url,
    this.updatedAt,
  });

  factory LivetvModel.fromJson(Map<String, dynamic> json) {
    return LivetvModel(
      id: json['_id'] ?? '', // MongoDB uses '_id' for the document ID
      tvgId: json['tvg_id'] ?? '',
      tvgLogo: json['tvg_logo'],
      groupTitle: json['group_title'],
      title: json['title'] ?? 'Untitled',
      url: json['url'] ?? '',
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tvg_id': tvgId,
      'tvg_logo': tvgLogo,
      'group_title': groupTitle,
      'title': title,
      'url': url,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
