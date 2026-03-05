abstract class MatchesPageEvent {}

class MatchesRequested extends MatchesPageEvent {
  final String? teamId;
  final int pageNumber;

  MatchesRequested(this.teamId, {this.pageNumber = 0});
}

class TeamNextMatchesRequested extends MatchesPageEvent {
  final String? teamId;
  final int pageNumber;

  TeamNextMatchesRequested(this.teamId, {this.pageNumber = 0});
}

class TeamPreviousMatchesRequested extends MatchesPageEvent {
  final String? teamId;
  final int pageNumber;

  TeamPreviousMatchesRequested(this.teamId, {this.pageNumber = 0});
}
