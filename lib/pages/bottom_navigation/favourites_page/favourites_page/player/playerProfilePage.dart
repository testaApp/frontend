import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../constants/constants.dart' as Curporito;
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
      expandedHeight: 150.h,
      pinned: true,
      elevation: 0,
      stretch: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
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
    final Color base = dominantColor ?? Colorscontainer.greenColor;
    final Color accent =
        _tone(base, hueShift: 24, satShift: 0.18, lightShift: 0.08);
    final Color accentAlt =
        _tone(base, hueShift: 200, satShift: -0.05, lightShift: -0.18);
    final Color deep = _tone(base, satShift: 0.05, lightShift: -0.42);
    final Color headerTop = Color.lerp(accent, Colors.white, 0.12) ?? accent;
    final Color headerMid = Color.lerp(base, accentAlt, 0.28) ?? base;
    final Color headerBottom = Color.lerp(deep, Colors.black, 0.12) ?? deep;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [headerTop, headerMid, headerBottom],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -60.w,
            top: -50.h,
            child: _buildGlowOrb(accent.withOpacity(0.65), 170.r),
          ),
          Positioned(
            left: -80.w,
            bottom: -80.h,
            child: _buildGlowOrb(accentAlt.withOpacity(0.55), 210.r),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.65,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, -0.8),
                    radius: 1.2,
                    colors: [
                      accent.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, 0.6),
                    radius: 1.1,
                    colors: [
                      accentAlt.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (teamPhotoUrl.isNotEmpty)
            Opacity(
              opacity: 0.08,
              child: CachedNetworkImage(
                imageUrl: teamPhotoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.black12),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.black12),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: 22.h,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: Container(color: Colors.black.withOpacity(0.0)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildAvatar(playerPhotoUrl, accent, _currentPlayerId),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.22),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getPlayerName(activeProfile),
                                    style: TextUtils.setTextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6.r),
                                              child: CachedNetworkImage(
                                                imageUrl: teamPhotoUrl,
                                                width: 26.r,
                                                height: 26.r,
                                                fit: BoxFit.contain,
                                                placeholder: (context, url) => Container(
                                                  width: 26.r,
                                                  height: 26.r,
                                                  color: Colors.white24,
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  width: 26.r,
                                                  height: 26.r,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(6.r),
                                                  ),
                                                  child: Icon(
                                                    Icons.sports_soccer,
                                                    size: 16.r,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  _getClubName(activeProfile),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13.sp,
                                                    height: 1.2,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildHoloDivider(accent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    final String? isFavParam =
        GoRouterState.of(context).uri.queryParameters['favourite'];
    final bool cameFromFavourites = isFavParam == 'true';
    final Color accent = dominantColor ?? Colorscontainer.greenColor;

    return BlocBuilder<FollowingBloc, FollowingState>(
      builder: (context, state) {
        final int? pid = _currentPlayerId;
        bool isFollowing;
        final bool isBusy = state.status == Status.followRequested;

        if (state.status == Status.following ||
            state.status == Status.followRequested) {
          isFollowing = true;
        } else if (state.status == Status.notFollowing) {
          isFollowing = false;
        } else {
          isFollowing = cameFromFavourites;
        }

        final String label = isFollowing ? 'Following' : 'Follow';
        final IconData icon =
            isFollowing ? Icons.favorite : Icons.favorite_border;
        final Color contentColor = isFollowing
          ? Colorscontainer.greenColor
          : _contrastColor(accent);
        final Color Colors_ = Colors.white.withOpacity(0.14);
        final Color borderColor = isFollowing
            ? Colors.white.withOpacity(0.7)
            : Colors.white.withOpacity(0.35);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isBusy ? 0.65 : 1,
          child: IgnorePointer(
            ignoring: isBusy,
            child: Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: (pid == null)
                      ? null
                      : () => _handleFollowTap(isFollowing),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isFollowing
                          ? Colorscontainer.greenColor.withOpacity(0.12)
                          : Colors_.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: isBusy
                              ? SizedBox(
                                  key: const ValueKey('loading'),
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(contentColor),
                                  ),
                                )
                              : Icon(
                                  icon,
                                  key: ValueKey(icon),
                                  size: 16,
                                  color: contentColor,
                                ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: Text(
                            label,
                            key: ValueKey(label),
                            style: TextStyle(
                              color: contentColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFollowTap(bool isFollowing) async {
    final int? pid = _currentPlayerId;
    if (pid == null) return;

    var permStatus = await perm_handler.Permission.notification.status;
    if (!permStatus.isGranted) {
      await _analyticsService.logNotificationPermissionRequested(
        'player_follow',
      );

      await perm_handler.Permission.notification.request();
      permStatus = await perm_handler.Permission.notification.status;

      if (permStatus.isGranted) {
        await _analyticsService.logNotificationPermissionGranted(
          'player_follow',
        );
      } else {
        await _analyticsService.logNotificationPermissionDenied(
          'player_follow',
        );
      }
    }

    if (permStatus.isGranted) {
      final playerName = _getEnglishPlayerName(
        context.read<PlayerProfileBloc>().state.player,
      );

      if (!isFollowing) {
        HapticFeedback.mediumImpact();
      }

      context.read<FollowingBloc>().add(
            isFollowing
                ? RemoveFollowingPlayer(
                    playerId: pid,
                    playerName: playerName,
                  )
                : FollowPlayerRequested(
                    playerId: pid,
                    playerName: playerName,
                  ),
          );
    }
  }

  Widget _buildTabBarView(PlayerProfile? activeProfile) {
    return TabBarView(
      controller: _tabController,
      children: [
        activeProfile != null
          ? PlayerDetails(
            playerProfile: activeProfile,
            color: _contrastColor(dominantColor ?? Colorscontainer.greenColor),
            )
            : const Center(child: CircularProgressIndicator()),
        activeProfile != null
          ? PlayerProfileStatistics(
            playerStatistics: activeProfile.statistics,
            color: _contrastColor(dominantColor ?? Colorscontainer.greenColor),
            )
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

  double _clamp01(num value) => value.clamp(0.0, 1.0).toDouble();

  Color _tone(
    Color base, {
    double hueShift = 0,
    double satShift = 0,
    double lightShift = 0,
  }) {
    final hsl = HSLColor.fromColor(base);
    return HSLColor.fromAHSL(
      1,
      (hsl.hue + hueShift) % 360,
      _clamp01(hsl.saturation + satShift),
      _clamp01(hsl.lightness + lightShift),
    ).toColor();
  }

  Color _contrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
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
    final Color accent = dominantColor ?? Colorscontainer.greenColor;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: Colorscontainer.greenColor,
          unselectedLabelColor:
              Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.55),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
            letterSpacing: 0.2,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: MaterialIndicator(
            color: Colorscontainer.greenColor,
            height: 2.h,
            topLeftRadius: 8,
            topRightRadius: 8,
          ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
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
          Colors.transparent,
        ],
      ),
    ),
  );
}

Widget _buildAvatar(String imageUrl, Color accent, int? playerId) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        colors: [
          accent.withOpacity(0.2),
          Colors.white.withOpacity(0.8),
          accent.withOpacity(0.8),
          accent.withOpacity(0.2),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.35),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
        color: Colors.black.withOpacity(0.2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black12),
          errorWidget: (context, url, error) => CachedNetworkImage(
            imageUrl:
                'https://media.api-sports.io/football/players/${playerId ?? 0}.png',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(
              Icons.person,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildHoloDivider(Color accent) {
  return Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.25),
          accent.withOpacity(0.7),
          Colors.white.withOpacity(0.25),
          Colors.transparent,
        ],
      ),
    ),
  );
}
