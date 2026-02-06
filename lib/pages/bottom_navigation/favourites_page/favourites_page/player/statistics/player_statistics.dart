import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../../../../../domain/player/playerStatisticsModel.dart';
import '../../../../../../localization/demo_localization.dart';
import '../../../../../../util/baseUrl.dart';
import '../../../../../constants/text_utils.dart';
import '../details/details_row.dart';
import 'stat_drop_down.dart';

class PlayerProfileStatistics extends StatefulWidget {
  final List<PlayerStatistics> playerStatistics;
  final Color? color;

  const PlayerProfileStatistics({
    super.key,
    required this.playerStatistics,
    this.color,
  });

  @override
  State<PlayerProfileStatistics> createState() =>
      _PlayerProfileStatisticsState();
}

class _PlayerProfileStatisticsState extends State<PlayerProfileStatistics> {
  int selectedIndex = 0;

  // Top values for comparison (fetched from API)
  int gamesApperance = 1;
  int minutesplayed = 1;
  int substitutedBench = 1;
  int totalShot = 1;
  int onShot = 1;
  int totalGoals = 1;
  int goalsConceaded = 1;
  int assists = 1;
  int keypasses = 1;
  int totaltackels = 1;
  int passaccuracy = 1;
  int totalSaves = 1;
  int totalPasses = 1;
  int totalblocks = 1;
  int totalinterceptions = 1;
  int duelswon = 1;
  int dribbleattempts = 1;
  int dribblesuccess = 1;
  int dribblepast = 1;
  int foulsdrawn = 1;
  int foulscomitted = 1;
  int yellow = 1;
  int red = 1;
  int yellowred = 1;
  int penalitywon = 1;
  int penalitycommited = 1;
  int penalityscored = 1;
  int penalitysaved = 1;
  int penalitymissed = 1;

  void setIndex(int index) {
    if (mounted) {
      setState(() => selectedIndex = index);
    }
  }

