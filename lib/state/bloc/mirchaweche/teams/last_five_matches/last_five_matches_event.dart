abstract class LastFiveMatchesEvent {}

class LastFiveMatchesRequested extends LastFiveMatchesEvent {
  final String teamId; // Changed from int to String
  LastFiveMatchesRequested({required this.teamId});
}
