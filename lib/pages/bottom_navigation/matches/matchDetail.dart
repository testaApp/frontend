import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../application/following/following_bloc.dart';
import '../../../application/following/following_event.dart';
import '../../../application/following/following_state.dart';
import '../../../application/matchdetail/fixtureEvents/events/bloc/fixtureevent_bloc.dart';
import '../../../application/matchdetail/fixtureEvents/events/bloc/fixtureevent_event.dart';
import '../../../application/matchdetail/match/match_bloc.dart';
import '../../../application/matchdetail/match/match_event.dart';
import '../../../application/matchdetail/match/match_state.dart';
import '../../../application/matchdetail/matchStatistics/match_statistics_bloc.dart';
import '../../../application/matchdetail/matchStatistics/match_statistics_state.dart';
import '../../../components/getAmharicDay.dart';
import '../../../components/routenames.dart';
import '../../../components/timeFormatter.dart';
import '../../../localization/demo_localization.dart';
import '../../../models/fixtures/stat.dart';
import '../../../models/teamName.dart';
import '../../../services/analytics_service.dart';
import 'match_detail/match_info_tab.dart';
import 'match_detail/head_to_head.dart';
import 'match_detail/lineups.dart';
import 'match_detail/stat/team_stat.dart';
import 'match_status.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';

class MatchDetailsPage extends StatefulWidget {
  final Stat? stat;
  final int? fixtureId;
  final String leagueName;

  const MatchDetailsPage(
      {super.key, this.stat, this.fixtureId, this.leagueName = ''});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}
