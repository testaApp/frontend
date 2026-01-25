import 'package:dartz/dartz.dart';

import '../../Infrastructure/teamDataProvider.dart';
import '../core/failure.dart';
import 'team.dart';

class TeamRepository {
  final TeamDataProvider dataProvider = TeamDataProvider();

  TeamRepository();

  Future<Either<Failure, List<TeamInfo>>> getTeams() async {
    try {
      final teams = await dataProvider.getTeams();
      ////print("repository");

      return Right(teams);
    } catch (e) {
      return Left(Failure('Failed to fetch teams: $e'));
    }
  }

  Future<Either<Failure, Unit>> addToHive(int teamId) async {
    try {
      await dataProvider.addToHive(teamId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to add team to Hive: $e'));
    }
  }

  Future<Either<Failure, Unit>> removeFromHive(int teamId) async {
    try {
      await dataProvider.removeFromHive(teamId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to remove team from Hive: $e'));
    }
  }

  Future<Either<String, List<int>>> getBestPlayerChoose() async {
    try {
      final bestPlayerChoose = await dataProvider.getBestPlayerChoose();
      return Right(bestPlayerChoose);
    } catch (e) {
      return const Left('Failed to get best player choose');
    }
  }

  Future<Either<Failure, TeamInfo>> getTeamById(int teamId) async {
    try {
      final team = await dataProvider.getTeamById(teamId);
      return Right(team);
    } catch (e) {
      return Left(Failure('Failed to fetch team: $e'));
    }
  }
}
