import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../services/analytics_service.dart';
import '../../services/fcm_service.dart';
import '../../services/following_storage_service.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import 'following_event.dart';
import 'following_state.dart';

class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  final FollowingStorageService _storageService;
  final FollowingAnalyticsService _analyticsService;
  Timer? _syncTimer;
  
  FollowingBloc({
    required FollowingStorageService storageService,
    required FollowingAnalyticsService analyticsService,
  })  : _storageService = storageService,
        _analyticsService = analyticsService,
        super(FollowingState()) {
    on<FollowingEvent>((event, emit) {});
    on<FollowPlayerRequested>(_handleAddFavouritePlayerEvent);
    on<FollowPodcastRequested>(_handleAddFavouritePodcastEvent);
    on<RemoveFollowingPlayer>(_handleRemoveFavouritePlayerEvent);
    on<FollowTeamRequested>(_handleAddFavouriteTeamEvent);
    on<RemoveFollowingTeam>(_handleRemoveFavouriteTeamEvent);
    on<RemoveFollowingPodcast>(_handleRemovePodcastEvent);
    on<CheckFollowingTeam>(_handleCheckFollowingTeam);
    on<AddFavouriteMatchEvent>(_handleAddFavouriteMatchEvent);
    on<RemoveFavouriteMatchEvent>(_handleRemoveFavouriteMatchEvent);
    on<CheckFollowingMatch>(_handleCheckFollowingEvent);
    on<CheckFollowingPlayer>(_handleCheckFollowingPlayer);
    on<CheckFollowingPodcast>(_handleCheckFollowingPodcast);
    on<LoadFollowedTeams>(_handleLoadFollowedTeams);
    on<ToggleFollowPlayer>(_handleToggleFollowPlayer);
    on<FetchAndSaveFavoritePodcasts>(_handleFetchAndSaveFavoritePodcasts);
    on<SyncPendingOperations>(_handleSyncPendingOperations);
    on<LoadFollowedPlayers>(_handleLoadFollowedPlayers);
    
    // Start periodic sync (every 30 seconds)
    _startPeriodicSync();
  }

  String url = BaseUrl().url;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(SyncPendingOperations());
    });
  }

  // ========== MATCHES ==========

  Future<void> _handleAddFavouriteMatchEvent(
      AddFavouriteMatchEvent event, Emitter<FollowingState> emit) async {
    print('⚽ ADD MATCH (LOCAL-FIRST): Match ID: ${event.matchId}');

    try {
      // 1. INSTANT local update
      await _storageService.addFollowedMatch(event.matchId!);
      emit(state.copyWith(status: Status.following));
      
      // 2. Log analytics
      await _analyticsService.logMatchFollowed(
        event.matchId!,
        leagueName: event.leagueName,
        homeTeam: event.homeTeam,
        awayTeam: event.awayTeam,
      );

      // 3. Subscribe to FCM topic immediately
      final languageCode = localLanguageNotifier.value;
      await FCMTopicManager.subscribeToMatch(
        fixtureId: event.matchId.toString(),
        languageCode: languageCode,
      );
      print('🔔 Subscribed to match notifications');

      // 4. Background sync (non-blocking)
      _syncMatchToBackend(event.matchId!, 'add');
    } catch (e) {
      print('❌ Error adding match locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  Future<void> _handleRemoveFavouriteMatchEvent(
      RemoveFavouriteMatchEvent event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE MATCH (LOCAL-FIRST): Match ID: ${event.matchId}');

    try {
      // 1. INSTANT local update
      await _storageService.removeFollowedMatch(event.matchId!);
      emit(state.copyWith(status: Status.notFollowing));

      // 2. Log analytics
      await _analyticsService.logMatchUnfollowed(
        event.matchId!,
        leagueName: event.leagueName,
        homeTeam: event.homeTeam,
        awayTeam: event.awayTeam,
      );

      // 3. Unsubscribe from FCM topic immediately
      final languageCode = localLanguageNotifier.value;
      await FCMTopicManager.unsubscribeFromMatch(
        fixtureId: event.matchId.toString(),
        languageCode: languageCode,
      );
      print('🔕 Unsubscribed from match notifications');

      // 4. Background sync (non-blocking)
      _syncMatchToBackend(event.matchId!, 'remove');
    } catch (e) {
      print('❌ Error removing match locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  /// Background sync for match (doesn't block UI)
  Future<void> _syncMatchToBackend(int matchId, String action) async {
    try {
      final endpoint = action == 'add' 
          ? '$url/api/user/addToFavMatch'
          : '$url/api/user/removeFavMatch';

      final response = await http.post(
        Uri.parse(endpoint),
        body: jsonEncode({'matchId': matchId.toString()}),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Match synced to backend: $action');
        await _storageService.removePendingSync('match', matchId.toString(), action);
      } else {
        print('⚠️ Failed to sync match, will retry later: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Network error syncing match, will retry later: $e');
    }
  }

  // ========== TEAMS ==========

  Future<void> _handleAddFavouriteTeamEvent(
      FollowTeamRequested event, Emitter<FollowingState> emit) async {
    print('⚽ ADD TEAM (LOCAL-FIRST): Team ID: ${event.teamId}');

    try {
      await _storageService.addFollowedTeam(event.teamId!);
      if (event.teamName != null && event.teamName!.isNotEmpty) {
        await _storageService.setFollowedTeamName(
          event.teamId!,
          event.teamName!,
        );
      }
      emit(state.copyWith(
        status: Status.following,
        followedTeams: _storageService.getFollowedTeams(),
      ));
      
      await _analyticsService.logTeamFollowed(event.teamId!, event.teamName ?? 'unknown');
      
      _syncTeamToBackend(event.teamId!, 'add');
    } catch (e) {
      print('❌ Error adding team locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  Future<void> _handleRemoveFavouriteTeamEvent(
      RemoveFollowingTeam event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE TEAM (LOCAL-FIRST): Team ID: ${event.teamId}');

    try {
      await _storageService.removeFollowedTeam(event.teamId!);
      await _storageService.removeFollowedTeamName(event.teamId!);
      emit(state.copyWith(
        status: Status.notFollowing,
        followedTeams: _storageService.getFollowedTeams(),
      ));
      
      await _analyticsService.logTeamUnfollowed(event.teamId!, event.teamName ?? 'unknown');
      
      _syncTeamToBackend(event.teamId!, 'remove');
    } catch (e) {
      print('❌ Error removing team locally: $e');
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> _syncTeamToBackend(int teamId, String action) async {
    try {
      final endpoint = action == 'add'
          ? '$url/api/user/addToFavTeam'
          : '$url/api/user/removeFavTeam';

      final response = await http.post(
        Uri.parse(endpoint),
        body: jsonEncode({'teamId': teamId.toString()}),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Team synced to backend: $action');
        await _storageService.removePendingSync('team', teamId.toString(), action);
      }
    } catch (e) {
      print('⚠️ Network error syncing team: $e');
    }
  }

  // ========== PLAYERS ==========

  Future<void> _handleAddFavouritePlayerEvent(
      FollowPlayerRequested event, Emitter<FollowingState> emit) async {
    print('👤 ADD PLAYER (LOCAL-FIRST): Player ID: ${event.playerId}');

    try {
      await _storageService.addFollowedPlayer(event.playerId!);
      if (event.playerName != null && event.playerName!.isNotEmpty) {
        await _storageService.setFollowedPlayerName(
          event.playerId!,
          event.playerName!,
        );
      }
      emit(state.copyWith(
        status: Status.following,
        followedPlayers: _storageService.getFollowedPlayers(),
      ));
      
      await _analyticsService.logPlayerFollowed(event.playerId!, event.playerName ?? 'unknown');
      
      _syncPlayerToBackend(event.playerId!, 'add');
    } catch (e) {
      print('❌ Error adding player locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  Future<void> _handleRemoveFavouritePlayerEvent(
      RemoveFollowingPlayer event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE PLAYER (LOCAL-FIRST): Player ID: ${event.playerId}');

    try {
      await _storageService.removeFollowedPlayer(event.playerId!);
      await _storageService.removeFollowedPlayerName(event.playerId!);
      emit(state.copyWith(
        status: Status.notFollowing,
        followedPlayers: _storageService.getFollowedPlayers(),
      ));
      
      await _analyticsService.logPlayerUnfollowed(event.playerId!, event.playerName ?? 'unknown');
      
      _syncPlayerToBackend(event.playerId!, 'remove');
    } catch (e) {
      print('❌ Error removing player locally: $e');
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> _syncPlayerToBackend(int playerId, String action) async {
    try {
      final endpoint = action == 'add'
          ? '$url/api/user/addToFavPlayer'
          : '$url/api/user/removeFavPlayer';

      final response = await http.post(
        Uri.parse(endpoint),
        body: jsonEncode({'playerId': playerId.toString()}),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Player synced to backend: $action');
        await _storageService.removePendingSync('player', playerId.toString(), action);
      }
    } catch (e) {
      print('⚠️ Network error syncing player: $e');
    }
  }

  // ========== PODCASTS ==========

  Future<void> _handleAddFavouritePodcastEvent(
      FollowPodcastRequested event, Emitter<FollowingState> emit) async {
    print('🎙️ ADD PODCAST (LOCAL-FIRST): Podcast ID: ${event.podcastId}');

    try {
      await _storageService.addFollowedPodcast(event.podcastId);
      emit(state.copyWith(status: Status.following));
      
      await _analyticsService.logPodcastFollowed(event.podcastId, event.podcastName ?? 'unknown');

      if (event.programId != null && event.programId!.isNotEmpty) {
        final languageCode = localLanguageNotifier.value;
        await FCMTopicManager.subscribeToPodcast(
          programId: event.programId!,
          languageCode: languageCode,
        );
      }

      await _syncPodcastToBackend(event.podcastId, event.programId, 'add');
    } catch (e) {
      print('❌ Error adding podcast locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  Future<void> _handleRemovePodcastEvent(
      RemoveFollowingPodcast event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE PODCAST (LOCAL-FIRST): Podcast ID: ${event.podcastId}');

    try {
      await _storageService.removeFollowedPodcast(event.podcastId);
      emit(state.copyWith(status: Status.notFollowing));
      
      await _analyticsService.logPodcastUnfollowed(event.podcastId, event.podcastName ?? 'unknown');

      if (event.programId != null && event.programId!.isNotEmpty) {
        final languageCode = localLanguageNotifier.value;
        await FCMTopicManager.unsubscribeFromPodcastTopic(
          programId: event.programId!,
          languageCode: languageCode,
        );
      }

      _syncPodcastToBackend(event.podcastId, event.programId, 'remove');
    } catch (e) {
      print('❌ Error removing podcast locally: $e');
      emit(state.copyWith(status: Status.networkError));
    }
  }

  Future<void> _syncPodcastToBackend(String podcastId, String? programId, String action) async {
    try {
      final endpoint = action == 'add'
          ? '$url/api/user/addToFavPodcast'
          : '$url/api/user/removeFavPodcast';

      final response = await http.post(
        Uri.parse(endpoint),
        body: jsonEncode({'podcastId': podcastId}),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Podcast synced to backend: $action');
        await _storageService.removePendingSync('podcast', podcastId, action);
      }
    } catch (e) {
      print('⚠️ Network error syncing podcast: $e');
    }
  }

  // ========== CHECK FOLLOWING (from local storage) ==========

  Future<void> _handleCheckFollowingEvent(
      CheckFollowingMatch event, Emitter<FollowingState> emit) async {
    print('🔍 CHECK MATCH (LOCAL): Match ID: ${event.matchId}');

    // Check local storage first (instant)
    final isFollowed = _storageService.isMatchFollowed(event.matchId!);
    
    if (isFollowed) {
      emit(state.copyWith(status: Status.following));
    } else {
      emit(state.copyWith(status: Status.notFollowing));
    }

    // Optionally sync with backend to verify (in background)
    if (!event.checkOnly) {
      _verifyMatchFollowingWithBackend(event.matchId!, emit);
    }
  }

  Future<void> _verifyMatchFollowingWithBackend(
      int matchId, Emitter<FollowingState> emit) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/user/checkFollowingMatch'),
        body: jsonEncode({'matchId': matchId.toString()}),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedData = jsonDecode(response.body);
        bool serverFollowing = parsedData['following'] ?? false;
        bool localFollowing = _storageService.isMatchFollowed(matchId);

        // Sync local with server if mismatch
        if (serverFollowing != localFollowing) {
          if (serverFollowing) {
            await _storageService.addFollowedMatch(matchId);
            emit(state.copyWith(status: Status.following));
          } else {
            await _storageService.removeFollowedMatch(matchId);
            emit(state.copyWith(status: Status.notFollowing));
          }
        }
      }
    } catch (e) {
      print('⚠️ Could not verify with backend: $e');
    }
  }

  Future<void> _handleCheckFollowingTeam(
      CheckFollowingTeam event, Emitter<FollowingState> emit) async {
    final isFollowed = _storageService.isTeamFollowed(event.teamId!);
    emit(state.copyWith(
      status: isFollowed ? Status.following : Status.notFollowing,
      followedTeams: _storageService.getFollowedTeams(),
    ));
  }

  Future<void> _handleLoadFollowedTeams(
      LoadFollowedTeams event, Emitter<FollowingState> emit) async {
    emit(state.copyWith(
      followedTeams: _storageService.getFollowedTeams(),
    ));
  }

  Future<void> _handleCheckFollowingPlayer(
      CheckFollowingPlayer event, Emitter<FollowingState> emit) async {
    final isFollowed = _storageService.isPlayerFollowed(event.playerId!);
    emit(state.copyWith(
      status: isFollowed ? Status.following : Status.notFollowing,
      followedPlayers: _storageService.getFollowedPlayers(),
    ));
  }

  Future<void> _handleCheckFollowingPodcast(
      CheckFollowingPodcast event, Emitter<FollowingState> emit) async {
    final isFollowed = _storageService.isPodcastFollowed(event.podcastId);
    emit(state.copyWith(
      status: isFollowed ? Status.following : Status.notFollowing,
    ));
  }

  // ========== SYNC PENDING OPERATIONS ==========

  Future<void> _handleSyncPendingOperations(
      SyncPendingOperations event, Emitter<FollowingState> emit) async {
    final pendingOps = _storageService.getPendingSync();
    
    if (pendingOps.isEmpty) return;

    print('🔄 Syncing ${pendingOps.length} pending operations...');
    await _analyticsService.logSyncStarted('pending_operations');

    int successCount = 0;
    
    for (final op in pendingOps) {
      try {
        final type = op['type'] as String;
        final id = op['id'] as String;
        final action = op['action'] as String;

        switch (type) {
          case 'match':
            await _syncMatchToBackend(int.parse(id), action);
            successCount++;
            break;
          case 'team':
            await _syncTeamToBackend(int.parse(id), action);
            successCount++;
            break;
          case 'player':
            await _syncPlayerToBackend(int.parse(id), action);
            successCount++;
            break;
          case 'podcast':
            await _syncPodcastToBackend(id, null, action);
            successCount++;
            break;
        }
      } catch (e) {
        print('⚠️ Failed to sync operation: $e');
      }
    }

    await _analyticsService.logSyncCompleted(
      'pending_operations',
      itemsSynced: successCount,
      success: successCount == pendingOps.length,
    );

    print('✅ Sync completed: $successCount/${pendingOps.length}');
  }

  Future<void> _handleFetchAndSaveFavoritePodcasts(
      FetchAndSaveFavoritePodcasts event, Emitter<FollowingState> emit) async {
    // Keep existing implementation
    print('📥 FETCH PODCASTS: Starting to fetch favorite podcasts');
    try {
      emit(state.copyWith(status: Status.loading));

      final response = await http.get(
        Uri.parse('$url/api/user/FavoritePodcasts'),
        headers: {
          'accesstoken': await getAccessToken(),
          'content-type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> favoritePodcasts = data['favoritePodcasts'];

        final List<String> podcastIds = favoritePodcasts
            .map<String>((podcast) => podcast['id'].toString())
            .toList();

        // Save to local storage
        await _storageService.syncFromServer(podcasts: podcastIds);

        emit(state.copyWith(
          status: Status.success,
          followedPodcasts: podcastIds,
        ));
      } else {
        emit(state.copyWith(status: Status.error));
      }
    } catch (e) {
      print('Error fetching favorite podcasts: $e');
      emit(state.copyWith(status: Status.error));
    }
  }

  Future<void> _handleToggleFollowPlayer(
      ToggleFollowPlayer event, Emitter<FollowingState> emit) async {
    final isFollowing = _storageService.isPlayerFollowed(event.playerId!);
    
    if (isFollowing) {
      await _handleRemoveFavouritePlayerEvent(
        RemoveFollowingPlayer(playerId: event.playerId, playerName: event.playerName),
        emit,
      );
    } else {
      await _handleAddFavouritePlayerEvent(
        FollowPlayerRequested(playerId: event.playerId, playerName: event.playerName),
        emit,
      );
    }
  }

  Future<void> _handleLoadFollowedPlayers(
      LoadFollowedPlayers event, Emitter<FollowingState> emit) async {
    emit(state.copyWith(
      followedPlayers: _storageService.getFollowedPlayers(),
    ));
  }
}
