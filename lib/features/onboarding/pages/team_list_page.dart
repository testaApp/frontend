import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/onboarding/pages/team.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(baseUrl: BaseUrl().url));

final selectedItemsNotifier = ValueNotifier<Set<int>>({});

class SelectedCountNotifier {
  static final ValueNotifier<int> selectedCount = ValueNotifier<int>(0);
}

class TeamListPageEntry extends StatefulWidget {
  final String categoryUrl;
  final List<int> selectedIndices;
  final Function(List<int>) onUpdateSelectedIndices;
  final List<FavTeamsData>? preloadedTeams;

  const TeamListPageEntry({
    super.key,
    required this.categoryUrl,
    required this.selectedIndices,
    required this.onUpdateSelectedIndices,
    this.preloadedTeams,
  });

  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPageEntry> {
  late Future<List<FavTeamsData>> _teams;
  Set<int> favteamIDs = {};
  final ScrollController _scrollController = ScrollController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize all data in sequence to avoid multiple rebuilds
  Future<void> _initializeData() async {
    // Initialize local selections without triggering setState
    await _initSelections();

    // Set up teams future
    _teams = widget.preloadedTeams != null
        ? Future.value(widget.preloadedTeams)
        : fetchTeams(widget.categoryUrl);
    unawaited(_teams.then(_prefetchVisibleLogos));

    // Mark as initialized and trigger single rebuild
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// FIX FUNCTION — ensures invalid domain is replaced
  String fixLogoUrl(String url) {
    if (url.contains("media-4.api-sports.io")) {
      return url.replaceAll("media-4.api-sports.io", "media.api-sports.io");
    }
    return url;
  }

  Future<void> _initSelections() async {
    favteamIDs = globalStorageService.getFollowedTeams().toSet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSelectedItemsNotifier();
    });
  }

  void _updateSelectedItemsNotifier() {
    void update() {
      selectedItemsNotifier.value = favteamIDs;
      SelectedCountNotifier.selectedCount.value = favteamIDs.length;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final inBuildPhase = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (inBuildPhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        update();
      });
      return;
    }

