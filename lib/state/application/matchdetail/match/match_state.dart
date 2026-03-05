import 'package:blogapp/models/fixtures/stat.dart';

enum matchStatus { requesting, requestSuccessed, requestFailed, refreshing }

class MatchState {
  matchStatus status;
  Stat? stat;
  MatchState({
    this.status = matchStatus.requesting,
    this.stat,
  });

  MatchState copyWith({
    matchStatus? status,
    Stat? stat,
  }) {
    return MatchState(
      status: status ?? this.status,
      stat: stat ?? this.stat,
    );
  }
}
