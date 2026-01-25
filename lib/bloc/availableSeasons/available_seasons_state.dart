enum AvailableSeasonsStatus {
  requestInProgrees,
  requestFailed,
  requestSuccessed
}

class AvailableSeasonsState {
  AvailableSeasonsStatus status;
  List<String> seasons;
  String? currentSeason;
  AvailableSeasonsState(
      {this.status = AvailableSeasonsStatus.requestInProgrees,
      this.seasons = const [],
      this.currentSeason});

  AvailableSeasonsState copyWith(
          {AvailableSeasonsStatus? status,
          List<String>? seasons,
          String? currentSeason}) =>
      AvailableSeasonsState(
          status: status ?? this.status,
          seasons: seasons ?? this.seasons,
          currentSeason: currentSeason ?? this.currentSeason);
}
