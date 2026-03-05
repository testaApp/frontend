import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/main.dart';
import 'package:blogapp/models/teamName.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'myfavouriteteams_event.dart';
import 'myfavouriteteams_state.dart';

class MyfavouriteteamsBloc
    extends Bloc<MyfavouriteteamsEvent, MyfavouriteteamsState> {
  MyfavouriteteamsBloc() : super(MyfavouriteteamsState()) {
    on<MyfavouriteteamsEvent>((event, emit) {});
    on<LoadFavouriteTeams>(_handleLoadFavouriteTeams);
  }
  String url = BaseUrl().url;
  Future<void> _handleLoadFavouriteTeams(
      LoadFavouriteTeams event, Emitter<MyfavouriteteamsState> emit) async {
    emit(state.copyWith(status: favTeamStatus.requested));

    final headers = await buildAuthHeaders(includeJson: false);
    final response =
        await http.get(Uri.parse('$url/api/teams/favTeams'), headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> result = jsonDecode(response.body);
      List<TeamName> teams = [];
      for (int i = 0; i < result.length; i++) {
        final json = result[i];
        String name = '';
        switch (localLanguageNotifier.value) {
          case 'am':
            name = json['AmharicName'];
            break;
          case 'tr':
            name = json['AmharicName'];
            break;
          case 'or':
            name = json['OromoName'];
            break;
          case 'so':
            name = json['SomaliName'];
            break;
          default:
            json['EnglishName'];
        }
        final int teamId = json['id'] ?? 0;

        final String logo =
            (json['logo'] != null && json['logo'].toString().isNotEmpty)
                ? json['logo']
                : teamId != 0
                    ? 'https://media.api-sports.io/football/teams/$teamId.png'
                    : 'assets/club.png';

        final team = TeamName(
            id_: json['_id'],
            amharicName: json['AmharicName'],
            englishName: json['EnglishName'],
            oromoName: json['OromoName'],
            somaliName: json['SomaliName'],
            logo: logo,
            venuename: json['venuename'],
            venueimage: json['venueimage'],
            venueaddress: json['venueaddress'],
            venuecapacity: json['venuecapacity'],
            venuecity: json['venuecity'],
            founded: json['founded'],
            venuesurface: json['venuesurface'],
            id: json['id']);
        teams.add(team);
      }
      final teamIds = teams.map((t) => t.id).toList();
      await globalStorageService.syncFromServer(teams: teamIds);
      emit(state.copyWith(status: favTeamStatus.success, teams: teams));
    } else {
      emit(state.copyWith(status: favTeamStatus.failure));
    }
  }
}

String listToCommaSeparatedString(List<int> integers) {
  if (integers.isEmpty) {
    return ''; // Return an empty string if the list is empty.
  }

  // Use the `join` method to concatenate the integers with commas.
  String commaSeparatedString = integers.map((id) => id.toString()).join(',');

  return commaSeparatedString;
}
