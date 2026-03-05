import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl_fmt;

import 'package:blogapp/state/bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/players/player_teammates/teammates_event.dart';
import 'package:blogapp/state/bloc/mirchaweche/players/player_teammates/teammates_state.dart';
import 'package:blogapp/domain/player/playerModel.dart';
import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/favourites_page/squadModel.dart';
import 'player_position_translation.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'squad_list.dart';

/// ================== FUTURISTIC CARD DECORATION ==================
BoxDecoration modernCard(
  BuildContext context, {
  bool glow = false,
  bool subtle = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseOpacity = subtle ? (isDark ? 0.88 : 0.98) : (isDark ? 0.94 : 1.0);

  return BoxDecoration(
    borderRadius: BorderRadius.circular(22.r),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.surface.withOpacity(baseOpacity),
        scheme.surfaceVariant.withOpacity(isDark ? 0.75 : 0.9),
      ],
    ),
    border: Border.all(
      color: scheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.22),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
        blurRadius: 26,
        offset: const Offset(0, 12),
      ),
      if (glow)
        BoxShadow(
          color: scheme.primary.withOpacity(isDark ? 0.4 : 0.24),
          blurRadius: 40,
          spreadRadius: -10,
        ),
    ],
  );
}

/// ================== PLAYER DETAILS ==================
class PlayerDetails extends StatelessWidget {
  final PlayerProfile playerProfile;
  final Color? color;

