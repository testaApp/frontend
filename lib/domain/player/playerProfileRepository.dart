import 'package:dartz/dartz.dart';

import 'package:blogapp/data/providers/playerProfileDataProvider.dart';
import '../core/failure.dart';
import 'playerProfile.dart';

class PlayerProfileRepository {
  final PlayerProfileDataProvider dataProvider = PlayerProfileDataProvider();
  PlayerProfileRepository();

  Future<Either<Failure, Profile>> fetchProfileData(
      String name, int league, int season) async {
    try {
      final profile = await dataProvider.fetchProfileData(name, league, season);
      return Right(profile);
    } catch (e) {
      return Left(Failure('Failed to fetch profile data: $e'));
    }
  }
}
