import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../domain/player/Players_for_selection_model.dart';
import '../../../../util/auth/tokens.dart';
import '../../../../util/baseUrl.dart';
import 'myfavourite_players_event.dart';
import 'myfavourite_players_state.dart';

class MyfavouritePlayersBloc
    extends Bloc<MyfavouritePlayersEvent, MyfavouritePlayersState> {
  MyfavouritePlayersBloc() : super(MyfavouritePlayersState()) {
    on<MyfavouritePlayersEvent>((event, emit) {});
    on<MyfavouritePlayersRequested>(_handleMyfavouritePlayersRequested);
  }

  String url = BaseUrl().url;

  Future<void> _handleMyfavouritePlayersRequested(
      MyfavouritePlayersRequested event,
      Emitter<MyfavouritePlayersState> emit) async {
    emit(state.copyWith(status: playersStatus.requested));

    try {
      String accessToken = await getAccessToken();
      final response = await http.get(Uri.parse('$url/api/players/favPlayers'),
          headers: {'accesstoken': accessToken});

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // Changed from PlayerProfile to PlayerSelectionModel
        List<PlayerSelectionModel> players =
            result.map((json) => PlayerSelectionModel.fromJson(json)).toList();

        print('Fetched favourite players count: ${players.length}');
        emit(state.copyWith(status: playersStatus.success, players: players));
      } else {
        emit(state.copyWith(status: playersStatus.connectionError));
      }
    } catch (e) {
      print('Error fetching fav players: $e');
      emit(state.copyWith(status: playersStatus.connectionError));
    }
  }
}
