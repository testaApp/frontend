import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_event.dart';
import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_state.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../main.dart';
import '../../../../../models/teamName.dart';
import '../../../../constants/colors.dart';

class TeamSquadPage extends StatefulWidget {
  final TeamName teamName;
  const TeamSquadPage({super.key, required this.teamName});

  @override
  State<TeamSquadPage> createState() => _TeamSquadPageState();
}

class _TeamSquadPageState extends State<TeamSquadPage>
    with AutomaticKeepAliveClientMixin {
  String deviceLanguage = 'en';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fire event asynchronously to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeammatesBloc>().add(SquadRequseted(team: widget.teamName));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceLanguage = Localizations.localeOf(context).languageCode;
  }

  String getLocalizedPlayerName(dynamic player) {
    switch (localLanguageNotifier.value) {
      case 'am':
      case 'tr':
        return player.amharicName?.isNotEmpty == true
            ? player.amharicName
            : player.englishName;
      case 'so':
        return player.somaliName?.isNotEmpty == true
            ? player.somaliName
            : player.englishName;
      case 'or':
        return player.oromoName?.isNotEmpty == true
            ? player.oromoName
            : player.englishName;
      default:
        return player.englishName ?? '';
    }
  }

  String getPositionLabel(String position) {
    final pos = position.toLowerCase();
    if (pos.contains('goalkeeper') || pos.contains('gk')) {
      return DemoLocalizations.goalkeeper;
    } else if (pos.contains('defender') || pos.contains('defence')) {
      return DemoLocalizations.defender;
    } else if (pos.contains('midfielder') || pos.contains('midfield')) {
      return DemoLocalizations.midfielder;
    } else if (pos.contains('forward') ||
        pos.contains('attacker') ||
        pos.contains('striker')) {
      return DemoLocalizations.attacker;
    }
    return position;
  }

  List<dynamic> sortPlayersByRating(List<dynamic> players) {
    final sorted = List<dynamic>.from(players);
    sorted.sort((a, b) {
      final numberA = a.number ?? 999;
      final numberB = b.number ?? 999;
      return numberA.compareTo(numberB);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF1C1C1E) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<TeammatesBloc, TeammatesState>(
        builder: (context, state) {
          // Show loading for requested OR if squad hasn't been loaded yet
          if (state.status == TeammatesStatus.requested ||
              (state.status != TeammatesStatus.notFound &&
                  state.squad == null)) {
            return _buildShimmerLoading(isDark);
          } else if (state.status == TeammatesStatus.requestSuccess) {
            final squad = state.squad;
            if (squad == null) {
              return _buildNotFoundWidget(isDark);
            }
            return _buildSquadList(squad, isDark);
          } else if (state.status == TeammatesStatus.notFound) {
            return _buildNotFoundWidget(isDark);
          }
          return _buildErrorWidget(isDark);
        },
      ),
    );
  }

  Widget _buildNotFoundWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colorscontainer.greenColor.withOpacity(0.2),
                          Colorscontainer.greenColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colorscontainer.greenColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      size: 56.sp,
                      color: Colorscontainer.greenColor.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32.h),
            Text(
              DemoLocalizations.teamSquadNotFound ?? 'Squad Not Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              DemoLocalizations.teamSquadNotFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            OutlinedButton.icon(
              onPressed: () {
                context.read<TeammatesBloc>().add(
                      SquadRequseted(team: widget.teamName),
                    );
              },
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                DemoLocalizations.tryAgain,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colorscontainer.greenColor,
                side: BorderSide(
                  color: Colorscontainer.greenColor.withOpacity(0.5),
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64.sp,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            SizedBox(height: 16.h),
            Text(
              DemoLocalizations.networkProblem ?? 'Network Problem',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              DemoLocalizations.networkproblem,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TeammatesBloc>().add(
                      SquadRequseted(team: widget.teamName),
                    );
              },
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                'Retry',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorscontainer.greenColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquadList(dynamic squad, bool isDark) {
    final hasCoach = squad.coach != null && squad.coach.isNotEmpty;

    // Pre-sort all lists once to avoid repeated sorting
    final goalKeepers =
        squad.goalKeepers != null && squad.goalKeepers.isNotEmpty
            ? sortPlayersByRating(squad.goalKeepers)
            : null;
    final defenders = squad.defenders != null && squad.defenders.isNotEmpty
        ? sortPlayersByRating(squad.defenders)
        : null;
    final midfielders =
        squad.midfielders != null && squad.midfielders.isNotEmpty
            ? sortPlayersByRating(squad.midfielders)
            : null;
    final attackers = squad.attackers != null && squad.attackers.isNotEmpty
        ? sortPlayersByRating(squad.attackers)
        : null;

    return CustomScrollView(
      slivers: [
        if (hasCoach)
          SliverToBoxAdapter(
              child: _CoachSection(squad: squad, isDark: isDark)),
        if (goalKeepers != null)
          _PositionSection(
            title: getPositionLabel('Goalkeeper'),
            players: goalKeepers,
            isDark: isDark,
            getLocalizedPlayerName: getLocalizedPlayerName,
          ),
        if (defenders != null)
          _PositionSection(
            title: getPositionLabel('Defender'),
            players: defenders,
            isDark: isDark,
            getLocalizedPlayerName: getLocalizedPlayerName,
          ),
        if (midfielders != null)
          _PositionSection(
            title: getPositionLabel('Midfielder'),
            players: midfielders,
            isDark: isDark,
            getLocalizedPlayerName: getLocalizedPlayerName,
          ),
        if (attackers != null)
          _PositionSection(
            title: getPositionLabel('Attacker'),
            players: attackers,
            isDark: isDark,
            getLocalizedPlayerName: getLocalizedPlayerName,
          ),
        SliverPadding(padding: EdgeInsets.only(bottom: 30.h)),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? const Color(0xFF2C2C2E)
          : const Color.fromARGB(255, 189, 189, 203),
      highlightColor: isDark
          ? const Color(0xFF3C3C3E)
          : const Color.fromARGB(255, 220, 220, 225),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 12.h),
                ...List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                width: 60.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Separate stateless widget to prevent unnecessary rebuilds
class _CoachSection extends StatelessWidget {
  final dynamic squad;
  final bool isDark;

  const _CoachSection({required this.squad, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          _PlayerAvatar(
            url: squad.coachimage,
            size: 40.w,
            isCoach: true,
            isDark: isDark,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DemoLocalizations.coach ?? 'Coach',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  squad.coach ?? 'Unknown',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (squad.coachStartdate != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Since',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  squad.coachStartdate.substring(0, 4),
                  style: TextStyle(
                    color: Colorscontainer.greenColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Separate stateless widget for position sections
class _PositionSection extends StatelessWidget {
  final String title;
  final List<dynamic> players;
  final bool isDark;
  final String Function(dynamic) getLocalizedPlayerName;

  const _PositionSection({
    required this.title,
    required this.players,
    required this.isDark,
    required this.getLocalizedPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colorscontainer.greenColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      DemoLocalizations.jerseyNumber ?? '#',
                      style: TextStyle(
                        color: Colorscontainer.greenColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
              itemCount: players.length,
              separatorBuilder: (context, index) => Divider(
                color: dividerColor,
                height: 16.h,
              ),
              itemBuilder: (context, index) {
                return _PlayerItem(
                  player: players[index],
                  isDark: isDark,
                  getLocalizedPlayerName: getLocalizedPlayerName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Separate stateless widget for player items
class _PlayerItem extends StatelessWidget {
  final dynamic player;
  final bool isDark;
  final String Function(dynamic) getLocalizedPlayerName;

  const _PlayerItem({
    required this.player,
    required this.isDark,
    required this.getLocalizedPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return InkWell(
      onTap: () {
        // Navigate to player details if needed
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            _PlayerAvatar(
              url: player.photo,
              size: 38.w,
              isDark: isDark,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getLocalizedPlayerName(player),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (player.age != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '${player.age} ${DemoLocalizations.year ?? 'yrs'}',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (player.number != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colorscontainer.greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${player.number}',
                  style: TextStyle(
                    color: Colorscontainer.greenColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Text(
                '-',
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Optimized avatar widget with proper caching
class _PlayerAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final bool isDark;
  final bool isCoach;

  const _PlayerAvatar({
    required this.url,
    required this.size,
    required this.isDark,
    this.isCoach = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF3C3C3E) : Colors.grey[200]!;
    final borderColor = isCoach
        ? Colorscontainer.greenColor.withOpacity(0.3)
        : (isDark ? Colors.white12 : Colors.black12);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: bgColor,
      ),
      child: ClipOval(
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                memCacheHeight: (size * 2).toInt(),
                memCacheWidth: (size * 2).toInt(),
                maxHeightDiskCache: (size * 3).toInt(),
                maxWidthDiskCache: (size * 3).toInt(),
                errorWidget: (c, e, s) => Icon(
                  Icons.person,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: size * 0.5,
                ),
                placeholder: (c, u) => Container(color: bgColor),
              )
            : Icon(
                Icons.person,
                color: isDark ? Colors.white38 : Colors.black38,
                size: size * 0.5,
              ),
      ),
    );
  }
}
