class PostModel {
  final String id;
  final String contentText;
  final String? image;
  final String authors;
  final String datePublished;
  final String accountName;
  final String? previewImage;
  final String? profile_pic;

  PostModel(
      {required this.id,
      required this.contentText,
      this.image,
      required this.authors,
      required this.datePublished,
      this.accountName = '',
      this.previewImage,
      this.profile_pic});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      contentText: json['content_text'] ?? '',
      image: json['image'] ?? '',
      authors: json['authors'][0]['name'] ?? '',
      datePublished: json['date_published'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
    );
  }

  factory PostModel.forTwitter(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      contentText: json['contentText'] ?? '',
      image: json['image'] ?? '',
      authors: json['authors'] ?? json['accountName'] ?? '',
      datePublished: json['datePublished'] ?? '',
      previewImage: json['previewImage'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
    );
  }

  factory PostModel.forTelegram(Map<String, dynamic> json) {
    PostModel post = PostModel(
      id: json['id'] ?? '',
      contentText: json['contentText'] ?? '',
      image: json['image'] ?? '',
      authors: json['authors'] ?? json['accountName'] ?? '',
      datePublished: json['datePublished'] ?? '',
      previewImage: json['previewImage'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
    );

    return post;
  }

  factory PostModel.forFacebook(Map<String, dynamic> json) {
    PostModel facebook = PostModel(
      id: json['id'] ?? '',
      contentText: json['contentText'] ?? '',
      image: json['image'] ?? '',
      authors: json['authors'] ?? json['accountName'] ?? '',
      datePublished: json['datePublished'] ?? '',
      previewImage: json['previewImage'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
    );

    return facebook;
  }

  factory PostModel.fromJsonForInsta(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      contentText: json['contentText'] ?? '',
      image: json['image'] ?? '',
      authors: json['authors'] ?? json['accountName'] ?? '',
      datePublished: json['datePublished'] ?? '',
      previewImage: json['previewImage'] ?? '',
      profile_pic: json['profile_pic'] ?? '',
    );
  }
}

String extractBackgroundImages(jsonObject) {
  final List<String> backgrounds = [];

  try {
    if (jsonObject is Map) {
      _extractBackgroundImagesFromMap(jsonObject, backgrounds);
    }
  } catch (e) {
    // Handle JSON parsing errors if needed
    // //print("JSON parsing error: $e");
  }

  return backgrounds.isNotEmpty ? backgrounds[0] : '';
}

void _extractBackgroundImagesFromMap(
    Map<dynamic, dynamic> jsonMap, List<String> backgrounds) {
  for (final value in jsonMap.values) {
    if (value is String && value.contains('background-image:url')) {
      final match =
          RegExp(r"background-image:url\('([^']+)'\)").firstMatch(value);
      if (match != null) {
        backgrounds.add(match.group(1) ?? '');
      }
    } else if (value is Map) {
      _extractBackgroundImagesFromMap(value, backgrounds);
    }
  }
}
