class VideosModel {
  final String youtubeHighlightVtitle;
  final String youtubeHighlightVid;
  final String youtubeHighlightThumbnail;
  final String catagory;
  final String youtubeHighlightDate;

  VideosModel({
    required this.youtubeHighlightVtitle,
    required this.youtubeHighlightVid,
    required this.youtubeHighlightThumbnail,
    required this.catagory,
    required this.youtubeHighlightDate,
  });

  factory VideosModel.fromJson(json) => VideosModel(
        youtubeHighlightVtitle: json['VideoTitle'] ?? '',
        youtubeHighlightVid: json['VideoId'] ?? '',
        youtubeHighlightThumbnail: json['Thumbnail'] ?? '',
        youtubeHighlightDate: json['date'] ?? '',
        catagory: json['catagory'] ?? '',
      );
}
