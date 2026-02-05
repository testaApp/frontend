import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class News {
  @HiveField(0)
  String? figCaption;

  @HiveField(1)
  String? summarized;

  @HiveField(2)
  String? summarizedTitle;

  @HiveField(3)
  String? author;

  @HiveField(4)
  String? source;

  @HiveField(5)
  String? sourcename;

  @HiveField(6)
  String? sourceimage;

  @HiveField(7)
  List<ImageModel> mainImages;

  @HiveField(8)
  String id;

  @HiveField(9)
  String? publishedDate;

  @HiveField(10)
  String? ttsAudio;

  @HiveField(11)
  int? viewCount;

  @HiveField(12)
  bool? pending;

  @HiveField(13)
  bool? isProcessed;

  @HiveField(14)
  bool? breakingNews;

  @HiveField(15)
  String? newsLink;

  @HiveField(16)
  String? category;

  @HiveField(17)
  List<String> teamTags;

  @HiveField(18)
  List<String> leagueTags;

  @HiveField(19)
  List<String> playerTags;

  @HiveField(20)
  String? createdAt;

  @HiveField(21)
  String? updatedAt;

  News({
    required this.id,
    required this.mainImages,
    this.figCaption,
    this.summarized,
    this.summarizedTitle,
    this.author,
    this.source,
    this.sourcename,
    this.sourceimage,
    this.publishedDate,
    this.ttsAudio,
    this.viewCount,
    this.pending,
    this.isProcessed,
    this.breakingNews,
    this.newsLink,
    this.category,
    this.teamTags = const [],
    this.leagueTags = const [],
    this.playerTags = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'figCaption': figCaption,
      'summarized': summarized,
      'summarizedTitle': summarizedTitle,
      'author': author,
      'source': source,
      'sourcename': sourcename,
      'sourceimage': sourceimage,
      'mainImages': mainImages.map((image) => image.toJson()).toList(),
      'id': id,
      'publishedDate': publishedDate,
      'ttsAudio': ttsAudio,
      'viewCount': viewCount,
      'pending': pending,
      'is_processed': isProcessed,
      'breakingNews': breakingNews,
      'newsLink': newsLink,
      'category': category,
      'teamTags': teamTags,
      'leagueTags': leagueTags,
      'playerTags': playerTags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory News.fromJson(Map<String, dynamic> json) {
    List<ImageModel> images = [];
    if (json['mainImages'] is List) {
      images = (json['mainImages'] as List)
          .whereType<Map>()
          .map((imageJson) => ImageModel.fromJson(
                Map<String, dynamic>.from(imageJson),
              ))
          .toList();
    }

    if (images.isEmpty && (json['sourceimage'] ?? '').toString().isNotEmpty) {
      images = [
        ImageModel(
          url: json['sourceimage'] ?? '',
          caption: json['figCaption'] ?? '',
        )
      ];
    }

    return News(
      figCaption: json['figCaption'],
      summarized: json['summarized'],
      summarizedTitle: json['summarizedTitle'],
      author: json['author'],
      source: json['source'],
      sourcename: json['sourcename'],
      sourceimage: json['sourceimage'],
      mainImages: images,
      id: json['id'] ?? '',
      publishedDate: json['publishedDate'],
      ttsAudio: json['ttsAudio'],
      viewCount: json['viewCount'],
      pending: json['pending'],
      isProcessed: json['is_processed'],
      breakingNews: json['breakingNews'],
      newsLink: json['newsLink'],
      category: json['category'],
      teamTags: (json['teamTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      leagueTags: (json['leagueTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      playerTags: (json['playerTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

@HiveType(typeId: 1)
class ImageModel {
  @HiveField(0)
  String url;

  @HiveField(1)
  String caption;

  ImageModel({
    required this.url,
    required this.caption,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] ?? '',
      caption: json['caption'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'caption': caption,
    };
  }
}
