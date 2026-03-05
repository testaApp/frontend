import 'package:dartz/dartz.dart';

import 'package:blogapp/data/providers/playerPreferencesDataProvider.dart';
import 'PlayerPreference.dart';
import 'PlayerPreferenceFailure.dart';

class PlayerPreferencesRepository {
  final PlayersDataProvider dataProvider;

  PlayerPreferencesRepository(this.dataProvider);

  Future<Either<PlayerPreferenceFailure, List<PlayerPreference>>>
      getAllPlayerPreferences() async {
    try {
      final playerPreferences = await dataProvider.getAllPlayers();
      return Right(playerPreferences);
    } catch (e) {
      return Left(NetworkErrorFailure());
    }
  }

  Future<Either<PlayerPreferenceFailure, PlayerPreference>>
      getPlayerPreferenceById(String id) async {
    try {
      final playerPreference = await dataProvider.getPlayerById(id);
      return Right(playerPreference);
    } catch (e) {
      return Left(NetworkErrorFailure());
    }
  }

  Future<Either<PlayerPreferenceFailure, PlayerPreference>>
      createPlayerPreference(PlayerPreference preference) async {
    try {
      final createdPlayerPreference =
          await dataProvider.createPlayer(preference);
      return Right(createdPlayerPreference);
    } catch (e) {
      return Left(NetworkErrorFailure());
    }
  }

  Future<Either<PlayerPreferenceFailure, PlayerPreference>>
      updatePlayerPreference(String id, PlayerPreference preference) async {
    try {
      final updatedPlayerPreference =
          await dataProvider.updatePlayer(id, preference);
      return Right(updatedPlayerPreference);
    } catch (e) {
      return Left(NetworkErrorFailure());
    }
  }

  Future<Either<PlayerPreferenceFailure, void>> deletePlayerPreference(
      String id) async {
    try {
      await dataProvider.deletePlayer(id);
      return const Right(null);
    } catch (e) {
      return Left(NetworkErrorFailure());
    }
  }
}
