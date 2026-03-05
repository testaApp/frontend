import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Service to track user interactions with Firebase Analytics
class FollowingAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _activeScreenName;
  DateTime? _screenEnteredAt;
  bool _screenTrackingPaused = false;

  String? get activeScreenName => _activeScreenName;

  // ========== GENERIC EVENT LOGGING ==========

  /// Log any custom event with parameters
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    final sanitized = _sanitizeParameters(parameters);
    await _analytics.logEvent(
      name: name,
      parameters: sanitized.isEmpty ? null : sanitized,
    );
  }

  // ========== SCREEN + LIFECYCLE TRACKING ==========
  Future<void> trackScreenVisible({
    required String screenName,
    String entryPoint = 'navigation',
  }) async {
    if (screenName.isEmpty) return;
    if (_activeScreenName == screenName && !_screenTrackingPaused) return;

    await _flushActiveScreen(
      exitType: _screenTrackingPaused ? 'resume_replace' : 'navigate',
      nextScreen: screenName,
    );

    _activeScreenName = screenName;
    _screenEnteredAt = DateTime.now();
    _screenTrackingPaused = false;

    await logEvent(
      name: 'screen_enter',
      parameters: {
        'screen_name': screenName,
        'entry_point': entryPoint,
      },
    );
  }

  Future<void> trackScreenHidden({
    required String exitType,
    String? nextScreen,
  }) async {
    await _flushActiveScreen(exitType: exitType, nextScreen: nextScreen);
  }

  Future<void> trackAppLifecycle({
    required AppLifecycleState state,
  }) async {
    await logEvent(
      name: 'app_lifecycle',
      parameters: {
        'state': state.name,
        'screen_name': _activeScreenName ?? 'unknown',
      },
    );

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_screenTrackingPaused) {
        await _flushActiveScreen(
          exitType: 'app_background',
        );
        _screenTrackingPaused = true;
      }
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _screenTrackingPaused &&
        _activeScreenName != null) {
      _screenEnteredAt = DateTime.now();
      _screenTrackingPaused = false;
      await logEvent(
        name: 'screen_resume',
        parameters: {
          'screen_name': _activeScreenName!,
        },
      );
    }
  }

  Future<void> _flushActiveScreen({
    required String exitType,
    String? nextScreen,
  }) async {
    final screenName = _activeScreenName;
    final enteredAt = _screenEnteredAt;
    if (screenName == null || enteredAt == null) return;

    final durationMs = DateTime.now().difference(enteredAt).inMilliseconds;
    if (durationMs < 250) {
      _screenEnteredAt = DateTime.now();
      return;
    }

    await logEvent(
      name: 'screen_stay',
      parameters: {
        'screen_name': screenName,
        'duration_ms': durationMs,
        'exit_type': exitType,
        if (nextScreen != null && nextScreen.isNotEmpty)
          'next_screen': nextScreen,
      },
    );
  }

  // ========== ONBOARDING TRACKING ==========
  Future<void> logOnboardingStepViewed(String stepName) async {
    await logEvent(
      name: 'onboarding_step_viewed',
      parameters: {
        'step_name': stepName,
      },
    );
  }

  Future<void> logOnboardingStepAction({
    required String stepName,
    required String action,
    int? teamCount,
    int? playerCount,
    int? leagueCount,
    Map<String, dynamic>? extraParameters,
  }) async {
    final params = <String, dynamic>{
      'step_name': stepName,
      'action': action,
      if (teamCount != null) 'team_count': teamCount,
      if (playerCount != null) 'player_count': playerCount,
      if (leagueCount != null) 'league_count': leagueCount,
    };
    if (extraParameters != null && extraParameters.isNotEmpty) {
      params.addAll(extraParameters);
    }

    await logEvent(
      name: 'onboarding_step_action',
      parameters: params,
    );
  }

  Future<void> logOnboardingTeamSelection({
    required int teamId,
    required bool isSelected,
    String? teamName,
    String source = 'onboarding',
  }) async {
    await logEvent(
      name: 'onboarding_team_selection',
      parameters: {
        'team_id': teamId,
        'team_name': teamName ?? 'unknown',
        'is_selected': isSelected,
        'source': source,
      },
    );
  }

  Future<void> logOnboardingPlayerSelection({
    required int playerId,
    required bool isSelected,
    String? playerName,
    String source = 'onboarding',
  }) async {
    await logEvent(
      name: 'onboarding_player_selection',
      parameters: {
        'player_id': playerId,
        'player_name': playerName ?? 'unknown',
        'is_selected': isSelected,
        'source': source,
      },
    );
  }

  Future<void> logOnboardingSetupResult({
    required String status,
    int? teamCount,
    int? playerCount,
    int? leagueCount,
    int? statusCode,
    int? durationMs,
    String? errorType,
  }) async {
    await logEvent(
      name: 'onboarding_setup_result',
      parameters: {
        'status': status,
        if (teamCount != null) 'team_count': teamCount,
        if (playerCount != null) 'player_count': playerCount,
        if (leagueCount != null) 'league_count': leagueCount,
        if (statusCode != null) 'status_code': statusCode,
        if (durationMs != null) 'duration_ms': durationMs,
        if (errorType != null && errorType.isNotEmpty) 'error_type': errorType,
      },
    );
  }

  Map<String, Object> _sanitizeParameters(Map<String, dynamic>? params) {
    if (params == null) return <String, Object>{};
    final Map<String, Object> out = <String, Object>{};
    params.forEach((key, value) {
      if (value == null) return;
      if (value is bool) {
        out[key] = value ? 1 : 0;
      } else if (value is DateTime) {
        out[key] = value.millisecondsSinceEpoch;
      } else if (value is num) {
        out[key] = value;
      } else if (value is String) {
        out[key] = value;
      } else {
        out[key] = value.toString();
      }
    });
    return out;
  }

  // ========== MATCH EVENTS ==========

  Future<void> logMatchFollowed(
    int matchId, {
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

  Future<void> logMatchUnfollowed(
    int matchId, {
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

  Future<void> logPodcastUnfollowed(
      String podcastId, String podcastName) async {
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

  Future<void> logSyncCompleted(
    String syncType, {
    int? itemsSynced,
    bool? success,
  }) async {
    await _analytics.logEvent(
      name: 'sync_completed',
      parameters: {
        'sync_type': syncType,
        'items_synced': itemsSynced ?? 0,
        'success': (success ?? true) ? 1 : 0,
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

  Future<void> logMatchDetailsViewed(
    int matchId, {
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

class AppRouteAnalyticsObserver extends NavigatorObserver {
  final FollowingAnalyticsService analytics;

  AppRouteAnalyticsObserver({required this.analytics});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final screen = _screenNameFromRoute(route);
    if (screen == null) return;
    unawaited(analytics.trackScreenVisible(
      screenName: screen,
      entryPoint: 'push',
    ));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final previousScreen = _screenNameFromRoute(previousRoute);
    unawaited(
      analytics.trackScreenHidden(
        exitType: 'pop',
        nextScreen: previousScreen,
      ),
    );
    if (previousScreen != null) {
      unawaited(
        analytics.trackScreenVisible(
          screenName: previousScreen,
          entryPoint: 'pop_resume',
        ),
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final nextScreen = _screenNameFromRoute(newRoute);
    unawaited(
      analytics.trackScreenHidden(
        exitType: 'replace',
        nextScreen: nextScreen,
      ),
    );
    if (nextScreen != null) {
      unawaited(
        analytics.trackScreenVisible(
          screenName: nextScreen,
          entryPoint: 'replace',
        ),
      );
    }
  }

  String? _screenNameFromRoute(Route<dynamic>? route) {
    final routeName = route?.settings.name?.trim();
    if (routeName != null && routeName.isNotEmpty) return routeName;

    final routeType = route?.runtimeType.toString();
    if (routeType == null || routeType.isEmpty) return null;
    return routeType;
  }
}