  const PlayerDetails({
    super.key,
    required this.playerProfile,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (playerProfile.statistics.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            DemoLocalizations.playerInformationNotAvailable,
            style: TextUtils.setTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final stats = playerProfile.statistics.first;
    final deviceLanguage = localLanguageNotifier.value;
    final scheme = Theme.of(context).colorScheme;

    // ===================== FULL NAME (First + Last Name) =====================
    String getFullName() {
      final name = playerProfile.playerName;
      String? first, last;

      switch (deviceLanguage) {
        case 'am':
        case 'tr':
          first = name?.amharicFirstName;
          last = name?.amharicLastName;
          break;
        case 'or':
          first = name?.afanOromoFirstName;
          last = name?.afanOromoLastName;
          break;
        case 'so':
          first = name?.somaliFirstName;
          last = name?.somaliLastName;
          break;
        default:
          first = name?.englishFirstName;
          last = name?.englishLastName;
      }

      final parts = [
        if (first?.isNotEmpty == true) first,
        if (last?.isNotEmpty == true) last,
      ].join(' ');

      return parts.isNotEmpty ? parts : (name?.englishName ?? 'Unknown Player');
    }

    // ===================== OTHER HELPERS =====================
    String getCountryName() => switch (deviceLanguage) {
          'am' || 'tr' => playerProfile.amharicCountryName ??
              playerProfile.englishCountryName ??
              '',
          'or' => playerProfile.oromoCountryName ??
              playerProfile.englishCountryName ??
              '',
          'so' => playerProfile.somaliCountryName ??
              playerProfile.englishCountryName ??
              '',
          _ => playerProfile.englishCountryName ?? '',
        };

    String getTeamName() => switch (deviceLanguage) {
          'am' || 'tr' => stats.amharicTeamName?.isNotEmpty == true
              ? stats.amharicTeamName!
              : stats.englishTeamName ?? '',
          'or' => stats.oromoTeamName?.isNotEmpty == true
              ? stats.oromoTeamName!
              : stats.englishTeamName ?? '',
          'so' => stats.somaliTeamName?.isNotEmpty == true
              ? stats.somaliTeamName!
              : stats.englishTeamName ?? '',
          _ => stats.englishTeamName ?? '',
        };

    String getFormattedBirthDate() {
      if (playerProfile.birthDate == null) return 'N/A';
      try {
        return intl_fmt.DateFormat('dd MMM yyyy')
            .format(DateTime.parse(playerProfile.birthDate!));
      } catch (_) {
        return 'N/A';
      }
    }

    int getAge() {
      if (playerProfile.birthDate == null) return 0;
      try {
        final birth = DateTime.parse(playerProfile.birthDate!);
        final now = DateTime.now();
        int age = now.year - birth.year;
        if (now.month < birth.month ||
            (now.month == birth.month && now.day < birth.day)) age--;
        return age;
      } catch (_) {
        return 0;
      }
    }

    Color getRatingColor(String? rating) {
      final r = double.tryParse(rating ?? '') ?? 0;
      if (r >= 8) return Colors.green;
      if (r >= 7) return Colors.lightGreen;
      if (r >= 6) return Colors.amber;
      return Colors.red;
    }

    String leagueName = switch (deviceLanguage) {
      'am' || 'tr' => stats.amharicLeagueName?.isNotEmpty == true
          ? stats.amharicLeagueName!
          : stats.englishLeagueName ?? 'League',
      'or' => stats.oromoLeagueName?.isNotEmpty == true
          ? stats.oromoLeagueName!
          : stats.englishLeagueName ?? 'League',
      'so' => stats.somaliLeagueName?.isNotEmpty == true
          ? stats.somaliLeagueName!
          : stats.englishLeagueName ?? 'League',
      _ => stats.englishLeagueName ?? 'League',
    };

    final teamName = getTeamName();
    final ratingText =
        stats.gameRating?.isNotEmpty == true ? stats.gameRating! : '-';
    final ratingValue = double.tryParse(stats.gameRating ?? '') ?? 0;
    final ratingPercent = (ratingValue / 10).clamp(0.0, 1.0);
    final playerImageUrl = (playerProfile.photo?.isNotEmpty == true)
        ? playerProfile.photo!
        : 'https://media.api-sports.io/football/players/${playerProfile.id}.png';
    final teamLogo = stats.teamPhoto?.isNotEmpty == true
        ? stats.teamPhoto!
        : (playerProfile.currentTeamLogo ?? '');
    final leagueLogo = stats.leaguePhoto ?? '';

    double topPart = switch (stats.gamePosition) {
      'Attacker' => 20.h,
      'Goalkeeper' => 170.h,
      'Defender' => 150.h,
      'Midfielder' => 100.h,
      'Right Back' => 130.h,
      'Left Back' => 130.h,
      'Center Back' => 150.h,
      'Wing Back' => 120.h,
      _ => 85.h,
    };

    String formatInt(int? value) => value == null ? '-' : value.toString();
    String formatPercent(int? value) =>
        value == null ? '-' : '${value.toString()}%';

    return Stack(
      children: [
        const Positioned.fill(child: _FuturisticBackground()),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Reveal(
                delay: const Duration(milliseconds: 0),
                child: Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: modernCard(context, glow: true),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DemoLocalizations.name.toUpperCase(),
                              style: TextUtils.setTextStyle(
                                fontSize: 10.sp,
                                letterSpacing: 1.4,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              getFullName(),
                              style: TextUtils.setTextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _getTranslatedPlayerPosition(
                                stats.gamePosition ?? '',
                              ),
                              style: TextUtils.setTextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            if (teamName.trim().isNotEmpty)
                              _IconLabelRow(
                                text: teamName,
                                imageUrl: teamLogo,
                                icon: Icons.shield_outlined,
                              ),
                            if (teamName.trim().isNotEmpty)
                              SizedBox(height: 6.h),
                            if (leagueName.trim().isNotEmpty)
                              _IconLabelRow(
                                text: leagueName,
                                imageUrl: leagueLogo,
                                icon: Icons.emoji_events_outlined,
                              ),
                            if (playerProfile.injured == true)
                              Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: _TagPill(
                                  text: DemoLocalizations.onInjury,
                                  color: scheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      _AvatarRing(
                        imageUrl: playerImageUrl,
                        ratingText: ratingText,
                        ratingColor: getRatingColor(stats.gameRating),
                        jerseyNumber: stats.gameNumber?.toString(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _Reveal(
                delay: const Duration(milliseconds: 80),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: modernCard(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: DemoLocalizations.profile.toUpperCase(),
                        icon: Icons.tune_rounded,
                      ),
                      SizedBox(height: 12.h),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 420 ? 3 : 2;
                          final ratio = crossAxisCount == 3 ? 2.6 : 2.4;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: ratio,
                            children: [
                              _StatPill(
                                label: DemoLocalizations.age,
                                value: getAge().toString(),
                                icon: Icons.cake_outlined,
                              ),
                              _StatPill(
                                label: DemoLocalizations.height,
                                value: '${playerProfile.height ?? '-'} cm',
                                icon: Icons.height_rounded,
                              ),
                              _StatPill(
                                label: DemoLocalizations.weight,
                                value: '${playerProfile.weight ?? '-'} kg',
                                icon: Icons.monitor_weight_outlined,
                              ),
                              _StatPill(
                                label: DemoLocalizations.jerseyNumber,
                                value: stats.gameNumber?.toString() ?? '-',
                                icon: Icons.confirmation_number_outlined,
                              ),
                              _StatPill(
                                label: DemoLocalizations.nationality,
                                value: getCountryName(),
                                icon: Icons.public_outlined,
                              ),
                              _StatPill(
                                label: DemoLocalizations.year,
                                value: getFormattedBirthDate(),
                                icon: Icons.event_outlined,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _Reveal(
                delay: const Duration(milliseconds: 160),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: modernCard(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: _SectionHeader(
                              title: DemoLocalizations.seasonPerformance
                                  .toUpperCase(),
                              icon: Icons.insights_outlined,
                              showAccent: false,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          _RatingRing(
                            value: ratingPercent,
                            ratingText: ratingText,
                            color: getRatingColor(stats.gameRating),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (leagueName.trim().isNotEmpty)
                        Row(
                          children: [
                            if (leagueLogo.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: leagueLogo,
                                width: 20.w,
                                height: 20.w,
                                placeholder: (_, __) => SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.sports_soccer,
                                  size: 20.w,
                                ),
                              )
                            else
                              Icon(Icons.sports_soccer, size: 20.w),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                leagueName,
                                style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (leagueName.trim().isNotEmpty)
                        SizedBox(height: 12.h),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 420 ? 3 : 2;
                          final ratio = crossAxisCount == 3 ? 2.5 : 2.7;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: ratio,
                            children: [
                              _MetricTile(
                                label: DemoLocalizations.played,
                                value: formatInt(stats.gameAppearances),
                                icon: Icons.sports_soccer,
                              ),
                              _MetricTile(
                                label: DemoLocalizations.goal,
                                value: formatInt(stats.totalGoals),
                                icon: Icons.sports_score,
                              ),
                              _MetricTile(
                                label: DemoLocalizations.topAssist,
                                value: formatInt(stats.assists),
                                icon: Icons.handshake_outlined,
                              ),
                              _MetricTile(
                                label: DemoLocalizations.lineUp,
                                value: formatInt(stats.gameLineups),
                                icon: Icons.view_list_rounded,
                              ),
                              _MetricTile(
                                label: DemoLocalizations.minutes,
                                value: formatInt(stats.gameMinutes),
                                icon: Icons.schedule,
                              ),
                              _MetricTile(
                                label: DemoLocalizations.totalPass,
                                value: formatPercent(stats.passesAccuracy),
                                icon: Icons.swap_horiz_rounded,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _Reveal(
                delay: const Duration(milliseconds: 220),
                child: Container(
                  decoration: modernCard(context),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DemoLocalizations.player_trait,
                              style: TextUtils.setTextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            iconSize: 18,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              43.0, 20.0, 24.0, 40.0),
                                          child: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(
                                                  DemoLocalizations.description,
                                                  style: TextUtils.setTextStyle(
                                                    fontSize: 18.sp,
                                                    engFont: 12.sp,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  DemoLocalizations.describing,
                                                  style: TextUtils.setTextStyle(
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: TextButton(
                                            child: Text(
                                              DemoLocalizations.close,
                                              style: TextUtils.setTextStyle(),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              Icons.info_outline,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        DemoLocalizations.Stats_compared,
                        style: TextUtils.setTextStyle(
                          fontSize: 10.sp,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      Center(
                        child: PremiumRadarChartWidget(
                          values: [
                            (stats.totalBlocks ?? 0).toDouble(),
                            (stats.duelsWon ?? 0).toDouble(),
                            (stats.passesAccuracy ?? 0)
                                .toDouble()
                                .clamp(0, 100),
                            (stats.assists ?? 0).toDouble(),
                            (stats.totalShot ?? 0).toDouble(),
                            (stats.totalGoals ?? 0).toDouble(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _Reveal(
                delay: const Duration(milliseconds: 280),
                child: Container(
                  height: 260.h,
                  decoration: modernCard(context),
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DemoLocalizations.playground.toUpperCase(),
                              style: TextUtils.setTextStyle(
                                fontSize: 10.sp,
                                letterSpacing: 1.3,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _getTranslatedPlayerPosition(
                                stats.gamePosition ?? '',
                              ),
                              style: TextUtils.setTextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/football.png', height: 220.h),
                            Positioned(
                              top: topPart,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://media.api-sports.io/football/players/${playerProfile.id}.png',
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: Colors.grey[300]),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.person, size: 30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 22.sp,
                            color: scheme.primary,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            DemoLocalizations.field,
                            style: TextUtils.setTextStyle(
                              fontSize: 10.sp,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _SectionHeader(
                title: DemoLocalizations.team.toUpperCase(),
                icon: Icons.group_outlined,
              ),
              SizedBox(height: 12.h),
              _Reveal(
                delay: const Duration(milliseconds: 340),
                child: PlayersView(
                  playerId: playerProfile.id,
                  playerNameTextColor: scheme.onSurface,
                  playerNumberTextColor: scheme.onSurface,
                ),
              ),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _FuturisticBackground extends StatelessWidget {
  const _FuturisticBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF0A1020) : const Color(0xFFF3F7FF),
            isDark ? const Color(0xFF101A2E) : const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80.h,
            right: -40.w,
            child: _GlowOrb(
              color: scheme.primary.withOpacity(isDark ? 0.35 : 0.25),
              size: 220.w,
            ),
          ),
          Positioned(
            bottom: -120.h,
            left: -60.w,
            child: _GlowOrb(
              color: scheme.tertiary.withOpacity(isDark ? 0.3 : 0.2),
              size: 260.w,
            ),
          ),
          Positioned(
            top: 120.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    scheme.primary.withOpacity(isDark ? 0.4 : 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 90,
            spreadRadius: 25,
          ),
        ],
      ),
    );
  }
}

class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _Reveal({required this.child, required this.delay});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_opacity);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool showAccent;

  const _SectionHeader({
    required this.title,
    this.icon,
    this.showAccent = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAccent)
          Container(
            width: 16.w,
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.tertiary,
                ],
              ),
            ),
          ),
        if (showAccent) SizedBox(width: 8.w),
        if (icon != null) ...[
          Icon(icon, size: 14.sp, color: scheme.primary),
          SizedBox(width: 6.w),
        ],
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextUtils.setTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface.withOpacity(0.95),
            scheme.surfaceVariant.withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: scheme.primary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextUtils.setTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextUtils.setTextStyle(
                    fontSize: 9.sp,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: scheme.surface.withOpacity(0.9),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 14.sp, color: scheme.primary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextUtils.setTextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextUtils.setTextStyle(
                    fontSize: 8.5.sp,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRing extends StatelessWidget {
  final double value;
  final String ratingText;
  final Color color;

  const _RatingRing({
    required this.value,
    required this.ratingText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 54.w,
          height: 54.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 5,
              ),
              Text(
                ratingText,
                style: TextUtils.setTextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          DemoLocalizations.rank,
          style: TextUtils.setTextStyle(
            fontSize: 9.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  final String ratingText;
  final Color color;

  const _RatingPill({
    required this.ratingText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.4),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            ratingText,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TagPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextUtils.setTextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _IconLabelRow extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final IconData icon;

  const _IconLabelRow({
    required this.text,
    this.imageUrl,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (imageUrl != null && imageUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            width: 18.w,
            height: 18.w,
            placeholder: (_, __) => SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => Icon(icon, size: 18.w),
          )
        else
          Icon(icon, size: 18.w),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final String imageUrl;
  final String ratingText;
  final Color ratingColor;
  final String? jerseyNumber;

  const _AvatarRing({
    required this.imageUrl,
    required this.ratingText,
    required this.ratingColor,
    required this.jerseyNumber,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 92.w,
          height: 92.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                scheme.primary.withOpacity(0.7),
                scheme.tertiary.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: scheme.surfaceContainerHighest,
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.person),
              ),
            ),
          ),
        ),
        if (jerseyNumber != null && jerseyNumber!.isNotEmpty)
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.5),
                ),
              ),
              child: Text(
                '#$jerseyNumber',
                style: TextUtils.setTextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: -12.h,
          child: _RatingPill(
            ratingText: ratingText,
            color: ratingColor,
          ),
        ),
      ],
    );
  }
}

class PremiumRadarChartWidget extends StatelessWidget {
  final List<double> values;

  const PremiumRadarChartWidget({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = scheme.primary;

    final labels = [
      DemoLocalizations.totalBlocks.isNotEmpty
          ? DemoLocalizations.totalBlocks
          : "Blocks",
      DemoLocalizations.duelsWon.isNotEmpty
          ? DemoLocalizations.duelsWon
          : "Duels Won",
      DemoLocalizations.totalPass.isNotEmpty
          ? DemoLocalizations.totalPass
          : "Pass Accuracy",
      DemoLocalizations.topAssist.isNotEmpty
          ? DemoLocalizations.topAssist
          : "Assists",
      DemoLocalizations.shots.isNotEmpty ? DemoLocalizations.shots : "Shots",
      DemoLocalizations.goal.isNotEmpty ? DemoLocalizations.goal : "Goals",
    ];

    return SizedBox(
      width: 250.w,
      height: 250.h,
      child: CustomPaint(
        painter: PremiumRadarChartPainter(
          values: values,
          labels: labels,
          fillColor: accent.withOpacity(isDark ? 0.3 : 0.22),
          outlineColor: accent.withOpacity(isDark ? 0.9 : 0.85),
          textColor: scheme.onSurface.withOpacity(0.9),
          gridColor: scheme.onSurface.withOpacity(isDark ? 0.12 : 0.08),
          spokeColor: scheme.onSurface.withOpacity(isDark ? 0.18 : 0.12),
        ),
      ),
    );
  }
}

class PremiumRadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color fillColor;
  final Color outlineColor;
  final Color textColor;
  final Color gridColor;
  final Color spokeColor;

  PremiumRadarChartPainter({
    required this.values,
    required this.labels,
    required this.fillColor,
    required this.outlineColor,
    required this.textColor,
    required this.gridColor,
    required this.spokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) * 0.75;
    final angle = 2 * pi / values.length;

    // Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Spokes
    final spokePaint = Paint()
      ..color = spokeColor
      ..strokeWidth = 1.0;

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Outline
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Draw concentric grid
    for (int i = 1; i <= 5; i++) {
      final r = radius * i / 5;
      final path = Path();
      for (int j = 0; j < values.length; j++) {
        final x = center.dx + r * cos(angle * j - pi / 2);
        final y = center.dy + r * sin(angle * j - pi / 2);
        j == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes
    for (int i = 0; i < values.length; i++) {
      final x = center.dx + radius * cos(angle * i - pi / 2);
      final y = center.dy + radius * sin(angle * i - pi / 2);
      canvas.drawLine(center, Offset(x, y), spokePaint);
    }

    // Draw data shape
    final dataPath = Path();
    for (int i = 0; i < values.length; i++) {
      final normalized = (values[i] / 100).clamp(0.0, 1.0);
      final r = radius * normalized;
      final x = center.dx + r * cos(angle * i - pi / 2);
      final y = center.dy + r * sin(angle * i - pi / 2);
      i == 0 ? dataPath.moveTo(x, y) : dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, outlinePaint);

    // Draw labels + percentages
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labelOffset = 14.0;

    for (int i = 0; i < labels.length; i++) {
      final percent = '${values[i].toInt()}%';
      final fullText = '${labels[i]}\n$percent';

      textPainter.text = TextSpan(
        text: fullText,
        style: TextUtils.setTextStyle(
          color: textColor,
          fontSize: 11.sp,
          height: 1.4,
        ),
      );
      textPainter.layout();

      final x = center.dx + (radius + labelOffset) * cos(angle * i - pi / 2);
      final y = center.dy + (radius + labelOffset) * sin(angle * i - pi / 2);

      canvas.save();
      canvas.translate(x, y);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

String _getTranslatedPlayerPosition(String position) {
  return PlayerPositionTranslation.translatePosition(position);
}

/// ================== PLAYERS VIEW (Teammates) ==================
class PlayersView extends StatefulWidget {
  final int playerId;
  final Color playerNameTextColor;
  final Color playerNumberTextColor;

  const PlayersView({
    super.key,
    required this.playerId,
    required this.playerNameTextColor,
    required this.playerNumberTextColor,
  });

  @override
  _TeammatesViewState createState() => _TeammatesViewState();
}

class _TeammatesViewState extends State<PlayersView> {
  @override
  void initState() {
    super.initState();
    context
        .read<TeammatesBloc>()
        .add(TeammatesRequested(playerId: widget.playerId));
  }

  Widget _buildSquadSection(SquadModel squad) {
    final scheme = Theme.of(context).colorScheme;
    final List<PlayerName> allPlayers = [
      ...squad.goalKeepers,
      ...squad.defenders,
      ...squad.midfielders,
      ...squad.attackers,
    ];

    if (allPlayers.isEmpty) return const SizedBox.shrink();

    final String deviceLanguage = localLanguageNotifier.value;

    String teamName = squad.team.englishName;
    if (deviceLanguage == 'am' || deviceLanguage == 'tr') {
      teamName = squad.team.amharicName.isNotEmpty
          ? squad.team.amharicName
          : squad.team.englishName;
    } else if (deviceLanguage == 'or') {
      teamName = squad.team.oromoName.isNotEmpty
          ? squad.team.oromoName
          : squad.team.englishName;
    } else if (deviceLanguage == 'so') {
      teamName = squad.team.somaliName.isNotEmpty
          ? squad.team.somaliName
          : squad.team.englishName;
    }

    final String primaryLogo = squad.team.logo ?? '';
    String getSafeTeamLogo(String? logo, int teamId) {
      if (logo == null || logo.isEmpty) {
        return 'https://media.api-sports.io/football/teams/$teamId.png';
      }
      if (logo.contains('media-4.api-sports.io')) {
        return logo.replaceAll('media-4.api-sports.io', 'media.api-sports.io');
      }
      return logo;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface.withOpacity(0.96),
            scheme.surfaceVariant.withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withOpacity(0.6),
                      scheme.tertiary.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: getSafeTeamLogo(primaryLogo, squad.team.id),
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Padding(
                        padding: EdgeInsets.all(6.w),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) =>
                          Image.asset('assets/club-icon.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  teamName,
                  style: TextUtils.setTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 130.h,
            child: SquadList(
              header: '',
              players: allPlayers,
              teamPic: primaryLogo.isNotEmpty
                  ? primaryLogo
                  : 'https://media.api-sports.io/football/teams/${squad.team.id}.png',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeammatesBloc, TeammatesState>(
      builder: (context, state) {
        if (state.status == TeammatesStatus.initial ||
            state.status == TeammatesStatus.requested) {
          return SizedBox(
              height: 300.h,
              child: const Center(child: CircularProgressIndicator()));
        }
        if (state.status == TeammatesStatus.requestFailure) {
          return Center(child: Text(DemoLocalizations.networkProblem));
        }
        if (state.status == TeammatesStatus.notFound || state.squads.isEmpty) {
          return Center(child: Text(DemoLocalizations.informationNotFound));
        }
        if (state.status == TeammatesStatus.requestSuccess) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: state.squads.length,
            itemBuilder: (context, index) =>
                _buildSquadSection(state.squads[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
