import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/Live_Tv_model.dart';
import 'live_tv_State.dart';
import 'live_tv_event.dart';
import '../../../../util/baseUrl.dart';
import 'm3u_parser.dart';

class LiveTvBloc extends Bloc<LiveTvEvent, LiveTvState> {
  LiveTvBloc() : super(LiveTvState.initial()) {
    on<LiveTvRequested>(_onLiveTvRequested);
    on<RecentChannelsRequested>(_onRecentChannelsRequested);
    on<ParseM3ULink>(_onParseM3ULink);
    on<LoadUserAddedChannels>(_onLoadUserAddedChannels);
    on<LoadMoreUserAddedChannels>(_onLoadMoreUserAddedChannels);
    on<FetchSportsChannels>(_onFetchSportsChannels);
    on<FetchNewsChannels>(_onFetchNewsChannels);
  }

  // Fetch recent channels
  Future<void> _onLiveTvRequested(
      LiveTvRequested event, Emitter<LiveTvState> emit) async {
    if (state.status == LiveTvStatus.requestSuccess) return;
    emit(state.copyWith(status: LiveTvStatus.requested));
    try {
      final response =
          await http.get(Uri.parse('${BaseUrl().url}/api/recent-channels'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        final recentChannels =
            responseData.map((json) => LivetvModel.fromJson(json)).toList();
        emit(state.copyWith(
          status: LiveTvStatus.requestSuccess,
          recentChannels: recentChannels,
        ));
      } else {
        emit(state.copyWith(status: LiveTvStatus.networkFailure));
      }
    } catch (e) {
      emit(state.copyWith(status: LiveTvStatus.networkFailure));
    }
  }

  // Re-fetch recent channels
  Future<void> _onRecentChannelsRequested(
      RecentChannelsRequested event, Emitter<LiveTvState> emit) async {
    await _onLiveTvRequested(LiveTvRequested(), emit);
  }

// Optimized M3U parsing handler
  Future<void> _onParseM3ULink(
      ParseM3ULink event, Emitter<LiveTvState> emit) async {
    try {
      // Indicate parsing is in progress
      emit(state.copyWith(
        status: LiveTvStatus.parsing,
        parsingError: null,
      ));

      // Validate URL format
      if (!Uri.parse(event.url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      // Parse the M3U URL with timeout
      final channels = await parseM3U(event.url)
          .timeout(const Duration(seconds: 30))
          .catchError((error) {
        throw Exception('Failed to parse M3U: ${error.toString()}');
      });

      if (channels.isEmpty) {
        throw Exception('No channels found in the M3U file');
      }

      // Save new channels to SharedPreferences
      await _saveUserAddedChannels(channels);

      // Update state with new channels
      emit(state.copyWith(
        status: LiveTvStatus.requestSuccess,
        userAddedChannels: channels.take(20).toList(),
        allUserAddedChannels: channels,
        hasMoreUserAddedChannels: channels.length > 20,
        parsingError: null,
      ));
    } catch (e) {
      // Handle specific error cases
      final errorMessage = _getErrorMessage(e);
      emit(state.copyWith(
        status: LiveTvStatus.requestSuccess, // Keep previous state visible
        parsingError: errorMessage,
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FormatException) {
      return 'Invalid URL format. Please check the URL and try again.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. Please check your internet connection and try again.';
    } else if (error.toString().contains('No channels found')) {
      return 'No channels found in the provided M3U file.';
    } else {
      return 'Failed to load channels. Please try again later.';
    }
  }

  // Optimized storage of user-added channels
  Future<void> _saveUserAddedChannels(List<LivetvModel> channels) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert channels to a more efficient storage format
      final channelsJson = jsonEncode(channels.map((c) => c.toJson()).toList());

      // Store with versioning for future compatibility
      final storageData = jsonEncode({
        'version': '1.0',
        'lastUpdated': DateTime.now().toIso8601String(),
        'channels': channelsJson,
      });

      await prefs.setString('user_added_channels', storageData);
    } catch (e) {
      throw Exception('Failed to save channels: ${e.toString()}');
    }
  }

  // Optimized loading of user-added channels
  Future<void> _onLoadUserAddedChannels(
      LoadUserAddedChannels event, Emitter<LiveTvState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('user_added_channels');

      if (storedData != null) {
        final data = jsonDecode(storedData);
        final channelsJson = jsonDecode(data['channels']) as List<dynamic>;

        final allUserAddedChannels =
            channelsJson.map((json) => LivetvModel.fromJson(json)).toList();

        final initialChannels = allUserAddedChannels.take(20).toList();

        emit(state.copyWith(
          userAddedChannels: initialChannels,
          allUserAddedChannels: allUserAddedChannels,
          hasMoreUserAddedChannels: allUserAddedChannels.length > 20,
          parsingError: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LiveTvStatus.requestSuccess,
        parsingError: 'Failed to load saved channels',
      ));
    }
  }

  // Paginate through user-added channels
  Future<void> _onLoadMoreUserAddedChannels(
      LoadMoreUserAddedChannels event, Emitter<LiveTvState> emit) async {
    final currentCount = state.userAddedChannels.length;
    final moreChannels =
        state.allUserAddedChannels.skip(currentCount).take(20).toList();

    final updatedChannels = [...state.userAddedChannels, ...moreChannels];

    emit(state.copyWith(
      userAddedChannels: updatedChannels,
      hasMoreUserAddedChannels:
          updatedChannels.length < state.allUserAddedChannels.length,
    ));
  }

  // Fetch sports channels with pagination
  Future<void> _onFetchSportsChannels(
      FetchSportsChannels event, Emitter<LiveTvState> emit) async {
    if (state.hasReachedMaxSports) return;

    try {
      final response = await http.get(Uri.parse(
          '${BaseUrl().url}/api/channels/sports?page=${event.page}&limit=10'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final channelsJson = (data['channels'] as List?) ?? [];

        final newChannels =
            channelsJson.map((json) => LivetvModel.fromJson(json)).toList();

        if (newChannels.isEmpty && event.page == 1) {
          emit(state.copyWith(
            sportsChannels: [],
            hasReachedMaxSports: true,
          ));
        } else if (newChannels.isEmpty) {
          emit(state.copyWith(hasReachedMaxSports: true));
        } else {
          final updatedSportsChannels = event.page == 1
              ? newChannels
              : [...state.sportsChannels, ...newChannels];

          emit(state.copyWith(
            sportsChannels: updatedSportsChannels,
            hasReachedMaxSports: false,
          ));
        }
      } else if (response.statusCode == 404) {
        emit(state.copyWith(hasReachedMaxSports: true));
      } else {
        emit(state.copyWith(status: LiveTvStatus.networkFailure));
      }
    } catch (e) {
      emit(state.copyWith(status: LiveTvStatus.networkFailure));
    }
  }

  // Fetch news channels with pagination
  Future<void> _onFetchNewsChannels(
      FetchNewsChannels event, Emitter<LiveTvState> emit) async {
    if (state.hasReachedMaxNews) return;

    try {
      final response = await http.get(Uri.parse(
          '${BaseUrl().url}/api/channels/news?page=${event.page}&limit=10'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final channelsJson = (data['channels'] as List?) ?? [];

        final newChannels =
            channelsJson.map((json) => LivetvModel.fromJson(json)).toList();

        if (newChannels.isEmpty && event.page == 1) {
          emit(state.copyWith(
            newsChannels: [],
            hasReachedMaxNews: true,
          ));
        } else if (newChannels.isEmpty) {
          emit(state.copyWith(hasReachedMaxNews: true));
        } else {
          final updatedNewsChannels = event.page == 1
              ? newChannels
              : [...state.newsChannels, ...newChannels];

          emit(state.copyWith(
            newsChannels: updatedNewsChannels,
            hasReachedMaxNews: false,
          ));
        }
      } else {
        emit(state.copyWith(status: LiveTvStatus.networkFailure));
      }
    } catch (e) {
      emit(state.copyWith(status: LiveTvStatus.networkFailure));
    }
  }
}
