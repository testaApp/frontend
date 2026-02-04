import 'package:firebase_analytics/firebase_analytics.dart';

/// Service to track user interactions with Firebase Analytics
class FollowingAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ========== GENERIC EVENT LOGGING ==========
  
  /// Log any custom event with parameters
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // ========== MATCH EVENTS ==========
  
  Future<void> logMatchFollowed(int matchId, {
    String? leagueName,
    String? homeTeam,
    String? awayTeam,
  }) async {
    await _analytics.logEvent(
      name: 'match_followed',
      parameters: {
        'match_id': matchId,
        'league_name': leagueName ?? 'unknown',
        'home_team': homeTeam ?? 'unknown',
        'away_team': awayTeam ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logMatchUnfollowed(int matchId, {
    String? leagueName,
    String? homeTeam,
    String? awayTeam,
  }) async {
    await _analytics.logEvent(
      name: 'match_unfollowed',
      parameters: {
        'match_id': matchId,
        'league_name': leagueName ?? 'unknown',
        'home_team': homeTeam ?? 'unknown',
        'away_team': awayTeam ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== TEAM EVENTS ==========
  
  Future<void> logTeamFollowed(int teamId, String teamName) async {
    await _analytics.logEvent(
      name: 'team_followed',
      parameters: {
        'team_id': teamId,
        'team_name': teamName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logTeamUnfollowed(int teamId, String teamName) async {
    await _analytics.logEvent(
      name: 'team_unfollowed',
      parameters: {
        'team_id': teamId,
        'team_name': teamName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== PLAYER EVENTS ==========
  
  Future<void> logPlayerFollowed(int playerId, String playerName) async {
    await _analytics.logEvent(
      name: 'player_followed',
      parameters: {
        'player_id': playerId,
        'player_name': playerName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logPlayerUnfollowed(int playerId, String playerName) async {
    await _analytics.logEvent(
      name: 'player_unfollowed',
      parameters: {
        'player_id': playerId,
        'player_name': playerName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== PODCAST EVENTS ==========
  
  Future<void> logPodcastFollowed(String podcastId, String podcastName) async {
    await _analytics.logEvent(
      name: 'podcast_followed',
      parameters: {
        'podcast_id': podcastId,
        'podcast_name': podcastName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logPodcastUnfollowed(String podcastId, String podcastName) async {
    await _analytics.logEvent(
      name: 'podcast_unfollowed',
      parameters: {
        'podcast_id': podcastId,
        'podcast_name': podcastName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== SYNC EVENTS ==========
  
  Future<void> logSyncStarted(String syncType) async {
    await _analytics.logEvent(
      name: 'sync_started',
      parameters: {
        'sync_type': syncType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logSyncCompleted(String syncType, {
    int? itemsSynced,
    bool? success,
  }) async {
    await _analytics.logEvent(
      name: 'sync_completed',
      parameters: {
        'sync_type': syncType,
        'items_synced': itemsSynced ?? 0,
        'success': success ?? true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logSyncFailed(String syncType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'sync_failed',
      parameters: {
        'sync_type': syncType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== NOTIFICATION PERMISSION ==========
  
  Future<void> logNotificationPermissionRequested(String context) async {
    await _analytics.logEvent(
      name: 'notification_permission_requested',
      parameters: {
        'context': context, // e.g., 'match_follow', 'team_follow'
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logNotificationPermissionGranted(String context) async {
    await _analytics.logEvent(
      name: 'notification_permission_granted',
      parameters: {
        'context': context,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logNotificationPermissionDenied(String context) async {
    await _analytics.logEvent(
      name: 'notification_permission_denied',
      parameters: {
        'context': context,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========== USER ENGAGEMENT ==========
  
  Future<void> logMatchDetailsViewed(int matchId, {
    String? leagueName,
    String? homeTeam,
    String? awayTeam,
  }) async {
    await _analytics.logEvent(
      name: 'match_details_viewed',
      parameters: {
        'match_id': matchId,
        'league_name': leagueName ?? 'unknown',
        'home_team': homeTeam ?? 'unknown',
        'away_team': awayTeam ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> logTabChanged(String tabName, int matchId) async {
    await _analytics.logEvent(
      name: 'match_tab_changed',
      parameters: {
        'tab_name': tabName,
        'match_id': matchId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}