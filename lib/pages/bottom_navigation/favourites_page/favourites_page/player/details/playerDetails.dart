import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl_fmt;

import '../../../../../../bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import '../../../../../../bloc/mirchaweche/players/player_teammates/teammates_event.dart';
import '../../../../../../bloc/mirchaweche/players/player_teammates/teammates_state.dart';
import '../../../../../../domain/player/playerModel.dart';
import '../../../../../../domain/player/playerName.dart';
import '../../../../../../localization/demo_localization.dart';
import '../../../../../../main.dart';
import '../../../../../../models/favourites_page/squadModel.dart';
import 'player_position_translation.dart';
import '../../../../../constants/text_utils.dart';
import 'squad_list.dart';
import 'details_row.dart';

/// ================== MODERN CARD DECORATION ==================
BoxDecoration modernCard(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12.r),
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

    Color _getRatingColor(String? rating) {
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ================== MODERN PERSONAL INFO CARD ==================
          Container(
            width: double.infinity,
            // height: 253.h,  // ← Remove this fixed height
            padding: EdgeInsets.all(
                16.w), // Add some bottom padding for breathing room inside
            decoration: modernCard(context),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // or center, as needed
              children: [
                Text(
                  DemoLocalizations.name,
                  style: TextUtils.setTextStyle(
                    fontSize: 10.sp,
                    height: 1.2,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  getFullName(),
                  style: TextUtils.setTextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 3,
                ),
                SizedBox(
                    height: 12.h), // Add consistent spacing before the grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 400
                        ? 4
                        : (constraints.maxWidth > 160 ? 3 : 2);
                    final childAspectRatio = crossAxisCount == 4
                        ? 1.6
                        : (crossAxisCount == 3 ? 1.4 : 1.3);

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _ModernDetailItem(
                          label: DemoLocalizations
                              .age, // or just an empty string if you don't want a label
                          value: '${getAge()}',
                        ),
                        _ModernDetailItem(
                          label: DemoLocalizations.height,
                          value: '${playerProfile.height ?? '-'} cm',
                        ),
                        _ModernDetailItem(
                          label: DemoLocalizations.weight,
                          value: '${playerProfile.weight ?? '-'} kg',
                        ),
                        _ModernDetailItem(
                          label: DemoLocalizations.jerseyNumber,
                          value: stats.gameNumber?.toString() ?? '-',
                        ),
                        _ModernDetailItem(
                          label: DemoLocalizations.nationality,
                          value: getCountryName(),
                        ),
                        _ModernDetailItem(
                          label: DemoLocalizations.year,
                          value: getFormattedBirthDate(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),

          /// ================== LEAGUE + STATS ==================
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: modernCard(context),
            child: Column(
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: stats.leaguePhoto ?? '',
                      width: 18.w,
                      height: 18.w,
                      placeholder: (_, __) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.sports_soccer, size: 32.w),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        leagueName,
                        style: TextUtils.setTextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Player_league_performanceDetailRow1(
                      label: DemoLocalizations.played,
                      value: stats.gameAppearances.toString(),
                    ),
                    Player_league_performanceDetailRow1(
                      label: DemoLocalizations.goal,
                      value: stats.totalGoals.toString(),
                    ),
                    Player_league_performanceDetailRow1(
                      label: DemoLocalizations.topAssist,
                      value: stats.assists.toString(),
                    ),
                    // Rating circle with Rank label below it
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getRatingColor(stats.gameRating),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            stats.gameRating ?? '-',
                            style: TextUtils.setTextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                4.h), // Small spacing between circle and text
                        Text(
                          DemoLocalizations.rank,
                          style: TextUtils.setTextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          /// ================== RADAR CHART ==================
          Container(
            width: double.infinity,
            height: 300.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Text(
                    DemoLocalizations.player_trait,
                    style: TextUtils.setTextStyle(
                      fontSize: 18.sp,
                      engFont: 12.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DemoLocalizations.Stats_compared,
                          style: TextUtils.setTextStyle(fontSize: 10.sp),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: 8.w), // Small spacing
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 24, minHeight: 24),
                        iconSize: 16,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Center(
                    child: PremiumRadarChartWidget(
                      values: [
                        (stats.totalBlocks ?? 0).toDouble(),
                        (stats.duelsWon ?? 0).toDouble(),
                        (stats.passesAccuracy ?? 0).toDouble().clamp(0, 100),
                        (stats.assists ?? 0).toDouble(),
                        (stats.totalShot ?? 0).toDouble(),
                        (stats.totalGoals ?? 0).toDouble(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          /// ================== POSITION ==================
          /// ================== POSITION + PITCH WITH ARROW ON THE RIGHT (OUTSIDE) ==================
          Container(
            height: 290.h,
            decoration: modernCard(context),
            child: Row(
              children: [
                // Left: Position text
                Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DemoLocalizations.playground,
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _getTranslatedPlayerPosition(stats.gamePosition ?? ''),
                        style: TextUtils.setTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle: Pitch with player photo
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/football.png', height: 240.h),
                      Positioned(
                        top: topPart,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://media.api-sports.io/football/players/${playerProfile.id}.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.person, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Green upward arrow (outside the pitch, on the card's right edge)
                Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: Center(
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 19.sp,
                      color: Colors
                          .green, // Or: Colorscontainer.greenColor if you have it
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          /// ================== TEAM ==================
          Text(DemoLocalizations.team.toUpperCase(),
              style: TextUtils.setTextStyle(
                  fontSize: 13.sp, letterSpacing: 1.2, color: Colors.grey)),
          SizedBox(height: 12.h),

          PlayersView(
            playerId: playerProfile.id,
            playerNameTextColor: Theme.of(context).colorScheme.onSurface,
            playerNumberTextColor: Theme.of(context).colorScheme.onSurface,
          ),

          SizedBox(height: 60.h),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labels = [
      DemoLocalizations.totalBlocks ?? "Blocks",
      DemoLocalizations.duelsWon ?? "Duels Won",
      DemoLocalizations.totalPass ?? "Pass Accuracy",
      DemoLocalizations.topAssist ?? "Assists",
      DemoLocalizations.shots ?? "Shots",
      DemoLocalizations.goal ?? "Goals",
    ];

    return SizedBox(
      width: 250.w,
      height: 250.h,
      child: CustomPaint(
        painter: PremiumRadarChartPainter(
          values: values,
          labels: labels,
          fillColor: isDark
              ? const Color(0xFFB8860B) // Dark gold
              : const Color(0xFFFFD700), // Bright gold
          outlineColor:
              isDark ? const Color(0xFFFFC107) : const Color(0xFFFFD700),
          textColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
          // ← ADD THESE TWO LINES TO FIX THE ERROR
          gridColor: isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          spokeColor: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.2),
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
    final radius = min(size.width / 2, size.height / 2) *
        0.75; // Reduced from 0.82// Reduced slightly
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
      ..strokeWidth = 3.5
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

    // Draw labels + percentages (with reduced offset to avoid cutoff)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labelOffset = 16.0; // Reduced from 22 → prevents bottom overflow

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

/// ================== MODERN DETAIL ITEM  ==================
class _ModernDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;

  const _ModernDetailItem({
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Critical: don't take more height than needed
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Value - allow shrinking if needed
          Flexible(
            child: Text(
              value,
              style: TextUtils.setTextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (subValue != null) ...[
            SizedBox(height: 3.h),
            Text(
              subValue!,
              style: TextUtils.setTextStyle(
                fontSize: 9.sp, // Slightly smaller to save space
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp, // Reduced a bit to prevent overflow
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

String _getTranslatedPlayerPosition(String position) {
  return PlayerPositionTranslation.translatePosition(position);
}

/// ================== PLAYERS VIEW (Teammates) - Unchanged ==================
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: getSafeTeamLogo(primaryLogo, squad.team.id),
                  width: 26.w,
                  height: 26.h,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Padding(
                    padding: EdgeInsets.all(6.w),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) =>
                      Image.asset('assets/club-icon.png', fit: BoxFit.contain),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  teamName,
                  style: TextUtils.setTextStyle(fontSize: 14.sp),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 120.h,
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
