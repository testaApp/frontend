import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← Keep this import

import '../../pages/entry_pages/device_info.dart';
import '../../services/fcm_service.dart';
import '../../util/api_manager/api_manager.dart';
import '../../util/baseUrl.dart';
import '../../util/delete_hive_box.dart';
import 'set_preference_event.dart';
import 'set_preference_state.dart';

class SetPreferenceBloc extends Bloc<SetPreferenceEvent, SetPreferenceState> {
  SetPreferenceBloc() : super(SetPreferenceState()) {
    on<SetPreferenceEvent>((event, emit) {});
    on<SetPreferenceRequested>(_handleSetPreferenceRequested);
  }

  Future<void> _handleSetPreferenceRequested(
    SetPreferenceRequested event,
    Emitter<SetPreferenceState> emit,
  ) async {
    emit(state.copyWith(status: SetPreferenceStatus.loading));

    try {
      var bestTeamBox = Hive.isBoxOpen('team')
          ? Hive.box<int>('team')
          : await Hive.openBox<int>('team');
      List<int> bestTeamIDs = bestTeamBox.values.toList();

      Set<int> uniqueSetofTeams = Set<int>.from(bestTeamIDs);
      List<int> uniqueList = uniqueSetofTeams.toList();
      String teamIdsAsString = uniqueList.join(',');

      var favPlayersBox = Hive.isBoxOpen('favPlayersBox')
          ? Hive.box<List<int>>('favPlayersBox')
          : await Hive.openBox<List<int>>('favPlayersBox');
      List<int> favPlayersId =
          favPlayersBox.get('favPlayersId', defaultValue: []) ?? [];
      String playerIdsAsString = favPlayersId.join(',');

      var favLeaguesBox = Hive.isBoxOpen('favLeaguesBox')
          ? Hive.box<List<int>>('favLeaguesBox')
          : await Hive.openBox<List<int>>('favLeaguesBox');
      List<int> favLeaguesId =
          favLeaguesBox.get('favLeaguesId', defaultValue: []) ?? [];
      String leaguesIdsAsString = favLeaguesId.join(',');

      var selectedLanguageBox = Hive.isBoxOpen('settings')
          ? Hive.box('settings')
          : await Hive.openBox('settings');
      String? selectedLanguage = selectedLanguageBox.get('language');

      var response = await ApiManager.postData(
        '${BaseUrl().url}/api/user/updatePreference',
        {
          'favouritePlayers': playerIdsAsString,
          'favouriteTeams': teamIdsAsString,
          'favouriteLeagues': leaguesIdsAsString,
          'language': selectedLanguage ?? 'en',
        },
        useRefreshToken: false,
        useAccessToken: false,
      );

      await deviceInfo();

      // No FCM initialization or token registration here anymore
      // → Basic init happens in main.dart
      // → Permission + token registration happens on home screen (perfect timing)

      if (response?.statusCode == 201) {
        print('Preference update succeeded');

        // Mark setup as complete — this unlocks notification display
        // and allows returning users to register token quietly in main.dart
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setup_done', true);

        emit(state.copyWith(status: SetPreferenceStatus.success));
        await deleteHiveBox('favPlayersBox');
        await deleteHiveBox('favLeaguesBox');
        await deleteHiveBox('team');
      } else if (response?.statusCode == 401) {
        print('Preference update unauthorized');
        emit(state.copyWith(status: SetPreferenceStatus.unauthorized));
      } else {
        print('Preference update failed with status: ${response?.statusCode}');
        emit(state.copyWith(status: SetPreferenceStatus.failure));
      }
    } catch (e) {
      print('Error found while setting preference: ${e.toString()}');
      emit(state.copyWith(status: SetPreferenceStatus.failure));
    }
  }
}
