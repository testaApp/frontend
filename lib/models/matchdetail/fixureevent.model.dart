import '../../domain/player/playerName.dart';
import '../../domain/team/team.dart';

class FixureEventModel {
  final Team team;
  final EventTime time;
  final PlayerName player;
  final String type;
  final String? detail;
  final String? comments;
  final PlayerName? assist;

  FixureEventModel({
    required this.team,
    required this.time,
    required this.player,
    required this.type,
    this.detail,
    this.comments,
    this.assist,
  });

  factory FixureEventModel.fromJson(Map<String, dynamic> json) {
    return FixureEventModel(
      team: Team.fromJson(json['team'] ?? {}),
      time: EventTime.fromJson(json['time'] ?? {}),
      player: PlayerName.fromJson(json['player'] ?? {}),
      type: json['type'] ?? '',
      detail: json['detail'] ?? '',
      comments: json['comments'] ?? '',
      assist: (json['assist'] != null && json['assist']['id'] != null)
          ? PlayerName.fromJson(json['assist'])
          : null,
    );
  }
}

class EventTime {
  final String elapsed;
  final int? extra;

  EventTime({required this.elapsed, required this.extra});

  factory EventTime.fromJson(Map<String, dynamic> json) {
    return EventTime(
      elapsed: json['elapsed']?.toString() ?? '0',
      extra: json['extra'],
    );
  }
}
