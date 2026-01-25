class SongModel {
  final int id;
  final String title;
  final String artist;

  final String uri;
  final int? duration;
  final String avatar;
  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.avatar,
    required this.uri,
    this.duration,
  });
}
