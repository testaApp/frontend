import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../../application/following/following_bloc.dart';
import '../../../../../application/following/following_event.dart';
import '../../../../../application/following/following_state.dart';
import '../../../../../bloc/mirchaweche/players/player_profile/player_profile_bloc.dart';
import '../../../../../bloc/mirchaweche/players/player_profile/player_profile_event.dart';
import '../../../../../bloc/mirchaweche/players/player_profile/player_profile_state.dart';
import '../../../../../bloc/news/news_bloc.dart';
import '../../../../../bloc/news/news_event.dart';
import '../../../../../bloc/news/news_state.dart';
import '../../../../../components/dominant_color_generator.dart';
import '../../../../../domain/player/playerModel.dart';
import '../../../../../domain/player/playerName.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../main.dart';
import '../../../../../services/analytics_service.dart';
import '../../../../appbar_pages/news/main_news/widgets/player_news.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';
import 'details/playerDetails.dart';
import 'matches_view/matches/matches_view.dart';
import 'statistics/player_statistics.dart';

// NEW: import player news page

class PlayerProfilePage extends StatefulWidget {
  final PlayerProfile? profile;
  final PlayerName? playerName;
  final String? teamPic;

  const PlayerProfilePage(
      {Key? key, this.profile, this.playerName, this.teamPic})
      : super(key: key);

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  Color? dominantColor;
  final FollowingAnalyticsService _analyticsService = FollowingAnalyticsService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // ✅ 4 tabs
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  String _sanitizeMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.replaceAll(
        RegExp(r'media-\d+\.api-sports\.io'), 'media.api-sports.io');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int? playerId = _currentPlayerId;
    final blocPlayerId = context.read<PlayerProfileBloc>().state.player?.id;

