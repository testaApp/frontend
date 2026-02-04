import 'package:hive/hive.dart';

/// Service to handle local storage of following statuses
/// This ensures instant UI updates without waiting for network requests
class FollowingStorageService {
  static const String _boxName = 'following_storage';
  static const String _matchesKey = 'followed_matches';
  static const String _teamsKey = 'followed_teams';
  static const String _playersKey = 'followed_players';
  static const String _podcastsKey = 'followed_podcasts';
  static const String _teamNamesKey = 'followed_team_names';
  static const String _playerNamesKey = 'followed_player_names';
  
  static const String _pendingSyncKey = 'pending_sync';

  late Box<dynamic> _box;

  /// Initialize the storage service
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ========== MATCHES ==========
  
  /// Check if a match is followed locally
  bool isMatchFollowed(int matchId) {
    final matches = _getFollowedMatches();
    return matches.contains(matchId);
  }

  /// Add a match to local following list
  Future<void> addFollowedMatch(int matchId) async {
    final matches = _getFollowedMatches();
    if (!matches.contains(matchId)) {
      matches.add(matchId);
      await _box.put(_matchesKey, matches);
      await _addPendingSync('match', matchId, 'add');
    }
  }

  /// Remove a match from local following list
  Future<void> removeFollowedMatch(int matchId) async {
    final matches = _getFollowedMatches();
    matches.remove(matchId);
    await _box.put(_matchesKey, matches);
    await _addPendingSync('match', matchId, 'remove');
  }

  List<int> _getFollowedMatches() {
    final data = _box.get(_matchesKey, defaultValue: <dynamic>[]);
    return List<int>.from(data);
  }

  // ========== TEAMS ==========
  
  bool isTeamFollowed(int teamId) {
    final teams = _getFollowedTeams();
    return teams.contains(teamId);
  }

  Future<void> addFollowedTeam(int teamId) async {
    final teams = _getFollowedTeams();
    if (!teams.contains(teamId)) {
      teams.add(teamId);
      await _box.put(_teamsKey, teams);
      await _addPendingSync('team', teamId, 'add');
    }
  }

  Future<void> removeFollowedTeam(int teamId) async {
    final teams = _getFollowedTeams();
    teams.remove(teamId);
    await _box.put(_teamsKey, teams);
    await _addPendingSync('team', teamId, 'remove');
  }

  List<int> _getFollowedTeams() {
    final data = _box.get(_teamsKey, defaultValue: <dynamic>[]);
    return List<int>.from(data);
  }

  /// Get all followed team IDs
  List<int> getFollowedTeams() {
    return _getFollowedTeams();
  }

  /// Get followed team names keyed by team ID
  Map<int, String> getFollowedTeamNames() {
    return _getNamesMap(_teamNamesKey);
  }

  /// Set or update a followed team name
  Future<void> setFollowedTeamName(int teamId, String name) async {
    final names = _getNamesMapRaw(_teamNamesKey);
    names[teamId.toString()] = name;
    await _box.put(_teamNamesKey, names);
  }

  /// Remove a followed team name
  Future<void> removeFollowedTeamName(int teamId) async {
    final names = _getNamesMapRaw(_teamNamesKey);
    names.remove(teamId.toString());
    await _box.put(_teamNamesKey, names);
  }

  // ========== PLAYERS ==========
  
  bool isPlayerFollowed(int playerId) {
    final players = _getFollowedPlayers();
    return players.contains(playerId);
  }

  Future<void> addFollowedPlayer(int playerId) async {
    final players = _getFollowedPlayers();
    if (!players.contains(playerId)) {
      players.add(playerId);
      await _box.put(_playersKey, players);
      await _addPendingSync('player', playerId, 'add');
    }
  }

  Future<void> removeFollowedPlayer(int playerId) async {
    final players = _getFollowedPlayers();
    players.remove(playerId);
    await _box.put(_playersKey, players);
    await _addPendingSync('player', playerId, 'remove');
  }

  List<int> _getFollowedPlayers() {
    final data = _box.get(_playersKey, defaultValue: <dynamic>[]);
    return List<int>.from(data);
  }

  /// Get all followed player IDs
  List<int> getFollowedPlayers() {
    return _getFollowedPlayers();
  }

  /// Get followed player names keyed by player ID
  Map<int, String> getFollowedPlayerNames() {
    return _getNamesMap(_playerNamesKey);
  }

