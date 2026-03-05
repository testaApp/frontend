import 'package:equatable/equatable.dart';

abstract class LiveTvEvent extends Equatable {
  const LiveTvEvent();

  @override
  List<Object?> get props => [];
}

class LiveTvRequested extends LiveTvEvent {}

class RecentChannelsRequested extends LiveTvEvent {}

// Event for parsing M3U links (user-added channels)
class ParseM3ULink extends LiveTvEvent {
  final String url;

  const ParseM3ULink(this.url);

  @override
  List<Object?> get props => [url];
}

// Event for loading user-added channels
class LoadUserAddedChannels extends LiveTvEvent {}

// Event for loading more user-added channels (pagination)
class LoadMoreUserAddedChannels extends LiveTvEvent {}

// Event for fetching sports channels (with pagination)
class FetchSportsChannels extends LiveTvEvent {
  final int page;

  const FetchSportsChannels({required this.page});

  @override
  List<Object> get props => [page];
}

// Event for fetching news channels (with pagination)
class FetchNewsChannels extends LiveTvEvent {
  final int page;

  const FetchNewsChannels({required this.page});

  @override
  List<Object> get props => [page];
}