  // Safe setState wrapper
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Generic fetch function for all stats
  Future<void> _fetchStat(String field, [String? position]) async {
    final baseUrl = BaseUrl().url;
    final url =
        '$baseUrl/api/compareplayer/$field${position != null ? '/$position' : ''}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        final value = (json[field] ?? 0) as int;

        _safeSetState(() {
          switch (field) {
            case 'gameAppearances':
              gamesApperance = value;
              break;
            case 'gameMinutes':
              minutesplayed = value;
              break;
            case 'substitutedBench':
              substitutedBench = value;
              break;
            case 'totalShot':
              totalShot = value;
              break;
            case 'onShot':
              onShot = value;
              break;
            case 'totalGoals':
              totalGoals = value;
              break;
            case 'goalsConceded':
              goalsConceaded = value;
              break;
            case 'assists':
              assists = value;
              break;
            case 'totalSaves':
              totalSaves = value;
              break;
            case 'totalPasses':
              totalPasses = value;
              break;
            case 'keyPasses':
              keypasses = value;
              break;
            case 'passesAccuracy':
              passaccuracy = value;
              break;
            case 'totalBlocks':
              totalblocks = value;
              break;
            case 'totalInterceptions':
              totalinterceptions = value;
              break;
            case 'totalTackles':
              totaltackels = value;
              break;
            case 'duelsWon':
              duelswon = value;
              break;
            case 'dribbleAttempts':
              dribbleattempts = value;
              break;
            case 'dribbleSuccess':
              dribblesuccess = value;
              break;
            case 'dribblePast':
              dribblepast = value;
              break;
            case 'foulsDrawn':
              foulsdrawn = value;
              break;
            case 'foulsCommitted':
              foulscomitted = value;
              break;
            case 'yellowCards':
              yellow = value;
              break;
            case 'redCards':
              red = value;
              break;
            case 'yellowRedCards':
              yellowred = value;
              break;
            case 'penalityWon':
              penalitywon = value;
              break;
            case 'penalityCommitted':
              penalitycommited = value;
              break;
            case 'penalityScored':
              penalityscored = value;
              break;
            case 'penalitySaved':
              penalitysaved = value;
              break;
            case 'penalityMissed':
              penalitymissed = value;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching $field: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Run all API calls in parallel
    Future.wait([
      _fetchStat('gameAppearances'),
      _fetchStat('gameMinutes', 'Goalkeeper'),
      _fetchStat('substitutedBench', 'Attacker'),
      _fetchStat('totalShot', 'Attacker'),
      _fetchStat('onShot', 'Attacker'),
      _fetchStat('totalGoals', 'Attacker'),
      _fetchStat('goalsConceded', 'Goalkeeper'),
      _fetchStat('assists', 'Midfielder'),
      _fetchStat('totalSaves', 'Goalkeeper'),
      _fetchStat('totalPasses', 'Midfielder'),
      _fetchStat('keyPasses', 'Midfielder'),
      _fetchStat('passesAccuracy', 'Midfielder'),
      _fetchStat('totalBlocks', 'Defender'),
      _fetchStat('totalInterceptions', 'Defender'),
      _fetchStat('totalTackles', 'Defender'),
      _fetchStat('duelsWon', 'Defender'),
      _fetchStat('dribbleAttempts', 'Attacker'),
      _fetchStat('dribbleSuccess', 'Attacker'),
      _fetchStat('dribblePast', 'Attacker'),
      _fetchStat('foulsDrawn', 'Defender'),
      _fetchStat('foulsCommitted', 'Defender'),
      _fetchStat('yellowCards', 'Defender'),
      _fetchStat('redCards', 'Defender'),
      _fetchStat('yellowRedCards', 'Defender'),
      _fetchStat('penalityWon', 'Attacker'),
      _fetchStat('penalityCommitted', 'Defender'),
      _fetchStat('penalityScored', 'Attacker'),
      _fetchStat('penalitySaved', 'Goalkeeper'),
      _fetchStat('penalityMissed', 'Attacker'),
    ]);
  }

  double _norm(double value, double maxValue) {
    if (maxValue <= 0) return 0.0;
    return (value / maxValue).clamp(0.0, 1.0);
  }

  double _normSaves(double value) => (value / totalSaves).clamp(0.0, 2.0);
  double _normDuelsTotal(double value) => (value / 250).clamp(0.0, 1.0);

  Color _getAdvancedColor(String? ratingString) {
    final rating = double.tryParse(ratingString ?? '') ?? 0.0;
    if (rating == 0) return Colors.grey.withOpacity(0.5);
    if (rating < 5.0) {
      return Color.lerp(Colors.red.shade900, Colors.red.shade400, rating / 5)!;
    } else if (rating < 7.0) {
      return Color.lerp(
          Colors.orange.shade400, Colors.yellow.shade700, (rating - 5) / 2)!;
    } else if (rating < 8.5) {
      return Color.lerp(
          Colors.lightGreen, Colors.green.shade700, (rating - 7) / 1.5)!;
    }
    return Colors.blueAccent.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final stat = widget.playerStatistics[selectedIndex];
    final scheme = Theme.of(context).colorScheme;

    final summaryMetrics = [
      (_MetricBadgeData(label: DemoLocalizations.played, value: stat.gameAppearances?.toString() ?? '-', icon: Icons.sports_soccer)),
      (_MetricBadgeData(label: DemoLocalizations.minutesPlayed, value: stat.gameMinutes?.toString() ?? '-', icon: Icons.schedule)),
      (_MetricBadgeData(label: DemoLocalizations.goal, value: stat.totalGoals?.toString() ?? '-', icon: Icons.sports_score)),
      (_MetricBadgeData(label: DemoLocalizations.topAssist, value: stat.assists?.toString() ?? '-', icon: Icons.handshake_outlined)),
      (_MetricBadgeData(label: DemoLocalizations.totalPass, value: stat.passesAccuracy != null ? '${stat.passesAccuracy}%' : '-', icon: Icons.swap_horiz_rounded)),
      (_MetricBadgeData(label: DemoLocalizations.shots, value: stat.totalShot?.toString() ?? '-', icon: Icons.bolt_outlined)),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surface.withOpacity(0.95),
                  scheme.surfaceVariant.withOpacity(0.85),
                ],
              ),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(14.w),
            child: PlayerstatDropdown(
              playerStats: widget.playerStatistics,
              index: selectedIndex,
              setIndex: setIndex,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withOpacity(0.08),
                  scheme.tertiary.withOpacity(0.10),
                  scheme.surface,
                ],
              ),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DemoLocalizations.seasonPerformance,
                            style: TextUtils.setTextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DemoLocalizations.profile,
                            style: TextUtils.setTextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RatingDial(
                      value: double.tryParse(stat.gameRating ?? '') ?? 0,
                      color: _getAdvancedColor(stat.gameRating),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 10.h,
                  children: summaryMetrics
                      .map((m) => _MetricBadge(data: m))
                      .toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _SectionRow(
            title: DemoLocalizations.Stats_compared,
            onInfo: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: scheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(43, 20, 24, 40),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DemoLocalizations.description,
                              style: TextUtils.setTextStyle(fontSize: 18.sp)),
                          const SizedBox(height: 18),
                          Text(DemoLocalizations.stat_info,
                              style: TextUtils.setTextStyle(fontSize: 13.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.22)),
            ),
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
            child: Column(
              children: [
                _SectionLabel(text: DemoLocalizations.seasonPerformance),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.numberOfGames,
                  value: stat.gameAppearances?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.gameAppearances?.toDouble() ?? 0,
                    gamesApperance.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.minutesPlayed,
                  value: stat.gameMinutes?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.gameMinutes?.toDouble() ?? 0,
                    minutesplayed.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.waiter,
                  value: stat.substitutedBench?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.substitutedBench?.toDouble() ?? 0,
                    substitutedBench.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.generalTest,
                  value: stat.totalShot?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalShot?.toDouble() ?? 0,
                    totalShot.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.onTargetTrials,
                  value: stat.onShot?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.onShot?.toDouble() ?? 0,
                    onShot.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalGoalsScored,
                  value: stat.totalGoals?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalGoals?.toDouble() ?? 0,
                    totalGoals.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalGoalsConceded,
                  value: stat.goalsConceded?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.goalsConceded?.toDouble() ?? 0,
                    goalsConceaded.toDouble(),
                  ),
                ),
                const Divider(height: 22),
                _SectionLabel(text: DemoLocalizations.totalPass),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.heAcceptedForTheGoal,
                  value: stat.assists?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.assists?.toDouble() ?? 0,
                    assists.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.whoSavedHim,
                  value: stat.totalSaves?.toString() ?? '-',
                  normalizedValue: _normSaves(stat.totalSaves?.toDouble() ?? 0),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalPass,
                  value: stat.totalPasses?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalPasses?.toDouble() ?? 0,
                    totalPasses.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.keyRelay,
                  value: stat.keyPasses?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.keyPasses?.toDouble() ?? 0,
                    keypasses.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.relaySuccess,
                  value: stat.passesAccuracy?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.passesAccuracy?.toDouble() ?? 0,
                    passaccuracy.toDouble(),
                  ),
                ),
                const Divider(height: 22),
                _SectionLabel(text: DemoLocalizations.totalTackle),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalTackle,
                  value: stat.totalTackles?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalTackles?.toDouble() ?? 0,
                    totaltackels.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalBlocks,
                  value: stat.totalBlocks?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalBlocks?.toDouble() ?? 0,
                    totalblocks.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.totalInterceptions,
                  value: stat.totalInterceptions?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.totalInterceptions?.toDouble() ?? 0,
                    totalinterceptions.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.duelsTotal,
                  value: stat.duelsTotal?.toString() ?? '-',
                  normalizedValue:
                      _normDuelsTotal(stat.duelsTotal?.toDouble() ?? 0),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.duelsWon,
                  value: stat.duelsWon?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.duelsWon?.toDouble() ?? 0,
                    duelswon.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.dribbleAttempts,
                  value: stat.dribbleAttempts?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.dribbleAttempts?.toDouble() ?? 0,
                    dribbleattempts.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.dribbleSuccess,
                  value: stat.dribbleSuccess?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.dribbleSuccess?.toDouble() ?? 0,
                    dribblesuccess.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.dribblesPast,
                  value: stat.dribblePast?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.dribblePast?.toDouble() ?? 0,
                    dribblepast.toDouble(),
                  ),
                ),
                const Divider(height: 22),
                _SectionLabel(text: DemoLocalizations.foul),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.foulsDrawn,
                  value: stat.foulsDrawn?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.foulsDrawn?.toDouble() ?? 0,
                    foulsdrawn.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.committedFouls,
                  value: stat.foulsCommitted?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.foulsCommitted?.toDouble() ?? 0,
                    foulscomitted.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.yellowCards,
                  value: stat.yellowCards?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.yellowCards?.toDouble() ?? 0,
                    yellow.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.yellowRedCards,
                  value: stat.yellowRedCards?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.yellowRedCards?.toDouble() ?? 0,
                    yellowred.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.redCard,
                  value: stat.redCards?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.redCards?.toDouble() ?? 0,
                    red.toDouble(),
                  ),
                ),
                const Divider(height: 22),
                _SectionLabel(text: DemoLocalizations.penality),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.penaltyWon,
                  value: stat.penalityWon?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.penalityWon?.toDouble() ?? 0,
                    penalitywon.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.penaltyCommitted,
                  value: stat.penalityCommitted?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.penalityCommitted?.toDouble() ?? 0,
                    penalitycommited.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.penalty_scored,
                  value: stat.penalityScored?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.penalityScored?.toDouble() ?? 0,
                    penalityscored.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.penalty_missed,
                  value: stat.penalityMissed?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.penalityMissed?.toDouble() ?? 0,
                    penalitymissed.toDouble(),
                  ),
                ),
                Player_stat_lists_DetailColumn(
                  label: DemoLocalizations.penaltySaved,
                  value: stat.penalitySaved?.toString() ?? '-',
                  normalizedValue: _norm(
                    stat.penalitySaved?.toDouble() ?? 0,
                    penalitysaved.toDouble(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final VoidCallback onInfo;

  const _SectionRow({required this.title, required this.onInfo});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.info_outline, size: 18.sp, color: scheme.onSurfaceVariant),
          onPressed: onInfo,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextUtils.setTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MetricBadgeData {
  final String label;
  final String value;
  final IconData icon;
  const _MetricBadgeData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _MetricBadge extends StatelessWidget {
  final _MetricBadgeData data;
  const _MetricBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: scheme.surface.withOpacity(0.92),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(data.icon, size: 16.sp, color: scheme.primary),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.value,
                style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                data.label,
                style: TextUtils.setTextStyle(
                  fontSize: 10.sp,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingDial extends StatelessWidget {
  final double value; // 0-10
  final Color color;

  const _RatingDial({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 10).clamp(0.0, 1.0);
    return SizedBox(
      width: 70.w,
      height: 70.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalized,
            strokeWidth: 6,
            backgroundColor: color.withOpacity(0.18),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextUtils.setTextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                DemoLocalizations.rank,
                style: TextUtils.setTextStyle(
                  fontSize: 9.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
