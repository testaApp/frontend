import 'package:blogapp/models/Live_Tv_model.dart';

class LiveTvState {
  final LiveTvStatus status;
  final List<LivetvModel> recentChannels;
  final List<LivetvModel> userAddedChannels;
  final List<LivetvModel> allUserAddedChannels;
  final List<LivetvModel> sportsChannels;
  final List<LivetvModel> newsChannels;
  final bool hasMoreUserAddedChannels;
  final bool hasReachedMaxSports;
  final bool hasReachedMaxNews;
  final String? parsingError; // New field for error handling

  LiveTvState({
    required this.status,
    required this.recentChannels,
    required this.userAddedChannels,
    required this.allUserAddedChannels,
    required this.sportsChannels,
    required this.newsChannels,
    required this.hasMoreUserAddedChannels,
    required this.hasReachedMaxSports,
    required this.hasReachedMaxNews,
    this.parsingError,
  });

  factory LiveTvState.initial() {
    return LiveTvState(
      status: LiveTvStatus.initial,
      recentChannels: const [],
      userAddedChannels: const [],
      allUserAddedChannels: const [],
      sportsChannels: const [],
      newsChannels: const [],
      hasMoreUserAddedChannels: false,
      hasReachedMaxSports: false,
      hasReachedMaxNews: false,
      parsingError: null,
    );
  }

  LiveTvState copyWith({
    LiveTvStatus? status,
    List<LivetvModel>? recentChannels,
    List<LivetvModel>? userAddedChannels,
    List<LivetvModel>? allUserAddedChannels,
    List<LivetvModel>? sportsChannels,
    List<LivetvModel>? newsChannels,
    bool? hasMoreUserAddedChannels,
    bool? hasReachedMaxSports,
    bool? hasReachedMaxNews,
    String? parsingError,
  }) {
    return LiveTvState(
      status: status ?? this.status,
      recentChannels: recentChannels ?? this.recentChannels,
      userAddedChannels: userAddedChannels ?? this.userAddedChannels,
      allUserAddedChannels: allUserAddedChannels ?? this.allUserAddedChannels,
      sportsChannels: sportsChannels ?? this.sportsChannels,
      newsChannels: newsChannels ?? this.newsChannels,
      hasMoreUserAddedChannels:
          hasMoreUserAddedChannels ?? this.hasMoreUserAddedChannels,
      hasReachedMaxSports: hasReachedMaxSports ?? this.hasReachedMaxSports,
      hasReachedMaxNews: hasReachedMaxNews ?? this.hasReachedMaxNews,
      parsingError: parsingError,
    );
  }
}

enum LiveTvStatus {
  initial,
  requested,
  parsing, // New status for M3U parsing
  requestSuccess,
  networkFailure,
}