class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedTabIndex = 0;
  bool? condition;
  bool? conditionOne;
  bool? conditionTwo;
  Stat? fetchedMatch;
  Timer? _countdownTimer;
  final FollowingAnalyticsService _analyticsService = FollowingAnalyticsService();


  @override
  void initState() {
    super.initState();

    if (widget.stat != null && widget.stat!.fixtureId != null) {
      context.read<FollowingBloc>().add(CheckFollowingMatch(
          matchId: widget.stat!.fixtureId!, checkOnly: true));

      context.read<MatchBloc>().state.stat = widget.stat;
      context.read<MatchBloc>().state.status = matchStatus.requestSuccessed;
      context
          .read<MatchBloc>()
          .add(RefreshMatch(fixtureId: widget.stat!.fixtureId));

      context
          .read<FixtureeventBloc>()
          .add(FixtureEventsRequested(fixtureId: widget.stat!.fixtureId));
      
      // ADD ANALYTICS TRACKING
      _analyticsService.logMatchDetailsViewed(
        widget.stat!.fixtureId!,
        leagueName: widget.leagueName,
        homeTeam: widget.stat!.homeTeam.name,
        awayTeam: widget.stat!.awayTeam.name,
      );
    } else {
      context.read<MatchBloc>().add(GetMatchById(fixtureId: widget.fixtureId!));
      context
          .read<FixtureeventBloc>()
          .add(FixtureEventsRequested(fixtureId: widget.fixtureId!));
    }

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        updateSelectedIdx(_tabController.index);
      }
    });

    _startCountdownTimer();
  }

  void updateSelectedIdx(int wgtIdx) {
    setState(() {
      selectedTabIndex = wgtIdx;
      _tabController.animateTo(wgtIdx);
    });
    
    // ADD ANALYTICS FOR TAB CHANGES
    if (fetchedMatch?.fixtureId != null) {
      final tabNames = ['Info', 'Lineups', 'Statistics', 'Head to Head', 'Video'];
      if (wgtIdx < tabNames.length) {
        _analyticsService.logTabChanged(tabNames[wgtIdx], fetchedMatch!.fixtureId!);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }


  void _handleBackPress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state.status == matchStatus.requestSuccessed &&
            state.stat != null) {
          setState(() {
            fetchedMatch = state.stat;
          });
        }
      },
      child: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state.stat != null) {
            fetchedMatch = state.stat!;
            String secondHalfTime =
                fetchedMatch!.secondHalfTime ?? DateTime.now().toString();
            bool newCondition = ![
                  'FT',
                  'PST',
                  'AET',
                  'CANC',
                  'NS',
                  'ABD',
                  'AWD',
                  'WO'
                ].contains(state.stat?.status) &&
                (state.stat?.kickOfTime != null || state.stat?.time != null);

            List<Widget> screens = [
              if (fetchedMatch != null) ...[
                MatchInfoTab(
                    homeTeamId: fetchedMatch!.homeTeam.id,
                    awayTeamId: fetchedMatch!.awayTeam.id,
                    venue: fetchedMatch!.venue,
                    city: fetchedMatch!.city, // ← ADD THIS LINE
                    referee: fetchedMatch!.referee,
                    homeTeamGoal: fetchedMatch!.homeTeam.goal,
                    awayTeamGoal: fetchedMatch!.awayTeam.goal,
                    fixtureId: fetchedMatch!.fixtureId,
                    status: fetchedMatch!.status,
                    awayTeamLogo: fetchedMatch!.awayTeam.logo,
                    homeTeamLogo: fetchedMatch!.homeTeam.logo,
                    awayTeamName: fetchedMatch!.awayTeam.name,
                    homeTeamName: fetchedMatch!.homeTeam.name,
                    matchDate: fetchedMatch!.dateOnly,
                    matchTime: fetchedMatch!.time,
                    displayLeagueName:
                        widget.leagueName, // ← Pass the one from previous page

                    round: fetchedMatch!.round,
                    leagueLogo: fetchedMatch!.leaguelogo,
                    VideoId: fetchedMatch!.VideoId),
                LineupsView(
                  homeTeamId: fetchedMatch!.homeTeam.id,
                  awayTeamId: fetchedMatch!.awayTeam.id,
                  awayTeamName: fetchedMatch!.awayTeam.name,
                  homeTeamName: fetchedMatch!.homeTeam.name,
                  fixtureId: fetchedMatch!.fixtureId!,
                ),
                TeamsStat(
                  homeTeamLogo: fetchedMatch!.homeTeam.logo,
                  awayTeamLogo: fetchedMatch!.awayTeam.logo,
                  homeTeamId: fetchedMatch!.homeTeam.id,
                  awayTeamId: fetchedMatch!.awayTeam.id,
                  fixtureId: fetchedMatch!.fixtureId,
                ),
                HeadToHeadPage(
                    homeTeamId: fetchedMatch!.homeTeam.id,
                    awayTeamId: fetchedMatch!.awayTeam.id,
                    currentFixtureId: fetchedMatch!.fixtureId),
                if (fetchedMatch!.VideoId != null) SizedBox()
              ] else
                const Center(child: CircularProgressIndicator()),
            ];
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 230.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.green.shade900
                                  : Colors.green.shade800,
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.green.shade800
                                  : Colors.green.shade600,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.1,
                              child: Image.asset(
                                'assets/meda.jpeg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 40.h,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 50.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.leagueName,
                                            style: TextUtils.setTextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 15.h),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: _buildTeamInfo(
                                                context,
                                                fetchedMatch!.homeTeam,
                                                isHome: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: _buildScoreSection(
                                                  fetchedMatch!),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: _buildTeamInfo(
                                                context,
                                                fetchedMatch!.awayTeam,
                                                isHome: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors
                                          .grey[900] // Dark theme background
                                      : Colors.white, // Light theme background
                                  borderRadius: BorderRadius.circular(25.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black26
                                          : Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildTabItem(0, Icons.info_outline,
                                        DemoLocalizations.detail),
                                    if (fetchedMatch?.homeTeam.id != null &&
                                        fetchedMatch?.awayTeam.id != null)
                                      _buildTabItem(1, Icons.people_outline,
                                          DemoLocalizations.lineUp),
                                    if (fetchedMatch?.homeTeam.id != null &&
                                        fetchedMatch?.awayTeam.id != null)
                                      _buildTabItem(2, Icons.bar_chart,
                                          DemoLocalizations.statistics),
                                    if (fetchedMatch?.homeTeam.id != null &&
                                        fetchedMatch?.awayTeam.id != null)
                                      _buildTabItem(3, Icons.sports_soccer,
                                          DemoLocalizations.games),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: screens[selectedTabIndex],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 5.w,
                    top: 20.h,
                    child: IconButton(
                      onPressed: () => _handleBackPress(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
               Positioned(
  right: 5.w,
  top: 20.h,
  child: BlocBuilder<FollowingBloc, FollowingState>(
    builder: (context, state) {
      final isFollowing = state.status == Status.following;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.05),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: isFollowing ? 1.0 : value, // stop pulsing when followed
            child: child,
          );
        },
        child: LikeButton(
          isLiked: isFollowing,
          size: 46,
          circleColor: CircleColor(
            start: Colors.white,
            end: Colorscontainer.greenColor,
          ),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colorscontainer.greenColor,
            dotSecondaryColor: Colors.white,
          ),
          likeBuilder: (isLiked) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
  shape: BoxShape.circle,
  color: Colors.black.withOpacity(0.25),
  border: Border.all(
    color: isLiked
        ? Colors.white        // 👈 white stroke when followed
        : Colors.white.withOpacity(0.25),
    width: isLiked ? 2 : 1.2, // slightly thicker when active
  ),
  boxShadow: [
    if (isLiked)
      BoxShadow(
        color: Colorscontainer.greenColor.withOpacity(0.6),
        blurRadius: 14,
        spreadRadius: 1,
      ),
  ],
),

              child: Icon(
                CupertinoIcons.bell_fill,
                size: 24,
                color: isLiked
                    ? Colorscontainer.greenColor
                    : Colors.white.withOpacity(0.9),
              ),
            );
          },
          onTap: (isLiked) async {
            var status = await Permission.notification.status;

            if (!status.isGranted) {
              await _analyticsService.logNotificationPermissionRequested('match_follow');
              await openNotificationSettings(context);
              status = await Permission.notification.status;

              if (status.isGranted) {
                await _analyticsService.logNotificationPermissionGranted('match_follow');
              } else {
                await _analyticsService.logNotificationPermissionDenied('match_follow');
              }
            }

            if (status.isGranted) {
              if (!isLiked) {
                HapticFeedback.mediumImpact();
                context.read<FollowingBloc>().add(
                  AddFavouriteMatchEvent(
                    matchId: fetchedMatch!.fixtureId,
                    leagueName: widget.leagueName,
                    homeTeam: fetchedMatch!.homeTeam.name,
                    awayTeam: fetchedMatch!.awayTeam.name,
                  ),
                );
              } else {
                context.read<FollowingBloc>().add(
                  RemoveFavouriteMatchEvent(
                    matchId: fetchedMatch!.fixtureId,
                    leagueName: widget.leagueName,
                    homeTeam: fetchedMatch!.homeTeam.name,
                    awayTeam: fetchedMatch!.awayTeam.name,
                  ),
                );
              }
              return !isLiked;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(DemoLocalizations.notificationPermissionRequired),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            return isLiked;
          },
        ),
      );
    },
  ),
)
],
              ),
            );
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0, top: 15.h),
                    child: IconButton(
                      onPressed: () => _handleBackPress(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colorscontainer.greenColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 300.h,
                ),
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                    strokeWidth: 2.w,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> openNotificationSettings(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Colorscontainer.greenColor,
                size: 24.w,
              ),
              SizedBox(width: 10.w),
              Text(
                DemoLocalizations.enableNotifications,
                style: TextUtils.setTextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DemoLocalizations.stayUpdatedWith,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              _buildNotificationFeature(
                icon: Icons.sports_soccer,
                text: DemoLocalizations.liveMatchUpdates,
              ),
              _buildNotificationFeature(
                icon: Icons.emoji_events,
                text: DemoLocalizations.goalAlerts,
              ),
              _buildNotificationFeature(
                icon: Icons.access_time,
                text: DemoLocalizations.matchReminders,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                DemoLocalizations.notNow,
                style: TextUtils.setTextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
              child: ElevatedButton(
                onPressed: () {
                  if (status.isPermanentlyDenied) {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.notification);
                  } else {
                    Permission.notification.request();
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colorscontainer.greenColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  status.isPermanentlyDenied
                      ? DemoLocalizations.openSettings
                      : DemoLocalizations.enable,
                  style: TextUtils.setTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNotificationFeature({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colorscontainer.greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Colorscontainer.greenColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextUtils.setTextStyle(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = selectedTabIndex == index;

    bool showTab = true;

    // Hide statistics tab if no stats available
    if (index == 2) {
      final statsState = context.watch<MatchStatisticsBloc>().state;
      if (statsState.status != matchesStatsStatus.requestSuccessed ||
          statsState.teamsMatchStat == null) {
        showTab = false;
      }
    }

    return showTab
        ? GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              updateSelectedIdx(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colorscontainer.greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    )
                  : null,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20.w,
                    color:
                        isSelected ? Colorscontainer.greenColor : Colors.grey,
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 5.w),
                    Text(
                      label,
                      style: TextUtils.setTextStyle(
                        color: Colorscontainer.greenColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  bool _hasHiddenTabs() {
    return selectedTabIndex == 1 ||
        selectedTabIndex == 2 ||
        selectedTabIndex == 3 ||
        (selectedTabIndex == 4 && fetchedMatch?.VideoId == null);
  }

  Widget _buildTeamInfo(BuildContext context, dynamic team,
      {required bool isHome}) {
    return GestureDetector(
      onTap: () {
        TeamName teamName = TeamName(
          id: team.id,
          amharicName: team.name.toString(),
          englishName: team.name.toString(),
          logo: team.logo.toString(),
          oromoName: team.name.toString(),
          somaliName: team.name.toString(),
        );
        context.pushNamed(RouteNames.teamProfilePage, extra: teamName);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
        child: CachedNetworkImage(
  imageUrl: team.logo.toString(),
  width: 45.w,
  height: 45.w,
  fit: BoxFit.contain,
  // This triggers if the primary URL fails
  errorWidget: (context, url, error) => CachedNetworkImage(
    imageUrl: "https://media.api-sports.io/football/teams/${team.id.toString()}.png",
    width: 35.w,
    height: 35.w,
    fit: BoxFit.contain,
    // This triggers if the fallback URL also fails
    errorWidget: (context, fallbackUrl, fallbackError) => Icon(
      Icons.network_locked_outlined,
      size: 20.w,
    ),
  ),
),

          ),
          SizedBox(height: 6.h),
          Flexible(
            child: Text(
              team.name.toString(),
              textAlign: TextAlign.center,
              maxLines: 2,
              
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.abyssinicaSil(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(dynamic match) {
    // Helper function to get correct match status
    String getCorrectMatchStatus() {
      if (match.dateString == null) return '';

      final matchDate = DateTime.parse(match.dateString!);
      final now = DateTime.now().toUtc();
      final isMatchInPast = now.difference(matchDate).inHours >= 3;

      // Handle special statuses
      final unchangeableStatuses = [
        'PST',
        'CANC',
        'ABD',
        'AWD',
        'TBD',
        'WO',
        'SUSP',
        'INT',
        'AET',
        'PEN'
      ];

      if (unchangeableStatuses.contains(match.status)) {
        return match.status ?? '';
      }

      // Force FT status for past matches
      if (isMatchInPast &&
          ['1H', '2H', 'HT', 'LIVE', '', null].contains(match.status)) {
        return 'FT';
      }

      return match.status ?? '';
    }

    final correctStatus = getCorrectMatchStatus();

    // Helper function to get match status text
    String getMatchStatus() {
      switch (correctStatus) {
        case 'FT':
          return DemoLocalizations.matchEnded;
        case 'HT':
          return DemoLocalizations.firstHalf;
        case 'NS':
          final matchDateTime = DateTime.parse(match.dateOnly.toString());
          final now = DateTime.now();

          // If match is today
          if (matchDateTime.year == now.year &&
              matchDateTime.month == now.month &&
              matchDateTime.day == now.day) {
            final matchTime =
                DateTime.parse(match.dateString ?? match.dateOnly.toString());
            final hoursUntilMatch = matchTime.difference(now).inHours;

            // If less than 6 hours until match
            if (hoursUntilMatch < 24 && hoursUntilMatch >= 0) {
              return _formatCountdown(
                matchTime,
              );
            }
            // If more than 6 hours but still today
            else {
              return getAmharicMonthName(match.dateOnly.toString());
            }
          }
          // If not today
          return getAmharicMonthName(match.dateOnly.toString());

        case 'PST':
          return DemoLocalizations.postponed;
        case 'CANC':
          return DemoLocalizations.cancelled;
        case 'ABD':
          return DemoLocalizations.abandoned;
        case 'AWD':
          return DemoLocalizations.technicalLoss;
        case 'WO':
          return DemoLocalizations.walkOver;
        case 'LIVE':
          if (match.time?.elapsed != null) {
            // Show current minute with apostrophe
            return '${match.time.elapsed}\'';
          }
          return 'LIVE';
        case 'TBD':
          return DemoLocalizations.notDecided;
        case '1H':
          return DemoLocalizations.firstHalf;
        case '2H':
          return DemoLocalizations.secondHalf;
        case 'ET':
          return DemoLocalizations.extraTime;
        case 'BT':
          return DemoLocalizations.breakTime;
        case 'P':
          return DemoLocalizations.penaltyInProgress;
        case 'SUSP':
          return DemoLocalizations.suspended;
        case 'INT':
          return DemoLocalizations.matchInterrupted;
        case 'AET':
          return DemoLocalizations.finishedExtraTime;
        case 'PEN':
          return DemoLocalizations.penaltyShootout;
        default:
          if (match.time?.elapsed != null) {
            return '${match.time.elapsed}\'';
          }
          return getAmharicMonthName(match.dateOnly.toString());
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getMatchStatus(),
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(
              color: correctStatus == 'LIVE' ? Colors.red : Colors.white70,
              fontSize: correctStatus == 'LIVE' ? 16.sp : 14.sp,
              fontWeight:
                  correctStatus == 'LIVE' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (correctStatus == 'NS') ...[
                // Existing NS status code remains unchanged
                Column(
                  children: [
                    Text(
                      '-',
                      style: TextUtils.setTextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      extractTimeFromIso(
                              match.dateString ?? match.dateOnly.toString())
                          .toString(),
                      style: TextUtils.setTextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Existing score display code remains unchanged
                Text(
                  '${match.homeTeam.goal ?? "0"}',
                  style: GoogleFonts.russoOne(
                    fontSize: 26.sp,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    ' - ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
                Text(
                  '${match.awayTeam.goal ?? "0"}',
                  style: GoogleFonts.russoOne(
                    fontSize: 26.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
          // Only show match timer for live matches
          if (['1H', '2H'].contains(correctStatus)) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MatchStatusAndTime(
                    matchStatus: correctStatus,
                    startTimeString: correctStatus == '2H'
                        ? match.secondHalfTime
                        : match.kickOfTime ?? match.dateString,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeUnitText(DateTime matchTime) {
    final now = DateTime.now();
    final difference = matchTime.difference(now);

    if (difference.inHours >= 1) {
      return '${DemoLocalizations.hours} ${DemoLocalizations.left}';
    } else if (difference.inMinutes > 0) {
      return '${DemoLocalizations.minutes} ${DemoLocalizations.left}';
    } else {
      return '${DemoLocalizations.seconds} ${DemoLocalizations.left}';
    }
  }

  String _formatCountdown(DateTime matchTime) {
    final now = DateTime.now();
    final difference = matchTime.difference(now);

    // If match has passed more than 3 hours ago → show error or fallback
    if (difference.inHours < -3) {
      return DemoLocalizations.error;
    }

    String timePart;
    String unitPart = _getTimeUnitText(matchTime); // Now we use it!

    if (difference.inHours >= 1) {
      final hours = difference.inHours;
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
      timePart = '$hours:$minutes:$seconds';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes.toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
      timePart = '$minutes:$seconds';
    } else if (difference.inSeconds > 0) {
      timePart = '00:${difference.inSeconds.toString().padLeft(2, '0')}';
    } else {
      return DemoLocalizations.startingSoon;
    }

    // Combine time + unit text on the same line
    return '$timePart $unitPart';
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && fetchedMatch != null) {
        setState(() {
          // This will trigger a rebuild of the widget
        });
      }
    });
  }
}