    update();
  }

  Future<List<FavTeamsData>> fetchTeams(String categoryUrl) async {
    try {
      final response = await dio.get(
        categoryUrl,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        return _parseTeamsResponse(
          response.data,
          fallbackLeagueId: _extractLeagueIdFromUrl(categoryUrl),
        );
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

  int? _extractLeagueIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final segments = uri?.pathSegments ?? [];
    if (segments.isEmpty) return null;
    return int.tryParse(segments.last);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<FavTeamsData> _parseTeamsResponse(
    dynamic responseData, {
    int? fallbackLeagueId,
  }) {
    final deduped = <int, FavTeamsData>{};

    void addTeam(dynamic rawTeam, int leagueId) {
      if (rawTeam is! Map) return;
      final teamMap = Map<String, dynamic>.from(rawTeam as Map);
      teamMap['leagueId'] ??= leagueId;
      final team = FavTeamsData.fromJson(teamMap);
      if (team.teamId != 0) {
        deduped[team.teamId] = team;
      }
    }

    if (responseData is Map<String, dynamic>) {
      final leagues = responseData['leagues'];
      if (leagues is List) {
        for (final leagueEntry in leagues) {
          if (leagueEntry is! Map) continue;
          final leagueMap = Map<String, dynamic>.from(leagueEntry as Map);
          final leagueId = _toInt(leagueMap['leagueId']) ?? fallbackLeagueId;
          if (leagueId == null) continue;

          final teams = leagueMap['teams'];
          if (teams is! List) continue;

          for (final item in teams) {
            if (item is List) {
              for (final nested in item) {
                addTeam(nested, leagueId);
              }
            } else {
              addTeam(item, leagueId);
            }
          }
        }
      }
    } else if (responseData is List) {
      final leagueId = fallbackLeagueId ?? 0;
      for (final item in responseData) {
        if (item is List) {
          for (final nested in item) {
            addTeam(nested, leagueId);
          }
        } else {
          addTeam(item, leagueId);
        }
      }
    }

    return deduped.values.toList();
  }

  String _resolveTeamLogo(FavTeamsData team) {
    final fixed = fixLogoUrl(team.logo);
    if (fixed.isNotEmpty && fixed.startsWith('http')) {
      return fixed;
    }
    return 'https://media.api-sports.io/football/teams/${team.teamId}.png';
  }

  Future<void> _prefetchVisibleLogos(List<FavTeamsData>? teams) async {
    if (!mounted || teams == null) return;
    for (final team in teams.take(18)) {
      final logoUrl = _resolveTeamLogo(team);
      if (!logoUrl.startsWith('http')) continue;
      final provider = CachedNetworkImageProvider(
        logoUrl,
        cacheManager: onboardingCacheManager,
      );
      unawaited(precacheImage(provider, context));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colorscontainer.greenColor),
        ),
      );
    }

    return FutureBuilder<List<FavTeamsData>>(
      future: _teams,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colorscontainer.greenColor),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (widget.preloadedTeams != null) {
            return _buildEmptyTeamsWidget();
          }
          return _build404Widget();
        } else {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 90.h),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildTeamListItem(snapshot.data![index], index);
            },
          );
        }
      },
    );
  }

  Widget _build404Widget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200.w,
            height: 200.w,
            child: Image.asset(
              'assets/404.gif',
              fit: BoxFit.fitHeight,
              color: Colorscontainer.greenColor,
            ),
          ),
          Text(
            DemoLocalizations.networkProblem,
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _teams = fetchTeams(widget.categoryUrl);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colorscontainer.greenColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              DemoLocalizations.tryAgain,
              style: TextUtils.setTextStyle(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeamsWidget() {
    return Center(
      child: Text(
        'No teams available.',
        style: TextUtils.setTextStyle(
          color: Colorscontainer.greenColor,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildTeamListItem(FavTeamsData team, int index) {
    String teamName = _getLocalizedTeamName(team);
    bool isSelected = favteamIDs.contains(team.teamId);

    return InkWell(
      onTap: () => _onTeamTap(team),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colorscontainer.greenColor.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.15),
                width: isSelected ? 2 : 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        Colorscontainer.greenColor.withOpacity(0.08),
                        Colorscontainer.greenColor.withOpacity(0.04),
                      ]
                    : [
                        Theme.of(context).cardColor.withOpacity(0.5),
                        Theme.of(context).cardColor.withOpacity(0.3),
                      ],
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colorscontainer.greenColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              height: 45.0,
              child: Row(
                children: [
                  _buildTeamLogo(team),
                  Expanded(
                    child: _buildTeamName(
                        teamName, isSelected, Colorscontainer.greenColor),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStarIcon(isSelected),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedTeamName(FavTeamsData team) {
    switch (localLanguageNotifier.value) {
      case 'am':
        return team.Amharicname;
      case 'or':
        return team.Oromoname;
      case 'so':
        return team.Somaliname;
      case 'tr':
        return team.Tigrignaname;
      default:
        return team.name;
    }
  }

  void _onTeamTap(FavTeamsData team) {
    final wasSelected = favteamIDs.contains(team.teamId);
    setState(() {
      int teamId = team.teamId;
      if (favteamIDs.contains(teamId)) {
        favteamIDs.remove(teamId);
      } else {
        favteamIDs.add(teamId);
      }
    });

    final isSelected = !wasSelected;
    unawaited(
      globalAnalyticsService.logOnboardingTeamSelection(
        teamId: team.teamId,
        teamName: team.name,
        isSelected: isSelected,
        source: 'favourite_team_select',
      ),
    );

    final updatedTeams = favteamIDs.toList();
    unawaited(globalStorageService.syncFromServer(teams: updatedTeams));
    if (favteamIDs.contains(team.teamId)) {
      unawaited(
        globalStorageService.setFollowedTeamName(team.teamId, team.name),
      );
    } else {
      unawaited(globalStorageService.removeFollowedTeamName(team.teamId));
    }
    _updateSelectedItemsNotifier();
    widget.onUpdateSelectedIndices(updatedTeams);
  }

  Widget _buildTeamLogo(FavTeamsData team) {
    final resolvedUrl = _resolveTeamLogo(team);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ClipOval(
        child: CachedNetworkImage(
          cacheManager: onboardingCacheManager,
          imageUrl: resolvedUrl,
          width: 35.0,
          height: 35.0,
          fit: BoxFit.contain,
          placeholder: (context, url) => _buildPlaceholderImage(),
          errorWidget: (context, url, error) => _buildPlaceholderImage(),
          memCacheWidth: 70, // Minimal memory usage
          memCacheHeight: 70,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 35.0,
      height: 35.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Image.asset('assets/club-icon.png', width: 20.0, height: 20.0),
    );
  }

  Widget _buildTeamName(String teamName, bool isSelected, Color teamColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        teamName,
        style: TextUtils.setTextStyle(
          textStyle: Theme.of(context).textTheme.labelMedium,
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStarIcon(bool isSelected) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isSelected ? 1.1 : 1.0,
      child: Icon(
        isSelected ? Icons.star_rate_rounded : Icons.star_border_rounded,
        size: 34,
        color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.6),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Keep onboarding logos cached between tabs for faster switching.
final onboardingCacheManager = CacheManager(
  Config(
    'onboardingTeamLogos',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 300,
    repo: JsonCacheInfoRepository(databaseName: 'onboarding_logo_cache'),
    fileService: HttpFileService(),
  ),
);
