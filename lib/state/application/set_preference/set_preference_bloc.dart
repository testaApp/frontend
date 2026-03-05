import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_manager.dart';
import '../../../core/network/baseUrl.dart';
import '../../../core/storage/delete_hive_box.dart';
import '../../../features/auth/services/firebase_auth_helpers.dart';
import '../../../features/onboarding/pages/device_info.dart';
import '../../../main.dart';
import '../../../services/fcm_service.dart';
import '../../../services/sync_service.dart';
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
    final stopwatch = Stopwatch()..start();

    try {
      List<int> bestTeamIDs = globalStorageService.getFollowedTeams();
      Set<int> uniqueSetofTeams = Set<int>.from(bestTeamIDs);
      List<int> uniqueList = uniqueSetofTeams.toList();

      List<int> favPlayersId =
          globalStorageService.getFollowedPlayers().toSet().toList();
      final teamNames = globalStorageService.getFollowedTeamNames();
      final playerNames = globalStorageService.getFollowedPlayerNames();

      final favouriteTeamsPayload = uniqueList
          .map((id) => {'id': id, 'name': teamNames[id] ?? ''})
          .toList();
      final favouritePlayersPayload = favPlayersId
          .map((id) => {'id': id, 'name': playerNames[id] ?? ''})
          .toList();

      var favLeaguesBox = Hive.isBoxOpen('favLeaguesBox')
          ? Hive.box<List<int>>('favLeaguesBox')
          : await Hive.openBox<List<int>>('favLeaguesBox');
      List<int> favLeaguesId =
          favLeaguesBox.get('favLeaguesId', defaultValue: []) ?? [];
      favLeaguesId = favLeaguesId.toSet().toList();
      String leaguesIdsAsString = favLeaguesId.join(',');

      var selectedLanguageBox = Hive.isBoxOpen('settings')
          ? Hive.box('settings')
          : await Hive.openBox('settings');
      String? selectedLanguage = selectedLanguageBox.get('language');

      await globalAnalyticsService.logOnboardingStepAction(
        stepName: 'setup_preferences',
        action: 'submit_started',
        teamCount: uniqueList.length,
        playerCount: favPlayersId.length,
        leagueCount: favLeaguesId.length,
      );

      var response = await ApiManager.postData(
        '${BaseUrl().url}/api/user/updatePreference',
        {
          'favouritePlayers': favouritePlayersPayload,
          'favouriteTeams': favouriteTeamsPayload,
          'favouriteLeagues': leaguesIdsAsString,
          'language': selectedLanguage ?? 'am',
        },
        useRefreshToken: false,
        useAccessToken: true,
      );

      await deviceInfo();

      if (response?.statusCode == 201 || response?.statusCode == 200) {
        print('Preference update succeeded');

        // Seed FollowingStorageService so player/team tabs reflect selections immediately.
        await globalStorageService.syncFromServer(
          teams: uniqueList,
          players: favPlayersId,
        );
// 1. Dio uses .data instead of .body
        // Also, Dio usually auto-parses JSON, so we check if it's already a Map
        final responseData = response!.data;

        // 2. Extract the ID (Safe handling if it's already a Map or still a String)
        String mongoId;
        if (responseData is Map) {
          mongoId = responseData['userId']?.toString() ?? 'unknown_user';
        } else {
          // Fallback if your ApiManager doesn't auto-parse
          final decoded = jsonDecode(responseData.toString());
          mongoId = decoded['userId']?.toString() ?? 'unknown_user';
        }
        // ─── ADD THIS: Sync Firebase UID using the new mongoId ────────────────────────
        final auth = FirebaseAuth.instance;
        final firebaseUid = auth.currentUser?.uid;

        if (firebaseUid != null) {
          try {
            final uri = Uri.parse('${BaseUrl().url}/api/user/sync-firebase');
            final headers = await buildAuthHeaders();
            final syncResponse = await http.post(
              uri,
              headers: headers,
              body: jsonEncode({
                'firebaseUid': firebaseUid,
                'userId': mongoId, // ← send the newly created userId
                'platform': Platform.isAndroid ? 'android' : 'ios',
              }),
            );

            if (syncResponse.statusCode == 200) {
              debugPrint('✅ Firebase UID synced after user creation');
            } else {
              debugPrint(
                  '❌ Firebase UID sync failed: ${syncResponse.statusCode}');
            }
          } catch (e) {
            debugPrint('❌ Error syncing Firebase UID after setup: $e');
          }
        }
        // ────────────────────────────────────────────────────────────────────────────────
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setup_done', true);
        await ensureBreakingNewsSubscription(); // only here, not in main
        await syncFollowingDataAfterLogin(
          storageService: globalStorageService,
        );

// 3. Analytics calls
        await FirebaseAnalytics.instance.setUserId(id: mongoId);
        await FirebaseAnalytics.instance.setUserProperty(
          name: 'app_language',
          value: selectedLanguage ?? '',
        );
        await FirebaseAnalytics.instance.logEvent(name: 'setup_completed');
        await globalAnalyticsService.logOnboardingSetupResult(
          status: 'success',
          teamCount: uniqueList.length,
          playerCount: favPlayersId.length,
          leagueCount: favLeaguesId.length,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
        );

        emit(state.copyWith(status: SetPreferenceStatus.success));
        await deleteHiveBox<List<int>>('favPlayersBox');
        await deleteHiveBox<List<int>>('favLeaguesBox');
        await deleteHiveBox<int>('team');
      } else if (response?.statusCode == 401) {
        print('Preference update unauthorized');
        await globalAnalyticsService.logOnboardingSetupResult(
          status: 'unauthorized',
          teamCount: uniqueList.length,
          playerCount: favPlayersId.length,
          leagueCount: favLeaguesId.length,
          statusCode: response?.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          errorType: 'unauthorized',
        );
        emit(state.copyWith(status: SetPreferenceStatus.unauthorized));
      } else {
        print('Preference update failed with status: ${response?.statusCode}');
        await globalAnalyticsService.logOnboardingSetupResult(
          status: 'failure',
          teamCount: uniqueList.length,
          playerCount: favPlayersId.length,
          leagueCount: favLeaguesId.length,
          statusCode: response?.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
          errorType: 'api_failure',
        );
        emit(state.copyWith(status: SetPreferenceStatus.failure));
      }
    } catch (e) {
      print('Error found while setting preference: ${e.toString()}');
      await globalAnalyticsService.logOnboardingSetupResult(
        status: 'failure',
        durationMs: stopwatch.elapsedMilliseconds,
        errorType: e.runtimeType.toString(),
      );
      emit(state.copyWith(status: SetPreferenceStatus.failure));
    }
  }
}