  /// Set or update a followed player name
  Future<void> setFollowedPlayerName(int playerId, String name) async {
    final names = _getNamesMapRaw(_playerNamesKey);
    names[playerId.toString()] = name;
    await _box.put(_playerNamesKey, names);
  }

  /// Remove a followed player name
  Future<void> removeFollowedPlayerName(int playerId) async {
    final names = _getNamesMapRaw(_playerNamesKey);
    names.remove(playerId.toString());
    await _box.put(_playerNamesKey, names);
  }

  // ========== PODCASTS ==========
  
  bool isPodcastFollowed(String podcastId) {
    final podcasts = _getFollowedPodcasts();
    return podcasts.contains(podcastId);
  }

  Future<void> addFollowedPodcast(String podcastId) async {
    final podcasts = _getFollowedPodcasts();
    if (!podcasts.contains(podcastId)) {
      podcasts.add(podcastId);
      await _box.put(_podcastsKey, podcasts);
      await _addPendingSync('podcast', podcastId, 'add');
    }
  }

  Future<void> removeFollowedPodcast(String podcastId) async {
    final podcasts = _getFollowedPodcasts();
    podcasts.remove(podcastId);
    await _box.put(_podcastsKey, podcasts);
    await _addPendingSync('podcast', podcastId, 'remove');
  }

  List<String> _getFollowedPodcasts() {
    final data = _box.get(_podcastsKey, defaultValue: <dynamic>[]);
    return List<String>.from(data);
  }

  // ========== PENDING SYNC ==========
  
  /// Track operations that need to be synced to backend
  Future<void> _addPendingSync(String type, dynamic id, String action) async {
    final pending = _getPendingSync();
    pending.add({
      'type': type,
      'id': id.toString(),
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await _box.put(_pendingSyncKey, pending);
  }

  List<Map<String, dynamic>> _getPendingSync() {
    final data = _box.get(_pendingSyncKey, defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(
      data.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  /// Remove a sync operation from pending list
  Future<void> removePendingSync(String type, String id, String action) async {
    final pending = _getPendingSync();
    pending.removeWhere((item) => 
      item['type'] == type && 
      item['id'] == id && 
      item['action'] == action
    );
    await _box.put(_pendingSyncKey, pending);
  }

  /// Get all pending sync operations
  List<Map<String, dynamic>> getPendingSync() {
    return _getPendingSync();
  }

  /// Clear all pending sync operations
  Future<void> clearPendingSync() async {
    await _box.put(_pendingSyncKey, <dynamic>[]);
  }

  // ========== SYNC FROM SERVER ==========
  
  /// Update local storage with data from server
  /// Call this on app startup or after successful sync
  Future<void> syncFromServer({
    List<int>? matches,
    List<int>? teams,
    List<int>? players,
    List<String>? podcasts,
  }) async {
    if (matches != null) await _box.put(_matchesKey, matches);
    if (teams != null) {
      await _box.put(_teamsKey, teams);
      await _pruneNamesForIds(_teamNamesKey, teams);
    }
    if (players != null) {
      await _box.put(_playersKey, players);
      await _pruneNamesForIds(_playerNamesKey, players);
    }
    if (podcasts != null) await _box.put(_podcastsKey, podcasts);
  }

  /// Clear all local data
  Future<void> clearAll() async {
    await _box.clear();
  }

  Map<int, String> _getNamesMap(String key) {
    final raw = _getNamesMapRaw(key);
    final result = <int, String>{};
    for (final entry in raw.entries) {
      final id = int.tryParse(entry.key);
      if (id != null) {
        result[id] = entry.value;
      }
    }
    return result;
  }

  Map<String, String> _getNamesMapRaw(String key) {
    final data = _box.get(key, defaultValue: <String, dynamic>{});
    if (data is! Map) {
      return <String, String>{};
    }
    final raw = Map<String, dynamic>.from(data);
    return raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  Future<void> _pruneNamesForIds(String key, List<int> ids) async {
    final data = _box.get(key, defaultValue: <String, dynamic>{});
    if (data is! Map) {
      await _box.put(key, <String, String>{});
      return;
    }
    final names = Map<String, dynamic>.from(data);
    final allowed = ids.map((id) => id.toString()).toSet();
    names.removeWhere((k, _) => !allowed.contains(k));
    await _box.put(key, names);
  }
}
