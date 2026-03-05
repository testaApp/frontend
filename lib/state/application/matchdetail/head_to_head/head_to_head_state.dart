import 'package:blogapp/models/fixtures/stat.dart';

enum h2hStatus {
  initial,
  networkProblem,
  requestInProgress,
  requestSuccess,
  unknown
}

class HeadToHeadState {
  h2hStatus status;
  List<Stat> matches;
  HeadToHeadState({this.status = h2hStatus.initial, this.matches = const []});

  HeadToHeadState copyWith({h2hStatus? status, List<Stat>? matches}) =>
      HeadToHeadState(
          status: status ?? this.status, matches: matches ?? this.matches);
}
