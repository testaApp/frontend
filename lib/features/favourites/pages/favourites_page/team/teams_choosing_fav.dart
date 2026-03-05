import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/features/onboarding/pages/team.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/state/application/following/following_bloc.dart';
import 'package:blogapp/state/application/following/following_event.dart';

class TeamsPage extends StatefulWidget {
  final Set<int> selectedTeamIDs;

  const TeamsPage({super.key, required this.selectedTeamIDs});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage>
    with SingleTickerProviderStateMixin {
  static const List<int> _leagueIds = [
    363,
    39,
    140,
    135,
    78,
    61,
    307,
    288,
    203,
    233,
    253,
    88,
    144,
    94,
    179,
    305,
  ];

  static Map<int, List<FavTeamsData>> _sessionTeamsByLeague = {};
  static Set<int> _sessionMissingLeagueIds = {};
  static DateTime? _sessionCacheAt;
  static const Duration _sessionCacheTtl = Duration(minutes: 10);

  final String url = BaseUrl().url;

  late TabController _tabController;
  late Set<int> selectedTeamIDs;

  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  Map<int, List<FavTeamsData>> _teamsByLeague = {};
  Set<int> _missingLeagueIds = {};

  List<String> get _leagueNames => [
        DemoLocalizations.ethiopia,
        DemoLocalizations.england,
        DemoLocalizations.spain,
        DemoLocalizations.italy,
        DemoLocalizations.germany,
        DemoLocalizations.france,
        DemoLocalizations.saudi,
        DemoLocalizations.southAfrica,
        DemoLocalizations.turkey,
        DemoLocalizations.egypt,
        DemoLocalizations.USA,
        DemoLocalizations.netherland,
        DemoLocalizations.belgium,
        DemoLocalizations.portugal,
        DemoLocalizations.scotland,
        DemoLocalizations.qatar,
      ];

  bool get _hasFreshSessionCache {
    if (_sessionCacheAt == null || _sessionTeamsByLeague.isEmpty) {
      return false;
    }
    return DateTime.now().difference(_sessionCacheAt!) <= _sessionCacheTtl;
  }

  @override
  void initState() {
    super.initState();
    selectedTeamIDs = {
      ...widget.selectedTeamIDs,
      ...globalStorageService.getFollowedTeams(),
    };

    _tabController = TabController(length: _leagueIds.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    if (_hasFreshSessionCache) {
      _teamsByLeague = _cloneTeamsMap(_sessionTeamsByLeague);
      _missingLeagueIds = Set<int>.from(_sessionMissingLeagueIds);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _prefetchCurrentAndNearbyLogos();
      });
    } else {
      _loadTeams(refresh: true);
    }
  }

  Map<int, List<FavTeamsData>> _cloneTeamsMap(
    Map<int, List<FavTeamsData>> source,
  ) {
    return source.map(
      (leagueId, teams) => MapEntry(leagueId, List<FavTeamsData>.from(teams)),
    );
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_selectedIndex == _tabController.index) return;

    setState(() {
      _selectedIndex = _tabController.index;
    });

