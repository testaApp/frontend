enum AvailableSeasonsStatus {
  requestInProgrees,
  requestFailed,
  requestSuccessed
}

class AvailableSeasonsState {
  AvailableSeasonsStatus status;
  List<String> seasons;
  String? currentSeason;
  int? leagueId;
  int requestId;
  AvailableSeasonsState(
      {this.status = AvailableSeasonsStatus.requestInProgrees,
      this.seasons = const [],
      this.currentSeason,
      this.leagueId,
      this.requestId = 0});

  AvailableSeasonsState copyWith(
          {AvailableSeasonsStatus? status,
          List<String>? seasons,
          String? currentSeason,
          int? leagueId,
          int? requestId}) =>
      AvailableSeasonsState(
          status: status ?? this.status,
          seasons: seasons ?? this.seasons,
          currentSeason: currentSeason ?? this.currentSeason,
          leagueId: leagueId ?? this.leagueId,
          requestId: requestId ?? this.requestId);
}
