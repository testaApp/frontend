import 'package:blogapp/models/fixtures/lineups.dart';

enum LineupStatus { requestInProgress, requestFailure, requestSuccess, unknown }

class LineupsState {
  const LineupsState({
    this.lineups = const [],
    this.lineupsStatus = LineupStatus.unknown,
    this.isFallback = false,
    this.fallbackMessage,
  });

  final List<Lineup> lineups;
  final LineupStatus lineupsStatus;
  final bool isFallback;
  final String? fallbackMessage;

  LineupsState copyWith({
    List<Lineup>? lineups,
    LineupStatus? lineupsStatus,
    bool? isFallback,
    String? fallbackMessage,
  }) {
    return LineupsState(
      lineups: lineups ?? this.lineups,
      lineupsStatus: lineupsStatus ?? this.lineupsStatus,
      isFallback: isFallback ?? this.isFallback,
      fallbackMessage: fallbackMessage ?? this.fallbackMessage,
    );
  }
}