    if (playerId != null && blocPlayerId != playerId) {
      context
          .read<PlayerProfileBloc>()
          .add(PlayerProfileRequested(playerId: playerId));
      final String? teamId =
          GoRouterState.of(context).uri.queryParameters['teamId'] ??
              widget.profile?.idteam?.toString();
      if (teamId != null) {
        context
            .read<PlayerProfileBloc>()
            .add(PlayerProfilefor3(teamId: teamId));
      }
      context
          .read<FollowingBloc>()
          .add(CheckFollowingPlayer(playerId: playerId));
    }
  }

  void _initializeData() {
    final int? playerId = _currentPlayerId;
    if (playerId == null) return;

    context
        .read<PlayerProfileBloc>()
        .add(PlayerProfileRequested(playerId: playerId));

    final String? teamId =
        GoRouterState.of(context).uri.queryParameters['teamId'] ??
            widget.profile?.idteam?.toString();
    if (teamId != null) {
      context.read<PlayerProfileBloc>().add(PlayerProfilefor3(teamId: teamId));
    }

    context.read<FollowingBloc>().add(CheckFollowingPlayer(playerId: playerId));

    // ✅ load player news by English name
    final playerName =
        _getEnglishPlayerName(context.read<PlayerProfileBloc>().state.player);
    if (playerName.isNotEmpty) {
      context.read<NewsBloc>().add(
            PlayerNewsRequested(
              playerName: playerName,
              language: localLanguageNotifier.value,
            ),
          );
    }

    _analyticsService.logEvent(
      name: 'player_profile_viewed',
      parameters: {
        'player_id': playerId,
        'player_name': widget.playerName?.englishName ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    _generateDominantColor();
  }

  Future<void> _generateDominantColor() async {
    String url = _getPlayerImageUrl(null);
    if (url.isNotEmpty) {
      Color dominant = await generateDominantColor(imageUrl: url);
      if (mounted) setState(() => dominantColor = dominant);
    }
  }

  int? get _currentPlayerId {
    final String? paramId = GoRouterState.of(context).uri.queryParameters['id'];
    if (paramId != null && paramId.isNotEmpty) {
      return int.tryParse(paramId);
    }
    if (widget.playerName?.id != null) return widget.playerName!.id;
    if (widget.profile?.id != null) return widget.profile!.id;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
      builder: (context, state) {
        final int? targetId = _currentPlayerId;
        bool isDataCorrect =
            state.player != null && state.player!.id == targetId;
        final activeProfile = isDataCorrect ? state.player : widget.profile;
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            Navigator.of(context).pop(true);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildSliverAppBar(context, activeProfile),
                _buildTabBar(context),
              ],
              body: !isDataCorrect &&
                      widget.profile == null &&
                      widget.playerName == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTabBarView(activeProfile),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, PlayerProfile? activeProfile) {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: dominantColor ?? Colorscontainer.greenColor,
      leading: _buildBackButton(context),
      actions: [_buildFollowButton(), SizedBox(width: 10.w)],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildModernHeader(activeProfile),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget _buildModernHeader(PlayerProfile? activeProfile) {
    final String teamPhotoUrl = _getTeamImageUrl(activeProfile);
    final String playerPhotoUrl = _getPlayerImageUrl(activeProfile);

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: teamPhotoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Container(color: Colors.black45),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8)
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 6,
            ),
            child: Container(color: Colors.black.withOpacity(0.0)),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 25.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: playerPhotoUrl,
                    width: 100.r,
                    height: 100.r,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl:
                          'https://media.api-sports.io/football/players/${_currentPlayerId}.png',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getPlayerName(activeProfile),
                      style: TextUtils.setTextStyle(
                        fontSize: 22.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ).copyWith(
                        shadows: [
                          const Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: CachedNetworkImage(
                            imageUrl: teamPhotoUrl,
                            width: 28.r,
                            height: 28.r,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              width: 28.r,
                              height: 28.r,
                              color: Colors.white24,
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(Icons.sports_soccer,
                                  size: 16.r, color: Colors.white70),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${_getClubName(activeProfile)} ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    final String? isFavParam =
        GoRouterState.of(context).uri.queryParameters['favourite'];
    final bool cameFromFavourites = isFavParam == 'true';

    return BlocBuilder<FollowingBloc, FollowingState>(
      builder: (context, state) {
        final int? pid = _currentPlayerId;
        bool isFollowing;

        if (state.status == Status.following ||
            state.status == Status.followRequested) {
          isFollowing = true;
        } else if (state.status == Status.notFollowing) {
          isFollowing = false;
        } else {
          isFollowing = cameFromFavourites;
        }

        return LikeButton(
          size: 46,
          isLiked: isFollowing,
          circleColor: CircleColor(
            start: Colors.white,
            end: Colorscontainer.greenColor,
          ),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.white,
            dotSecondaryColor: Colorscontainer.greenColor,
          ),
          onTap: (isLiked) async {
            if (pid == null) return isLiked;

            var permStatus = await perm_handler.Permission.notification.status;
            if (!permStatus.isGranted) {
              await _analyticsService.logNotificationPermissionRequested(
                  'player_follow');

              await perm_handler.Permission.notification.request();
              permStatus = await perm_handler.Permission.notification.status;

              if (permStatus.isGranted) {
                await _analyticsService
                    .logNotificationPermissionGranted('player_follow');
              } else {
                await _analyticsService
                    .logNotificationPermissionDenied('player_follow');
              }
            }

            if (permStatus.isGranted) {
              final playerName = _getEnglishPlayerName(
                context.read<PlayerProfileBloc>().state.player,
              );

              if (!isLiked) {
                HapticFeedback.mediumImpact();
              }

              context.read<FollowingBloc>().add(
                    isLiked
                        ? RemoveFollowingPlayer(
                            playerId: pid,
                            playerName: playerName,
                          )
                        : FollowPlayerRequested(
                            playerId: pid,
                            playerName: playerName,
                          ),
                  );

              return !isLiked;
            }
            return isLiked;
          },
          likeBuilder: (isLiked) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.25),
                border: Border.all(
                  color: isLiked
                      ? Colors.white
                      : Colors.white.withOpacity(0.25),
                  width: isLiked ? 2 : 1.2,
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
                CupertinoIcons.heart_solid,
                color: isLiked
                    ? Colorscontainer.greenColor
                    : Colors.white.withOpacity(0.9),
                size: 24,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabBarView(PlayerProfile? activeProfile) {
    return TabBarView(
      controller: _tabController,
      children: [
        activeProfile != null
            ? PlayerDetails(playerProfile: activeProfile, color: dominantColor)
            : const Center(child: CircularProgressIndicator()),
        activeProfile != null
            ? PlayerProfileStatistics(
                playerStatistics: activeProfile.statistics,
                color: dominantColor)
            : const Center(child: CircularProgressIndicator()),
        MatchesView(
          teamId: activeProfile?.idteam.toString() ?? '',
          playerStatistics: activeProfile?.statistics ?? [],
        ),
        // ✅ News tab
        PlayerNewsPage(
          playerName: _getEnglishPlayerName(activeProfile),
        ),
      ],
    );
  }

  String _getPlayerName(PlayerProfile? active) {
    final p =
        active?.playerName ?? widget.playerName ?? widget.profile?.playerName;
    final lang = localLanguageNotifier.value;
    if (lang == 'am') return p?.amharicName ?? '';
    if (lang == 'si') return p?.somaliName ?? '';
    if (lang == 'or') return p?.oromoName ?? '';
    return p?.englishName ?? '';
  }

  String _getEnglishPlayerName(PlayerProfile? active) {
    final p =
        active?.playerName ?? widget.playerName ?? widget.profile?.playerName;
    return p?.englishName ?? '';
  }

  String _getClubName(PlayerProfile? active) {
    final passed = GoRouterState.of(context).uri.queryParameters['teamName'];
    if (passed != null) return passed;
    final stats = active?.statistics ?? widget.profile?.statistics;
    if (stats == null || stats.isEmpty) return '';
    final lang = localLanguageNotifier.value;
    if (lang == 'am') return stats[0].amharicTeamName ?? '';
    if (lang == 'si') return stats[0].somaliTeamName ?? '';
    return stats[0].englishTeamName ?? '';
  }

  String _getPlayerImageUrl(PlayerProfile? active) {
    String? url;

    if (active?.photo != null && active!.photo!.isNotEmpty) {
      url = _sanitizeMediaUrl(active.photo);
    } else if (widget.playerName?.photo != null &&
        widget.playerName!.photo!.isNotEmpty) {
      url = _sanitizeMediaUrl(widget.playerName!.photo);
    }

    if (url != null && url.isNotEmpty) {
      if (!url.endsWith('.png')) {
        url = '$url.png';
      }
      return url;
    }

    final int? pid = _currentPlayerId;
    return pid != null
        ? 'https://media.api-sports.io/football/players/$pid.png'
        : 'https://media.api-sports.io/football/players/0.png';
  }

  String _getTeamImageUrl(PlayerProfile? active) {
    if (widget.teamPic != null && widget.teamPic!.isNotEmpty) {
      return widget.teamPic!;
    }

    if (active?.currentTeamLogo != null &&
        active!.currentTeamLogo!.isNotEmpty) {
      return _sanitizeMediaUrl(active.currentTeamLogo)!;
    }

    final dynamic rawTeamId = active?.idteam ?? widget.profile?.idteam;

    int? tid;
    if (rawTeamId is int) {
      tid = rawTeamId;
    } else if (rawTeamId is String && rawTeamId.isNotEmpty) {
      tid = int.tryParse(rawTeamId);
    }

    if (tid != null) {
      return 'https://media.api-sports.io/football/teams/$tid.png';
    }

    return '';
  }

  SliverPersistentHeader _buildTabBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Colorscontainer.greenColor,
          unselectedLabelColor:
              Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
          indicator: MaterialIndicator(
              color: Colorscontainer.greenColor,
              height: 2.h,
              topLeftRadius: 8,
              topRightRadius: 8),
          tabs: [
            Tab(text: DemoLocalizations.detail),
            Tab(text: DemoLocalizations.statistics),
            Tab(text: DemoLocalizations.games),
            Tab(text: DemoLocalizations.news),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
