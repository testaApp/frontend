import 'dart:math';

import '../../../main.dart';

class PodcastModel {
  PodcastModel({
    required this.name,
    required this.station,
    required this.avatar,
    required this.program,
    required this.liveLink,
    required this.id,
    required this.programId,
    this.isLive = false, // Default to false
    required this.rssLink,
    this.description,
    this.newpodcast = false,
  });

  final String name;
  final String station;
  final String avatar;
  final String program;
  final String liveLink;
  final bool isLive;
  final String id;
  final String programId;
  final List<String> rssLink;
  final String? description;
  final bool newpodcast;

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    // Parse rssLink as a List<String>
    List<String> rssLinks = [];
    if (json['rssLink'] != null) {
      if (json['rssLink'] is List) {
        rssLinks = List<String>.from(json['rssLink'].map((x) => x.toString()));
      } else if (json['rssLink'] is String) {
        rssLinks = [json['rssLink']];
      }
    }

    // Determine language-specific fields based on device language
    String deviceLanguage = localLanguageNotifier.value;

    String description = '';
    String name = '';
    String station = '';
    String program = '';

    switch (deviceLanguage) {
      case 'am':
        description = json['amharicDescription'] ?? '';
        name = json['amharicName'] ?? '';
        station = json['amharicStationName'] ?? '';
        program = json['amharicProgramName'] ?? '';
        break;
      case 'en':
        description = json['englishDescription'] ?? '';
        name = json['englishName'] ?? '';
        station = json['englishStationName'] ?? '';
        program = json['englishProgramName'] ?? '';
        break;
      case 'or':
        description = json['oromoDescription'] ?? '';
        name = json['oromoName'] ?? '';
        station = json['oromoStationName'] ?? '';
        program = json['oromoProgramName'] ?? '';
        break;
      case 'so':
        description = json['somaliDescription'] ?? '';
        name = json['somaliName'] ?? '';
        station = json['somaliStationName'] ?? '';
        program = json['somaliProgramName'] ?? '';
        break;
      case 'tr':
        description = json['tigrignaDescription'] ?? '';
        name = json['tigrignaName'] ?? '';
        station = json['tigrignaStationName'] ?? '';
        program = json['tigrignaProgramName'] ?? '';
        break;
      default:
        description = json['englishDescription'] ?? '';
        name = json['englishName'] ?? '';
        station = json['englishStationName'] ?? '';
        program = json['englishProgramName'] ?? '';
        break;
    }

    // ✨ Use is_now_live from backend instead of calculating from liveTimes
    bool isLive = json['is_now_live'] ?? false;

    return PodcastModel(
      name: name,
      station: station,
      avatar: json['avatar'] ?? '',
      program: program,
      liveLink: json['liveLink'] ?? '',
      isLive: isLive, // ✨ Use backend value directly
      id: json['_id'] ?? json['id'], // MongoDB uses _id
      programId: json['programId'] ?? '',
      rssLink: rssLinks,
      description: description,
      newpodcast: json['newpodcast'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'station': station,
      'avatar': avatar,
      'program': program,
      'liveLink': liveLink,
      'isLive': isLive,
      'id': id,
      'programId': programId,
      'rssLink': rssLink,
      'description': description,
      'newpodcast': newpodcast,
    };
  }
}

bool getRandomBoolean() {
  Random random = Random();
  return random.nextBool();
}