    _prefetchCurrentAndNearbyLogos();
  }

  Future<void> _loadTeams({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && _teamsByLeague.isNotEmpty) {
      _prefetchCurrentAndNearbyLogos();
      return;
    }

    setState(() {
      _isLoading = true;
      if (refresh) {
        _hasError = false;
        _errorMessage = '';
      }
    });

    try {
      final payload = await _fetchAllLeagues();

      if (!mounted) return;
      setState(() {
        _teamsByLeague = payload.teamsByLeague;
        _missingLeagueIds = payload.missingLeagueIds;
        _isLoading = false;
        _hasError = false;
      });

      _sessionTeamsByLeague = _cloneTeamsMap(_teamsByLeague);
      _sessionMissingLeagueIds = Set<int>.from(_missingLeagueIds);
      _sessionCacheAt = DateTime.now();

      _prefetchCurrentAndNearbyLogos();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<_FavListChoosePayload> _fetchAllLeagues() async {
    final response = await http.get(
      Uri.parse('$url/api/favlistchoose'),
      headers: await buildAuthHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load teams (${response.statusCode})');
    }

    final dynamic jsonResponse = json.decode(response.body);
    return _parseFavListChoosePayload(jsonResponse);
  }

  _FavListChoosePayload _parseFavListChoosePayload(dynamic jsonResponse) {
    final Map<int, List<FavTeamsData>> leaguesMap = {
      for (final leagueId in _leagueIds) leagueId: <FavTeamsData>[],
    };
    final Set<int> missingLeagueIds = {};

    if (jsonResponse is Map<String, dynamic>) {
      final leagues = jsonResponse['leagues'];
      if (leagues is List) {
        for (final leagueEntry in leagues) {
          if (leagueEntry is! Map) continue;
          final leagueMap = Map<String, dynamic>.from(leagueEntry as Map);
          final leagueId = _toInt(leagueMap['leagueId']);
          if (leagueId == null) continue;

          leaguesMap[leagueId] =
              _parseTeamsList(rawTeams: leagueMap['teams'], leagueId: leagueId);
        }
      }

      final missing = jsonResponse['missingLeagueIds'];
      if (missing is List) {
        missingLeagueIds.addAll(
          missing.map(_toInt).whereType<int>(),
        );
      }

      return _FavListChoosePayload(
        teamsByLeague: leaguesMap,
        missingLeagueIds: missingLeagueIds,
      );
    }

    if (jsonResponse is List) {
      final fallbackLeagueId = _leagueIds[_selectedIndex];
      leaguesMap[fallbackLeagueId] =
          _parseTeamsList(rawTeams: jsonResponse, leagueId: fallbackLeagueId);
    }

    return _FavListChoosePayload(
      teamsByLeague: leaguesMap,
      missingLeagueIds: missingLeagueIds,
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<FavTeamsData> _parseTeamsList({
    required dynamic rawTeams,
    required int leagueId,
  }) {
    final flattened = <dynamic>[];

    if (rawTeams is List) {
      for (final item in rawTeams) {
        if (item is List) {
          flattened.addAll(item);
        } else {
          flattened.add(item);
        }
      }
    }

    final deduped = <int, FavTeamsData>{};

    for (final item in flattened) {
      if (item is! Map) continue;
      final normalized = Map<String, dynamic>.from(item as Map);
      normalized['leagueId'] ??= leagueId;

      final team = FavTeamsData.fromJson(normalized);
      if (team.teamId == 0) continue;

      deduped[team.teamId] = team;
    }

    final teams = deduped.values.toList();
    teams.sort((a, b) {
      if (a.rank == 0 && b.rank == 0) {
        return a.name.compareTo(b.name);
      }
      if (a.rank == 0) return 1;
      if (b.rank == 0) return -1;
      return a.rank.compareTo(b.rank);
    });

    return teams;
  }

  void _prefetchCurrentAndNearbyLogos() {
    _prefetchLogosForTab(_selectedIndex);
    _prefetchLogosForTab(_selectedIndex + 1);
    _prefetchLogosForTab(_selectedIndex - 1);
  }

  void _prefetchLogosForTab(int tabIndex) {
    if (!mounted || tabIndex < 0 || tabIndex >= _leagueIds.length) return;

    final leagueId = _leagueIds[tabIndex];
    final teams = _teamsByLeague[leagueId] ?? const <FavTeamsData>[];
    for (final team in teams.take(18)) {
      final logoUrl = _resolveTeamLogo(team);
      if (!logoUrl.startsWith('http')) continue;

      final provider = CachedNetworkImageProvider(
        logoUrl,
        cacheManager: favTeamLogoCacheManager,
      );
      unawaited(precacheImage(provider, context));
    }
  }

  void _toggleFavorite(FavTeamsData team) {
    final teamId = team.teamId;
    final wasSelected = selectedTeamIDs.contains(teamId);
    final teamNameForStorage = _getStorageTeamName(team);

    setState(() {
      if (wasSelected) {
        selectedTeamIDs.remove(teamId);
      } else {
        selectedTeamIDs.add(teamId);
      }
    });

    context.read<FollowingBloc>().add(
          wasSelected
              ? RemoveFollowingTeam(
                  teamId: teamId, teamName: teamNameForStorage)
              : FollowTeamRequested(
                  teamId: teamId, teamName: teamNameForStorage),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSelected
              ? 'Team removed from favorites'
              : 'Team added to favorites',
        ),
        backgroundColor: Colorscontainer.greenColor,
      ),
    );
  }

  String _getStorageTeamName(FavTeamsData team) {
    if (team.name.trim().isNotEmpty) return team.name;
    final localized = _getLocalizedTeamName(team);
    if (localized.trim().isNotEmpty) return localized;
    return team.teamId.toString();
  }

  String _getLocalizedTeamName(FavTeamsData team) {
    switch (localLanguageNotifier.value) {
      case 'am':
      case 'tr':
        return team.Amharicname;
      case 'or':
        return team.Oromoname;
      case 'so':
        return team.Somaliname;
      default:
        return team.name;
    }
  }

  String _apiFootballLogoUrl(int teamId) =>
      'https://media.api-sports.io/football/teams/$teamId.png';

  String _fixLogoUrl(String logoUrl) {
    if (logoUrl.contains('media-4.api-sports.io')) {
      return logoUrl.replaceAll('media-4.api-sports.io', 'media.api-sports.io');
    }
    return logoUrl;
  }

  String _resolveTeamLogo(FavTeamsData team) {
    final logo = _fixLogoUrl(team.logo.trim());
    if (logo.isNotEmpty && logo.startsWith('http')) return logo;
    return _apiFootballLogoUrl(team.teamId);
  }

  Widget _buildTeamListItem(FavTeamsData team) {
    final bool isSelected = selectedTeamIDs.contains(team.teamId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = Colorscontainer.greenColor;
    final localizedName = _getLocalizedTeamName(team);
    final teamName =
        localizedName.trim().isNotEmpty ? localizedName : team.name;

    return Padding(
      key: ValueKey('team_${team.teamId}'),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _toggleFavorite(team),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        accent.withOpacity(0.18),
                        accent.withOpacity(0.06),
                      ]
                    : [
                        colorScheme.surface.withOpacity(0.85),
                        colorScheme.surface.withOpacity(0.65),
                      ],
              ),
              border: Border.all(
                color: isSelected
                    ? accent.withOpacity(0.55)
                    : colorScheme.outline.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? accent.withOpacity(0.25)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  _buildTeamLogo(_resolveTeamLogo(team), isSelected),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtils.setTextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildFollowPill(isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl, bool isSelected) {
    final accent = Colorscontainer.greenColor;

    return Container(
      width: 44.w,
      height: 44.w,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
        border: Border.all(
          color: isSelected
              ? accent.withOpacity(0.6)
              : Colors.white.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          cacheManager: favTeamLogoCacheManager,
          imageUrl: logoUrl,
          fit: BoxFit.contain,
          memCacheWidth: 120,
          memCacheHeight: 120,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (_, __) => _buildLogoPlaceholder(),
          errorWidget: (_, __, ___) => _buildLogoPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Icon(
        Icons.shield_outlined,
        size: 22.sp,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildFollowPill(bool isSelected) {
    final accent = Colorscontainer.greenColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: isSelected ? accent : accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? accent : accent.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
        size: 18.sp,
        color: isSelected ? Colors.white : accent,
      ),
    );
  }

  Widget _buildSkeletonItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: baseColor,
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLeagueState(int leagueId) {
    final isMissing = _missingLeagueIds.contains(leagueId);
    final text = isMissing
        ? 'No teams available for this league yet.'
        : 'No teams found.';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(top: 120.h),
      children: [
        Center(
          child: Text(
            text,
            style: TextUtils.setTextStyle(fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamList(int leagueId) {
    final teams = _teamsByLeague[leagueId] ?? const <FavTeamsData>[];

    if (_isLoading && _teamsByLeague.isEmpty) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 120.h),
        itemCount: 10,
        itemBuilder: (_, __) => _buildSkeletonItem(),
      );
    }

    if (teams.isEmpty) {
      return _buildEmptyLeagueState(leagueId);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: 120.h),
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemCount: teams.length,
      itemBuilder: (_, index) => _buildTeamListItem(teams[index]),
    );
  }

  Widget _buildHeader() {
    final count = selectedTeamIDs.length;
    final countText = count > 0
        ? '$count ${DemoLocalizations.teamSelected}'
        : DemoLocalizations.teamSelected;
    final accent = Colorscontainer.greenColor;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface.withOpacity(0.85),
              accent.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: accent.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.stars_rounded, color: accent, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              DemoLocalizations.favouriteTeam,
              style: TextUtils.setTextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _buildCountChip(countText),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(String text) {
    final accent = Colorscontainer.greenColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14.sp, color: accent),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    final base = Theme.of(context).scaffoldBackgroundColor;
    final accent = Colorscontainer.greenColor;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base,
              base.withOpacity(0.95),
              accent.withOpacity(0.04),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _buildGlowOrb(accent.withOpacity(0.18), 220),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: _buildGlowOrb(accent.withOpacity(0.12), 260),
            ),
            Positioned(
              top: 180,
              left: -40,
              child: _buildGlowOrb(accent.withOpacity(0.08), 180),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(20.h),
        child: SizedBox(
          height: 40.h,
          child: ExtendedTabBar(
            controller: _tabController,
            isScrollable: true,
            physics: const BouncingScrollPhysics(),
            indicator: MaterialIndicator(
              topLeftRadius: 5.w,
              topRightRadius: 5.w,
              color: Colorscontainer.greenColor,
              strokeWidth: 2.w,
              horizontalPadding: 5.w,
            ),
            indicatorPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            indicatorColor: Colorscontainer.greenColor,
            indicatorWeight: 3,
            labelStyle: TextUtils.setTextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextUtils.setTextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.7),
              fontSize: 14.sp,
            ),
            tabs: _leagueNames.asMap().entries.map((entry) {
              final index = entry.key;
              final name = entry.value;
              return _customTab(name, _selectedIndex == index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _customTab(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextUtils.setTextStyle(
          color: isSelected
              ? Colorscontainer.greenColor
              : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(top: 110.h, left: 20.w, right: 20.w),
      children: [
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextUtils.setTextStyle(fontSize: 13.sp),
        ),
        SizedBox(height: 12.h),
        Center(
          child: ElevatedButton(
            onPressed: () => _loadTeams(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorscontainer.greenColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: Colorscontainer.greenColor,
                  onRefresh: () => _loadTeams(refresh: true),
                  child: _hasError && _teamsByLeague.isEmpty
                      ? _buildErrorView()
                      : TabBarView(
                          controller: _tabController,
                          children: _leagueIds
                              .map((leagueId) => _buildTeamList(leagueId))
                              .toList(),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}

class _FavListChoosePayload {
  final Map<int, List<FavTeamsData>> teamsByLeague;
  final Set<int> missingLeagueIds;

  const _FavListChoosePayload({
    required this.teamsByLeague,
    required this.missingLeagueIds,
  });
}

final CacheManager favTeamLogoCacheManager = CacheManager(
  Config(
    'favTeamLogos',
    stalePeriod: const Duration(days: 14),
    maxNrOfCacheObjects: 500,
    repo: JsonCacheInfoRepository(databaseName: 'fav_team_logo_cache'),
    fileService: HttpFileService(),
  ),
);
