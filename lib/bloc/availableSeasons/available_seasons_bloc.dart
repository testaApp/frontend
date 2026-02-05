import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../util/baseUrl.dart';
import 'available_seasons_event.dart';
import 'available_seasons_state.dart';

class AvailableSeasonsBloc
    extends Bloc<AvailableSeasonsEvent, AvailableSeasonsState> {
  String url = BaseUrl().url;
  AvailableSeasonsBloc() : super(AvailableSeasonsState()) {
    on<AvailableSeasonsEvent>((event, emit) {});
    on<AvailableSeasonsRequested>((event, emit) async {
      print('🔍 Requesting seasons for league ID: ${event.leagueId}');

      final response = await http.get(
          Uri.parse('$url/api/leagues/seasons/?leagueId=${event.leagueId}'),
          headers: <String, String>{'Content-Type': 'application/json'});

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List<dynamic>;
        print('📅 Available seasons response: $responseData');

        List<String> seasons =
            responseData.map((element) => element.toString()).toList();

        print('🗓️ Parsed seasons: $seasons');

        // Get the most recent season that actually has standings data
        String currentSeason = '';
        for (String season in seasons) {
          try {
            final response = await http.get(Uri.parse(
                '$url/api/leagues/standingsbyseason/?leagueId=${event.leagueId}&season=$season'));
            if (response.statusCode == 200) {
              final parsed = jsonDecode(response.body);
              final overall = parsed['overall'];
              final hasData = overall is List &&
                  overall.isNotEmpty &&
                  overall.first is List &&
                  (overall.first as List).isNotEmpty;
              if (hasData) {
                currentSeason = season;
                break;
              }
            }
          } catch (e) {
            continue;
          }
        }

        print('📌 Setting current season to: $currentSeason');

        emit(state.copyWith(
            seasons: seasons,
            status: AvailableSeasonsStatus.requestSuccessed,
            currentSeason: currentSeason.isNotEmpty
                ? currentSeason
                : (seasons.isNotEmpty ? seasons.first : ''),
            leagueId: event.leagueId,
            requestId: state.requestId + 1));
      } else {
        print('❌ Failed to fetch seasons. Status code: ${response.statusCode}');
      }
    });
    on<ChangeCurrentSeason>((event, emit) {
      print('🔄 Changing current season to: ${event.season}');
      emit(state.copyWith(currentSeason: event.season));
    });
  }
}
