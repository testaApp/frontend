import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:shimmer/shimmer.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../application/following/following_bloc.dart';
import '../../../../application/following/following_event.dart';
import '../../../../application/following/following_state.dart';
import '../../../../components/dominant_color_generator.dart';
import '../../../../localization/demo_localization.dart';
import '../../../../main.dart';
import '../../../../models/teamName.dart';
import '../../../../services/analytics_service.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
import '../favourites_page/player/matches_view/matches/matches_view.dart';
import '../favourites_page/teams/teams_page_standing.dart';
import '../favourites_page/teams/team_squad_page.dart';
import '../favourites_page/teams/teams_statistics_page.dart';

class TeamProfilePage extends StatefulWidget {
  final TeamName teamName;
  const TeamProfilePage({super.key, required this.teamName});

  @override
  State<TeamProfilePage> createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Color? bgColor;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isColorLoading = true;

final FollowingAnalyticsService _analyticsService = FollowingAnalyticsService();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

   // Fire BLoC event asynchronously to not block UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowingBloc>().add(LoadFollowedTeams());
      context
          .read<FollowingBloc>()
          .add(CheckFollowingTeam(teamId: widget.teamName.id));
    
    // ✨ ADD THIS - Track team profile view
      _analyticsService.logEvent(
        name: 'team_profile_viewed',
        parameters: {
          'team_id': widget.teamName.id,
          'team_name': widget.teamName.englishName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    });
    // Load color asynchronously with proper error handling
    _setBgColor();
  }

  void _onScroll() {
    final newOffset =
        (_scrollController.offset / 120).clamp(0.0, 1.0).toDouble();
    if ((newOffset - _scrollOffset).abs() > 0.01) {
      setState(() {
        _scrollOffset = newOffset;
      });
    }
  }

  Future<void> _setBgColor() async {
    try {
      final dominant =
          await generateDominantColor(imageUrl: widget.teamName.logo);
      if (mounted) {
        setState(() {
          bgColor = dominant;
          _isColorLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          bgColor = Colorscontainer.greenColor;
          _isColorLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final team = widget.teamName;
    final name = _getLocalizedName(team);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (_, __) => [
          _buildHeader(team, name),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(_buildTabBar()),
            pinned: false,
          ),
        ],
        body: _buildTabViews(team),
      ),
    );
  }

  // ================= HEADER =================

  SliverAppBar _buildHeader(TeamName team, String name) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: false,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _buildBackButton(),
      actions: [_buildFollowButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(
          bgColor: bgColor,
          isColorLoading: _isColorLoading,
          team: team,
          name: name,
        ),
      ),
    );
  }

  // ================= TABS =================

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colorscontainer.greenColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextUtils.setTextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w600),
        indicator: MaterialIndicator(
          color: Colorscontainer.greenColor,
          height: 3.h,
          topLeftRadius: 12,
          topRightRadius: 12,
        ),
        tabs: [
          Tab(text: DemoLocalizations.overall),
          Tab(text: DemoLocalizations.statistics),
          Tab(text: DemoLocalizations.squad),
          Tab(text: DemoLocalizations.games),
        ],
      ),
    );
  }

  Widget _buildTabViews(TeamName team) {
    return ExtendedTabBarView(
      controller: _tabController,
      cacheExtent: 1, // Only cache adjacent tabs, not all 4
      children: [
        TeamsStandingPage(
          venuename: team.venuename,
          venueimage: team.venueimage,
          venueaddress: team.venueaddress,
          venuecapacity: team.venuecapacity,
          venuecity: team.venuecity,
          founded: team.founded,
          venuesurface: team.venuesurface,
          teamId: team.id.toString(),
        ),
        TeamStatisticsPage(
          teamId: team.id,
        ),
        TeamSquadPage(teamName: team),
        MatchesView(
          teamId: team.id.toString(),
          playerStatistics: const [],
        ),
      ],
    );
  }

  // ================= CONTROLS =================

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    );
  }

 Widget _buildFollowButton() {
  return BlocBuilder<FollowingBloc, FollowingState>(
    builder: (_, state) {
      final isFollowing =
          state.followedTeams.contains(widget.teamName.id);

      return Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: LikeButton(
          size: 50, // slightly larger tap target
          isLiked: isFollowing,
          circleColor: CircleColor(
            start: Colors.white,
            end: Colorscontainer.greenColor,
          ),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colorscontainer.greenColor,
            dotSecondaryColor: Colors.white,
          ),
          likeBuilder: (liked) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.25),
                border: Border.all(
                  color: liked
                      ? Colors.white // ✅ white stroke when followed
                      : Colors.white.withOpacity(0.25),
                  width: liked ? 2 : 1.2,
                ),
                boxShadow: [
                  if (liked)
                    BoxShadow(
                      color: Colorscontainer.greenColor.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                size: 30.sp,
                color: liked
                    ? Colorscontainer.greenColor
                    : Colors.white.withOpacity(0.9),
              ),
            );
          },
          onTap: (liked) async {
            final teamName = _getEnglishName(widget.teamName);

            if (liked) {
              context.read<FollowingBloc>().add(
                RemoveFollowingTeam(
                  teamId: widget.teamName.id,
                  teamName: teamName,
                ),
              );
            } else {
              HapticFeedback.lightImpact();
              context.read<FollowingBloc>().add(
                FollowTeamRequested(
                  teamId: widget.teamName.id,
                  teamName: teamName,
                ),
              );
            }
            return !liked;
          },
        ),
      );
    },
  );
}
 // ================= HELPERS =================

  String _getLocalizedName(TeamName team) {
    switch (localLanguageNotifier.value) {
      case 'am':
      case 'tr':
        return team.amharicName;
      case 'or':
        return team.oromoName;
      case 'so':
        return team.somaliName;
      default:
        return team.englishName;
    }
  }

  String _getEnglishName(TeamName team) {
    return team.englishName;
  }
}

// Separate widget to prevent rebuilding expensive blur on scroll
class _HeaderBackground extends StatelessWidget {
  final Color? bgColor;
  final bool isColorLoading;
  final TeamName team;
  final String name;

  const _HeaderBackground({
    required this.bgColor,
    required this.isColorLoading,
    required this.team,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (bgColor ?? Colorscontainer.greenColor).withOpacity(0.95),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),

        // Reduced blur for better performance
        if (!isColorLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduced from 12
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),

        // Content
        Positioned(
          bottom: 28.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TeamLogo(team: team),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtils.setTextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    if (team.founded != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        '${team.founded} - ${DemoLocalizations.found} ',
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Separate stateless widget for logo to prevent unnecessary rebuilds
class _TeamLogo extends StatelessWidget {
  final TeamName team;

  const _TeamLogo({required this.team});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'team_logo_${team.id}',
      child: CachedNetworkImage(
        imageUrl: team.logo,
        height: 100.h, // Adjusted for the header
        width: 100.h,
        fit: BoxFit.contain,
        placeholder: (_, __) => _buildShimmerLogo(),
        // FIRST ERROR: Try API-Sports direct CDN
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: 'https://media.api-sports.io/football/teams/${team.id}.png',
          height: 100.h,
          width: 100.h,
          fit: BoxFit.contain,
          placeholder: (_, __) => _buildShimmerLogo(),
          // SECOND ERROR: The final Shield Icon
          errorWidget: (_, __, ___) => Container(
            height: 100.h,
            width: 100.h,
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield,
              size: 50.sp,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLogo() {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Container(
        height: 100.h,
        width: 100.h,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabBarDelegate(this.child);

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(_, __, ___) => child;

  @override
  bool shouldRebuild(_) => false;
}
