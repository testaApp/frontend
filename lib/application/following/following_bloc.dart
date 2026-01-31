import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../services/fcm_service.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import 'following_event.dart';
import 'following_state.dart';

class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  FollowingBloc() : super(FollowingState()) {
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
    on<ToggleFollowPlayer>(_handleToggleFollowPlayer);
    
    Future<void> handleFetchAndSaveFavoritePodcasts(
        FetchAndSaveFavoritePodcasts event,
        Emitter<FollowingState> emit) async {
      await fetchAndSaveFavoritePodcasts();
    }

    on<FetchAndSaveFavoritePodcasts>(handleFetchAndSaveFavoritePodcasts);
  }

  String url = BaseUrl().url;

  Future<void> _handleAddFavouriteMatchEvent(
      AddFavouriteMatchEvent event, Emitter<FollowingState> emit) async {
    print('⚽ ADD MATCH: Starting to add match ID: ${event.matchId}');
    print('📊 Current state status: ${state.status}');
    
    if (state.status == Status.notFollowing ||
        state.status == Status.unfollowRequested) {
      emit(state.copyWith(status: Status.followRequested));
      try {
        final response = await http.post(
            Uri.parse('$url/api/user/addToFavMatch'),
            body: jsonEncode({
              'matchId': event.matchId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.following));
          
          // ✨ Subscribe to FCM topic for this match
          final languageCode = localLanguageNotifier.value;
          await FCMTopicManager.subscribeToMatch(
            fixtureId: event.matchId.toString(),
            languageCode: languageCode,
          );
          print('🔔 Subscribed to match notifications: testa_match_${event.matchId}_$languageCode');
        } else {
          print('❌ Failed to add match to favorites: ${response.statusCode}');
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('❌ Error happened while adding match to favourite: $e');
        emit(state.copyWith(status: Status.networkError));
      }
    }
  }

  Future<void> _handleRemoveFavouriteMatchEvent(
      RemoveFavouriteMatchEvent event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE MATCH: Starting to remove match ID: ${event.matchId}');
    print('📊 Current state status: ${state.status}');
    
    if (state.status == Status.following ||
        state.status == Status.followRequested) {
      emit(state.copyWith(status: Status.unfollowRequested));

      try {
        final response = await http.post(
            Uri.parse('$url/api/user/removeFavMatch'),
            body: jsonEncode({
              'matchId': event.matchId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });
        
        print('📡 Remove match response: ${response.statusCode}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.notFollowing));
          
          // ✨ Unsubscribe from FCM topic for this match
          final languageCode = localLanguageNotifier.value;
          await FCMTopicManager.unsubscribeFromMatch(
            fixtureId: event.matchId.toString(),
            languageCode: languageCode,
          );
          print('🔕 Unsubscribed from match notifications: testa_match_${event.matchId}_$languageCode');
        } else {
          print('❌ Failed to remove match: ${response.statusCode}');
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('❌ Error happened while removing match: $e');
        emit(state.copyWith(status: Status.networkError));
      }
    }
  }

  Future<void> _handleAddFavouriteTeamEvent(
      FollowTeamRequested event, Emitter<FollowingState> emit) async {
    print('⚽ ADD TEAM: Starting to add team ID: ${event.teamId}');
    print('📊 Current state status: ${state.status}');
    if (state.status == Status.notFollowing ||
        state.status == Status.unfollowRequested) {
      emit(state.copyWith(status: Status.followRequested));
      try {
        print('this is ${event.teamId.toString()}');
        final response = await http.post(
            Uri.parse('$url/api/user/addToFavTeam'),
            body: jsonEncode({
              'teamId': event.teamId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.following));
        } else {
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('error happended while adding team to favourite $e');
      }
    }
  }

  Future<void> _handleAddFavouritePlayerEvent(
      FollowPlayerRequested event, Emitter<FollowingState> emit) async {
    print('👤 ADD PLAYER: Starting to add player ID: ${event.playerId}');
    print('📊 Current state status: ${state.status}');
    if (state.status == Status.notFollowing ||
        state.status == Status.unfollowRequested) {
      emit(state.copyWith(status: Status.followRequested));
      try {
        final response = await http.post(
            Uri.parse('$url/api/user/addToFavPlayer'),
            body: jsonEncode({
              'playerId': event.playerId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.following));
        } else {
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('error happended while adding player to favourite $e');
      }
    }
  }

  Future<void> _handleAddFavouritePodcastEvent(
      FollowPodcastRequested event, Emitter<FollowingState> emit) async {
    print('🎙️ ADD PODCAST: Starting to add podcast ID: ${event.podcastId}');
    print('📊 Current state status: ${state.status}');
    
    if (state.status == Status.notFollowing ||
        state.status == Status.unfollowRequested) {
      emit(state.copyWith(status: Status.followRequested));
      
      try {
        final response = await http.post(
          Uri.parse('$url/api/user/addToFavPodcast'),
          body: jsonEncode({
            'podcastId': event.podcastId,
          }),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.following));
          
          // ✨ Subscribe to FCM topic
          if (event.programId != null && event.programId!.isNotEmpty) {
            final languageCode = localLanguageNotifier.value;
            await FCMTopicManager.subscribeToPodcast(
              programId: event.programId!,
              languageCode: languageCode,
            );
            print('🔔 Subscribed to notifications for ${event.programId} in $languageCode');
          }
        } else {
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('error happened while adding podcast to favourite $e');
        emit(state.copyWith(status: Status.networkError));
      }
    }
  }

  Future<void> _handleRemovePodcastEvent(
      RemoveFollowingPodcast event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE PODCAST: Starting to remove podcast ID: ${event.podcastId}');
    print('📊 Current state status: ${state.status}');
    
    if (state.status == Status.following ||
        state.status == Status.followRequested) {
      emit(state.copyWith(status: Status.unfollowRequested));

      try {
        final response = await http.post(
          Uri.parse('$url/api/user/removeFavPodcast'),
          body: jsonEncode({
            'podcastId': event.podcastId,
          }),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          },
        );
        
        print(response.statusCode);

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.notFollowing));
          
          // ✨ Unsubscribe from FCM topic
          if (event.programId != null && event.programId!.isNotEmpty) {
            final languageCode = localLanguageNotifier.value;
            await FCMTopicManager.unsubscribeFromPodcastTopic(
              programId: event.programId!,
              languageCode: languageCode,
            );
            print('🔕 Unsubscribed from notifications for ${event.programId} in $languageCode');
          }
        } else {
          emit(state.copyWith(status: Status.networkError));
        }
      } catch (e) {
        print('error happened $e');
        emit(state.copyWith(status: Status.networkError));
      }
    }
  }

  Future<void> _handleRemoveFavouriteTeamEvent(
      RemoveFollowingTeam event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE TEAM: Starting to remove team ID: ${event.teamId}');
    print('📊 Current state status: ${state.status}');
    if (state.status == Status.following ||
        state.status == Status.followRequested) {
      emit(state.copyWith(status: Status.unfollowRequested));
      print('this is ${event.teamId.toString()}');
      try {
        final response = await http.post(
            Uri.parse('$url/api/user/removeFavTeam'),
            body: jsonEncode({
              'teamId': event.teamId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });
        print(response.statusCode);

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.notFollowing));
        } else {
          emit(state.copyWith(status: Status.unknownError));
        }
      } catch (e) {
        print('error happened $e');
        emit(state.copyWith(status: Status.unknownError));
      }
    }
  }

  Future<void> _handleRemoveFavouritePlayerEvent(
      RemoveFollowingPlayer event, Emitter<FollowingState> emit) async {
    print('🗑️ REMOVE PLAYER: Starting to remove player ID: ${event.playerId}');
    print('📊 Current state status: ${state.status}');
    if (state.status == Status.following ||
        state.status == Status.followRequested) {
      emit(state.copyWith(status: Status.unfollowRequested));

      try {
        final response = await http.post(
            Uri.parse('$url/api/user/removeFavPlayer'),
            body: jsonEncode({
              'playerId': event.playerId.toString(),
            }),
            headers: {
              'accesstoken': await getAccessToken(),
              'content-type': 'application/json'
            });
        print(response.statusCode);

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(state.copyWith(status: Status.notFollowing));
        } else {
          emit(state.copyWith(status: Status.unknownError));
        }
      } catch (e) {
        print('error happened $e');
        emit(state.copyWith(status: Status.unknownError));
      }
    }
  }

  Future<void> _handleCheckFollowingEvent(
      CheckFollowingMatch event, Emitter<FollowingState> emit) async {
    print('🔍 CHECK MATCH: Starting check for match ID: ${event.matchId}');
    print('📊 Current state status: ${state.status}');
    try {
      print(
          '🔍 CHECK FOLLOWING: Starting check for matchId: ${event.matchId}, checkOnly: ${event.checkOnly}');
      print('📊 Current state status: ${state.status}');

      // Only emit the initial states if not just checking
      if (!event.checkOnly) {
        print('🔄 Emitting requested state');
        emit(state.copyWith(status: Status.requested));
      }

      print('🌐 Sending API request to check following status...');
      final response = await http.post(
          Uri.parse('$url/api/user/checkFollowingMatch'),
          body: jsonEncode({
            'matchId': event.matchId.toString(),
          }),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          });

      print('📡 API Response status code: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        bool? data = parsedData['following'];

        if (data == true) {
          emit(state.copyWith(status: Status.following));
        } else {
          emit(state.copyWith(status: Status.notFollowing));
        }
      } else {
        emit(state.copyWith(status: Status.unknownError));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> _handleCheckFollowingTeam(
      CheckFollowingTeam event, Emitter<FollowingState> emit) async {
    emit(state.copyWith(status: Status.requested));
    try {
      final response = await http.post(
          Uri.parse('$url/api/user/checkFollowingTeam'),
          body: jsonEncode({
            'teamId': event.teamId.toString(),
          }),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          });

      print(response.statusCode);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);

        bool? data = parsedData['following'];
        print(parsedData);
        print(data);

        if (data == true) {
          emit(state.copyWith(status: Status.following));
        } else {
          emit(state.copyWith(status: Status.notFollowing));
        }
      } else {
        emit(state.copyWith(status: Status.unknownError));
      }
    } catch (e) {
      print('error happened $e');
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> _handleCheckFollowingPlayer(
      CheckFollowingPlayer event, Emitter<FollowingState> emit) async {
    // IMPORTANT: Reset to requested so the UI knows we are loading NEW data
    emit(state.copyWith(status: Status.requested));

    try {
      final response = await http.post(
          Uri.parse('$url/api/user/checkFollowingPlayer'),
          body: jsonEncode({'playerId': event.playerId.toString()}),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        bool data = parsedData['following'] ?? false;

        if (data) {
          emit(state.copyWith(status: Status.following));
        } else {
          emit(state.copyWith(status: Status.notFollowing));
        }
      } else {
        emit(state.copyWith(status: Status.unknownError));
      }
    } catch (e) {
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> _handleCheckFollowingPodcast(
      CheckFollowingPodcast event, Emitter<FollowingState> emit) async {
    emit(state.copyWith(status: Status.requested));
    try {
      final response = await http.post(
          Uri.parse('$url/api/user/checkFollowingPodcast'),
          body: jsonEncode({'podcastId': event.podcastId}),
          headers: {
            'accesstoken': await getAccessToken(),
            'content-type': 'application/json'
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedData = jsonDecode(response.body);
        bool? isFollowing = parsedData['following'];

        if (isFollowing == true) {
          final updatedPodcasts = List<String>.from(state.followedPodcasts);
          if (!updatedPodcasts.contains(event.podcastId)) {
            updatedPodcasts.add(event.podcastId);
          }
          emit(state.copyWith(
            status: Status.following,
            followedPodcasts: updatedPodcasts,
          ));
        } else {
          final updatedPodcasts = List<String>.from(state.followedPodcasts)
            ..remove(event.podcastId);
          emit(state.copyWith(
            status: Status.notFollowing,
            followedPodcasts: updatedPodcasts,
          ));
        }
      } else {
        emit(state.copyWith(status: Status.unknownError));
      }
    } catch (e) {
      print('Error checking podcast following status: $e');
      emit(state.copyWith(status: Status.unknownError));
    }
  }

  Future<void> fetchAndSaveFavoritePodcasts() async {
    print('📥 FETCH PODCASTS: Starting to fetch favorite podcasts');
    print('📊 Current state status: ${state.status}');
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

        // Extract podcast IDs and save to Hive
        final List<String> podcastIds = favoritePodcasts
            .map<String>((podcast) => podcast['id'].toString())
            .toList();

        final box = await Hive.openBox<List<String>>('favoritePodcasts');
        await box.put('podcasts', podcastIds);

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
    // We check if the player is ALREADY followed based on the logic
    // passed from the UI or by checking the current status.
    // If the status is already 'following', we REMOVE. Otherwise, we ADD.
    if (state.status == Status.following) {
      // Trigger the existing remove logic
      await _handleRemoveFavouritePlayerEvent(
          RemoveFollowingPlayer(playerId: event.playerId), emit);
    } else {
      // Trigger the existing add logic
      await _handleAddFavouritePlayerEvent(
          FollowPlayerRequested(playerId: event.playerId), emit);
    }
  }
}