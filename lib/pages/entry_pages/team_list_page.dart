import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import '../../util/baseUrl.dart';
import '../constants/text_utils.dart';
import 'team.dart';
import '../constants/colors.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  const TeamListPageEntry({
    super.key,
    required this.categoryUrl,
    required this.selectedIndices,
    required this.onUpdateSelectedIndices,
  });

  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPageEntry> {
  late Future<List<FavTeamsData>> _teams;
  Set<int> _selectedIndices = {};
  Set<int> favteamIDs = {};
  final ScrollController _scrollController = ScrollController();
  int _visibleItemCount = 20;

  final Map<String, Color> _logoColors = {};
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
    _teams = fetchTeams(widget.categoryUrl);

    // Add scroll listener
    _scrollController.addListener(_loadMoreItems);

    // Mark as initialized and trigger single rebuild
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _selectedIndices = Set.from(widget.selectedIndices);
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
        final List<dynamic> responseData = response.data;
        List<FavTeamsData> allTeams = [];

        for (var item in responseData) {
          if (item is List) {
            allTeams.addAll(item.map((json) => FavTeamsData.fromJson(json)));
          } else if (item is Map<String, dynamic>) {
            allTeams.add(FavTeamsData.fromJson(item));
          }
        }

        print("Parsed ${allTeams.length} teams");

        // Extract colors in background (lightweight, useful for visual appeal)
        Future.microtask(() {
          _batchPreloadTeamColors(allTeams.take(20).toList());
        });

        return allTeams;
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

  /// Batch preload colors (lightweight - only for visual appeal)
  Future<void> _batchPreloadTeamColors(List<FavTeamsData> teams) async {
    final Map<String, Color> newColors = {};

    for (var team in teams) {
      final fixedUrl = fixLogoUrl(team.leagueId.toString());
      if (fixedUrl.isNotEmpty &&
          fixedUrl.startsWith('http') &&
          !_logoColors.containsKey(fixedUrl)) {
        final color = await _getColorForUrl(fixedUrl);
        newColors[fixedUrl] = color;
      }
    }

    // Single setState with all colors at once
    if (mounted && newColors.isNotEmpty) {
      setState(() {
        _logoColors.addAll(newColors);
      });
    }
  }

  /// Get color for a URL without triggering setState
  Future<Color> _getColorForUrl(String logoUrl) async {
    if (logoUrl.isEmpty || !logoUrl.startsWith('http')) {
      return Theme.of(context).cardColor;
    }

    try {
      final imageProvider = CachedNetworkImageProvider(
        logoUrl,
        cacheManager: onboardingCacheManager,
      );
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(50, 50),
        timeout: const Duration(seconds: 5),
      );

      final dominantColor = paletteGenerator.dominantColor?.color;
      return dominantColor ?? Theme.of(context).cardColor;
    } catch (e) {
      return Theme.of(context).cardColor;
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
          return _build404Widget();
        } else {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 90.h),
            itemCount: _visibleItemCount.clamp(0, snapshot.data!.length),
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
                  _buildTeamLogo(team.logo),
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
        return team.Amharicname;
      default:
        return team.name;
    }
  }

  void _onTeamTap(FavTeamsData team) {
    setState(() {
      int teamId = team.teamId;
      if (favteamIDs.contains(teamId)) {
        favteamIDs.remove(teamId);
      } else {
        favteamIDs.add(teamId);
      }
    });
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

  Widget _buildTeamLogo(String logoUrl) {
    final fixedUrl = fixLogoUrl(logoUrl);

    // Safety check: show placeholder if URL is invalid
    if (fixedUrl.isEmpty || !fixedUrl.startsWith('http')) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: _buildPlaceholderImage(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ClipOval(
        child: CachedNetworkImage(
          cacheManager: onboardingCacheManager,
          imageUrl: fixedUrl,
          width: 35.0,
          height: 35.0,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            width: 35.0,
            height: 35.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colorscontainer.greenColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholderImage(),
          memCacheWidth: 70, // Minimal memory usage
          memCacheHeight: 70,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 200),
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

  void _loadMoreItems() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _visibleItemCount += 20;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clear the onboarding cache when leaving
    onboardingCacheManager.emptyCache();
    super.dispose();
  }
}

// Minimal cache ONLY for onboarding - auto-cleared on exit
final onboardingCacheManager = CacheManager(
  Config(
    'onboardingTeamLogos',
    stalePeriod: const Duration(hours: 1), // Very short - only for session
    maxNrOfCacheObjects: 50, // Minimal - just enough for visible items
    repo: JsonCacheInfoRepository(databaseName: 'onboarding_logo_cache'),
    fileService: HttpFileService(),
  ),
);
