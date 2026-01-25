import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import 'favourite_league_event.dart';
import 'favourite_league_state.dart';

class FavouriteLeagueBloc
    extends Bloc<FavouriteLeagueEvent, FavouriteLeagueState> {
  FavouriteLeagueBloc() : super(FavouriteLeagueState()) {
    on<FavouriteLeagueEvent>((event, emit) {});
    on<AddToFavouriteList>(_handleAddToFavlist);
    on<RemoveFromFavouriteList>(_handleRemoveFromFavlist);
  }

  Future<void> _handleAddToFavlist(
      AddToFavouriteList event, Emitter<FavouriteLeagueState> emit) async {
    var favLeaguesBox = await Hive.openBox<List<int>>('favLeaguesBox');
    List<int> favLeaguesId =
        favLeaguesBox.get('favLeaguesId', defaultValue: []) ?? [];

    if (!favLeaguesId.contains(event.leagueId) && event.leagueId != -1) {
      favLeaguesId.add(event.leagueId);
      await favLeaguesBox.put('favLeaguesId', favLeaguesId);
    }
  }

  Future<void> _handleRemoveFromFavlist(
      RemoveFromFavouriteList event, Emitter<FavouriteLeagueState> emit) async {
    var favLeaguesBox = await Hive.openBox<List<int>>('favLeaguesBox');
    List<int> favLeaguesId =
        favLeaguesBox.get('favLeaguesId', defaultValue: []) ?? [];

    if (!favLeaguesId.contains(event.leagueId)) {
      return;
    } else {
      favLeaguesId.remove(event.leagueId);
    }
  }
}
