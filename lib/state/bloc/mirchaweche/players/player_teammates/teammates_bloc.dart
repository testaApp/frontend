import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/domain/player/team_leaders_model.dart';
import 'package:blogapp/models/favourites_page/squadModel.dart';
import 'package:blogapp/models/teamName.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'teammates_event.dart';
import 'teammates_state.dart';

class TeammatesBloc extends Bloc<TeammatesEvent, TeammatesState> {
  TeammatesBloc() : super(TeammatesState()) {
    on<TeammatesEvent>((event, emit) {});
    on<TeammatesRequested>(_handleTeammatesRequested);
    on<SquadRequseted>(_handleTeamSquadRequested);
    on<TeamLeadersRequested>(_handleTeamLeadersRequested);
  }

  String url = BaseUrl().url;

  // -------------------------
  // Handle fetching player teammates
  // -------------------------
  Future<void> _handleTeammatesRequested(
      TeammatesRequested event, Emitter<TeammatesState> emit) async {
    emit(state.copyWith(status: TeammatesStatus.requested, clearSquad: true));

    try {
      final response = await http
          .get(Uri.parse('$url/api/squad/squads?id=${event.playerId}'));

      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(response.body);
        List<SquadModel> squadsList = [];

        for (var result in res) {
          List<PlayerName> goalKeepers = [];
          List<PlayerName> defenders = [];
          List<PlayerName> midfielders = [];
          List<PlayerName> attackers = [];

          final teamData = result['team'];
          TeamName team = TeamName(
            amharicName: teamData['AmharicName'],
            englishName: teamData['EnglishName'],
            oromoName: teamData['OromoName'],
            somaliName: teamData['SomaliName'],
            logo: teamData['logo'],
            id: teamData['id'],
          );

          for (var json in result['players']) {
            final player = json['player'];

            if (player == null) {
              continue;
            }

            final playerModel = PlayerName(
              amharicName: player['amharicName'] ?? '',
              englishName: player['englishName'] ?? '',
              oromoName: player['oromoName'] ?? '',
              somaliName: player['somaliName'] ?? '',
              photo: player['photo'],
              id: player['id'],
              age: json['age'],
              number: json['number'],
            );

            switch (json['position']?.toString().toLowerCase()) {
              case 'goalkeeper':
                goalKeepers.add(playerModel);
                break;
              case 'defender':
                defenders.add(playerModel);
                break;
              case 'midfielder':
                midfielders.add(playerModel);
                break;
              case 'attacker':
                attackers.add(playerModel);
                break;
              default:
            }
          }

          if (goalKeepers.isEmpty &&
              defenders.isEmpty &&
              midfielders.isEmpty &&
              attackers.isEmpty) {
            continue;
          }

          final squad = SquadModel(
            goalKeepers: goalKeepers,
            defenders: defenders,
            midfielders: midfielders,
            attackers: attackers,
            playerId: event.playerId,
            team: team,
          );

          squadsList.add(squad);
        }

        if (squadsList.isEmpty) {
          emit(state.copyWith(
              status: TeammatesStatus.notFound, clearSquad: true));
        } else {
          emit(state.copyWith(
              squads: squadsList,
              status: TeammatesStatus.requestSuccess,
              playerId: event.playerId));
        }
      } else if (response.statusCode == 404) {
        emit(
            state.copyWith(status: TeammatesStatus.notFound, clearSquad: true));
      } else {
        emit(state.copyWith(
            status: TeammatesStatus.requestFailure, clearSquad: true));
      }
    } catch (e) {
      print('ERROR in _handleTeammatesRequested: $e');
      emit(state.copyWith(
          status: TeammatesStatus.requestFailure, clearSquad: true));
    }
  }

  // -------------------------
  // Handle fetching a single team's squad
  // -------------------------
  Future<void> _handleTeamSquadRequested(
      SquadRequseted event, Emitter<TeammatesState> emit) async {
    emit(state.copyWith(
      status: TeammatesStatus.requested,
      clearSquad: true,
    ));

    try {
      final requestUrl = '$url/api/squad/teamSquads?id=${event.team.id}';
      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        List<PlayerName> goalKeepers = [];
        List<PlayerName> defenders = [];
        List<PlayerName> midfielders = [];
        List<PlayerName> attackers = [];

        // Helper function to safely parse player data using factory constructor
        PlayerName? parsePlayer(dynamic playerData) {
          try {
            if (playerData == null || playerData['player'] == null) {
              return null;
            }

            // Merge playerData fields (age, number) with nested player object
            final Map<String, dynamic> mergedData = {
              ...playerData['player'], // Spread player fields
              'age': playerData['age'],
              'number': playerData['number'],
            };

            return PlayerName.fromJson(mergedData);
          } catch (e) {
            print('⚠️ Failed to parse player: $e');
            print('   Data: $playerData');
            return null;
          }
        }

        // Parse goalkeepers
        if (res['goalKeepers'] != null && res['goalKeepers'] is List) {
          for (var playerData in res['goalKeepers']) {
            final player = parsePlayer(playerData);
            if (player != null) {
              goalKeepers.add(player);
            }
          }
        }

        // Parse defenders
        if (res['defenders'] != null && res['defenders'] is List) {
          for (var playerData in res['defenders']) {
            final player = parsePlayer(playerData);
            if (player != null) {
              defenders.add(player);
            }
          }
        }

        // Parse midfielders
        if (res['midfielders'] != null && res['midfielders'] is List) {
          for (var playerData in res['midfielders']) {
            final player = parsePlayer(playerData);
            if (player != null) {
              midfielders.add(player);
            }
          }
        }

        // Parse attackers
        if (res['attackers'] != null && res['attackers'] is List) {
          for (var playerData in res['attackers']) {
            final player = parsePlayer(playerData);
            if (player != null) {
              attackers.add(player);
            }
          }
        }

        final totalPlayers = goalKeepers.length +
            defenders.length +
            midfielders.length +
            attackers.length;

        print('✅ Parsed players:');
        print('  Goalkeepers: ${goalKeepers.length}');
        print('  Defenders: ${defenders.length}');
        print('  Midfielders: ${midfielders.length}');
        print('  Attackers: ${attackers.length}');
        print('  Total: $totalPlayers');

        if (totalPlayers == 0) {
          emit(state.copyWith(
            status: TeammatesStatus.notFound,
            clearSquad: true,
          ));
          return;
        }

        final squad = SquadModel(
          coach: res['coach'],
          coachimage: res['coachimage'],
          coachStartdate: res['coachStartdate'],
          coachEnddate: res['coachEnddate'],
          goalKeepers: goalKeepers,
          defenders: defenders,
          midfielders: midfielders,
          attackers: attackers,
          playerId: -1,
          team: event.team,
        );

        print('✅ Squad created successfully');

        emit(state.copyWith(
          squad: squad,
          status: TeammatesStatus.requestSuccess,
          clearSquad: false,
        ));

        print('✅ State emitted - Squad has ${totalPlayers} players');
      } else if (response.statusCode == 404) {
        print('⚠️ Squad not found (404)');
        emit(state.copyWith(
          status: TeammatesStatus.notFound,
          clearSquad: true,
        ));
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        emit(state.copyWith(
          status: TeammatesStatus.requestFailure,
          clearSquad: true,
        ));
      }
    } catch (e, stackTrace) {
      print('❌ Error in _handleTeamSquadRequested: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: TeammatesStatus.requestFailure,
        clearSquad: true,
      ));
    }
  }

  Future<void> _handleTeamLeadersRequested(
      TeamLeadersRequested event, Emitter<TeammatesState> emit) async {
    emit(state.copyWith(status: TeammatesStatus.requested));

    try {
      final response = await http.get(
        Uri.parse('$url/api/squad/teamLeaders?id=${event.teamId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<TeamLeader> parseCategory(String key) {
          final List<dynamic> list = data[key] ?? [];
          List<TeamLeader> result = [];

          print('Parsing $key: ${list.length} items');

          for (int i = 0; i < list.length; i++) {
            try {
              final leader = TeamLeader.fromJson(list[i]);
              result.add(leader);
            } catch (e) {}
          }

          return result;
        }

        emit(state.copyWith(
          status: TeammatesStatus.requestSuccess,
          topScorers: parseCategory('topScorers'),
          topAssisters: parseCategory('topAssisters'),
          topRedCards: parseCategory('mostRedCards'),
          topYellowCards: parseCategory('mostYellowCards'),
        ));
      } else {
        emit(state.copyWith(status: TeammatesStatus.requestFailure));
      }
    } catch (e) {
      emit(state.copyWith(status: TeammatesStatus.requestFailure));
    }
  }
}
