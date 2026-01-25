class PlaylistModel {
  PlaylistModel(
      {
      // required this.podcastId,
      required this.title,
      required this.audioUrl,
      required this.avatar,
      this.journalist = 'መንሱር አብዱልቀኒ',
      required this.id,
      required this.station});

  // final String podcastId;
  final String title;
  final String audioUrl;
  final String avatar;
  final String journalist;
  final String id;
  final String station;
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    // //print(json);
    return PlaylistModel(
        // podcastId: json['podcastId'] as String,
        title: json['title'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        avatar: json['avatar'] ?? '',
        journalist: json['journalist'] ?? '',
        id: json['audioUrl'],
        station: json['station'] ?? '');
  }
  factory PlaylistModel.fromJsonWithAvatar(
      Map<String, dynamic> json, String avatarName) {
    // //print(json);
    return PlaylistModel(
        // podcastId: json['podcastId'] as String,
        title: json['title'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        avatar: avatarName,
        journalist: json['journalist'] ?? '',
        id: json['audioUrl'],
        station: json['station'] ?? '');
  }
}
