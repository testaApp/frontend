abstract class MyfavouriteteamsEvent {}

class LoadFavouriteTeams extends MyfavouriteteamsEvent {
  List<int> teamsIds;
  LoadFavouriteTeams({required this.teamsIds});
}
