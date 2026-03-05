import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/domain/player/playerModel.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

class PlayerProfileBloc extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  PlayerProfileBloc() : super(PlayerProfileState()) {
    on<PlayerProfileEvent>((event, emit) {});
    on<PlayerProfileRequested>(_handlePlayerProfileRequested);
  }

  Future<void> _handlePlayerProfileRequested(
      PlayerProfileRequested event, Emitter<PlayerProfileState> emit) async {
    emit(state.copyWith(status: playersStatus.requested));
    String url = BaseUrl().url;
    final response =
        await http.get(Uri.parse('$url/api/players?id=${event.playerId}'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final player = PlayerProfile.fromJson(json);
      emit(state.copyWith(status: playersStatus.success, player: player));
    } else if (response.statusCode == 404) {
      emit(state.copyWith(
        status: playersStatus.connectionError,
      ));
    } else if (response.statusCode == 201) {
      emit(state.copyWith(
        status: playersStatus.notFound,
      ));
    } else if (response.statusCode == 502) {
      emit(state.copyWith(
        status: playersStatus.serverError,
      ));
    }
  }
}
