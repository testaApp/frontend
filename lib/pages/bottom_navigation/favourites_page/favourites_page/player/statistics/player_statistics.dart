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

  // Simple normalized value helper (0.0 to 1.0)
  double _norm(double value, double maxValue) {
    if (maxValue <= 0) return 0.0;
    return (value / maxValue).clamp(0.0, 1.0);
  }

  // Special case: total saves can go up to 2.0 for visual scaling
  double _normSaves(double value) => (value / totalSaves).clamp(0.0, 2.0);

  // Special case: duels total uses fixed 250 as max
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: PlayerstatDropdown(
                playerStats: widget.playerStatistics,
                index: selectedIndex,
                setIndex: setIndex,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 360.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
                child: Column(
                  children: [
                    // Top row: Goals, Assists, Rank
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatItem(
                          label: DemoLocalizations.totalGoalsScored,
                          value: stat.gameLineups.toString(),
                        )),
                        Expanded(
                            child: _buildStatItem(
                          label: DemoLocalizations.totalPass,
                          value: stat.gameLineups.toString(),
                        )), // Adjust to your actual localization
                        Expanded(
                          child:
                              _buildRankItem(value: stat.gameRating.toString()),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Bottom row: Appearances, Minutes Played, Lineups
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatItem(
                          label: DemoLocalizations.played,
                          value: stat.gameLineups.toString(),
                        )),
                        Expanded(
                            child: _buildStatItem(
                                label: DemoLocalizations.minutesPlayed,
                                value: stat.gameMinutes.toString())),
                        Expanded(
                            child: _buildStatItem(
                                label: DemoLocalizations.lineUp,
                                value: stat.gameLineups.toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  DemoLocalizations.seasonPerformance,
                  style: TextUtils.setTextStyle(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 4),
                    child: Text(
                      DemoLocalizations.Stats_compared,
                      style: TextUtils.setTextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 10.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 60, 4),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(43, 20, 24, 40),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(DemoLocalizations.description,
                                          style: TextUtils.setTextStyle(
                                              fontSize: 20)),
                                      const SizedBox(height: 20),
                                      Text(DemoLocalizations.stat_info,
                                          style: TextUtils.setTextStyle()),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(DemoLocalizations.close),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.question_mark, size: 15),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Appearance & Minutes
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.numberOfGames,
                    value: stat.gameAppearances?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.gameAppearances?.toDouble() ?? 0,
                        gamesApperance.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.minutesPlayed,
                    value: stat.gameMinutes?.toString() ?? '-',
                    normalizedValue: _norm(stat.gameMinutes?.toDouble() ?? 0,
                        minutesplayed.toDouble()),
                  ),

                  // Bench & Shots
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.waiter,
                    value: stat.substitutedBench?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.substitutedBench?.toDouble() ?? 0,
                        substitutedBench.toDouble()),
                  ),
                  if (stat.totalShot != null)
                    Player_stat_lists_DetailColumn(
                      label: DemoLocalizations.generalTest,
                      value: stat.totalShot.toString(),
                      normalizedValue: _norm(
                          stat.totalShot!.toDouble(), totalShot.toDouble()),
                    ),

                  // On Target & Goals
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.onTargetTrials,
                    value: stat.onShot?.toString() ?? '-',
                    normalizedValue:
                        _norm(stat.onShot?.toDouble() ?? 0, onShot.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalGoalsScored,
                    value: stat.totalGoals?.toString() ?? '-',
                    normalizedValue: _norm(stat.totalGoals?.toDouble() ?? 0,
                        totalGoals.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalGoalsConceded,
                    value: stat.goalsConceded?.toString() ?? '-',
                    normalizedValue: _norm(stat.goalsConceded?.toDouble() ?? 0,
                        goalsConceaded.toDouble()),
                  ),

                  // Assists, Saves, Passes
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.heAcceptedForTheGoal,
                    value: stat.assists?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.assists?.toDouble() ?? 0, assists.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.whoSavedHim,
                    value: stat.totalSaves?.toString() ?? '-',
                    normalizedValue:
                        _normSaves(stat.totalSaves?.toDouble() ?? 0),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalPass,
                    value: stat.totalPasses?.toString() ?? '-',
                    normalizedValue: _norm(stat.totalPasses?.toDouble() ?? 0,
                        totalPasses.toDouble()),
                  ),

                  // Key Passes, Accuracy, Tackles
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.keyRelay,
                    value: stat.keyPasses?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.keyPasses?.toDouble() ?? 0, keypasses.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.relaySuccess,
                    value: stat.passesAccuracy?.toString() ?? '-',
                    normalizedValue: _norm(stat.passesAccuracy?.toDouble() ?? 0,
                        passaccuracy.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalTackle,
                    value: stat.totalTackles?.toString() ?? '-',
                    normalizedValue: _norm(stat.totalTackles?.toDouble() ?? 0,
                        totaltackels.toDouble()),
                  ),

                  // Blocks, Interceptions, Duels Total
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalBlocks,
                    value: stat.totalBlocks?.toString() ?? '-',
                    normalizedValue: _norm(stat.totalBlocks?.toDouble() ?? 0,
                        totalblocks.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.totalInterceptions,
                    value: stat.totalInterceptions?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.totalInterceptions?.toDouble() ?? 0,
                        totalinterceptions.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.duelsTotal,
                    value: stat.duelsTotal?.toString() ?? '-',
                    normalizedValue:
                        _normDuelsTotal(stat.duelsTotal?.toDouble() ?? 0),
                  ),

                  // Duels Won, Dribble Attempts, Success
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.duelsWon,
                    value: stat.duelsWon?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.duelsWon?.toDouble() ?? 0, duelswon.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.dribbleAttempts,
                    value: stat.dribbleAttempts?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.dribbleAttempts?.toDouble() ?? 0,
                        dribbleattempts.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.dribbleSuccess,
                    value: stat.dribbleSuccess?.toString() ?? '-',
                    normalizedValue: _norm(stat.dribbleSuccess?.toDouble() ?? 0,
                        dribblesuccess.toDouble()),
                  ),

                  // Dribbles Past, Fouls Drawn, Committed
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.dribblesPast,
                    value: stat.dribblePast?.toString() ?? '-',
                    normalizedValue: _norm(stat.dribblePast?.toDouble() ?? 0,
                        dribblepast.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.foulsDrawn,
                    value: stat.foulsDrawn?.toString() ?? '-',
                    normalizedValue: _norm(stat.foulsDrawn?.toDouble() ?? 0,
                        foulsdrawn.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.committedFouls,
                    value: stat.foulsCommitted?.toString() ?? '-',
                    normalizedValue: _norm(stat.foulsCommitted?.toDouble() ?? 0,
                        foulscomitted.toDouble()),
                  ),

                  // Cards
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.yellowCards,
                    value: stat.yellowCards?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.yellowCards?.toDouble() ?? 0, yellow.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.yellowRedCards,
                    value: stat.yellowRedCards?.toString() ?? '-',
                    normalizedValue: _norm(stat.yellowRedCards?.toDouble() ?? 0,
                        yellowred.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.redCard,
                    value: stat.redCards?.toString() ?? '-',
                    normalizedValue:
                        _norm(stat.redCards?.toDouble() ?? 0, red.toDouble()),
                  ),

                  // Penalties
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.penaltyWon,
                    value: stat.penalityWon?.toString() ?? '-',
                    normalizedValue: _norm(stat.penalityWon?.toDouble() ?? 0,
                        penalitywon.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.penaltyCommitted,
                    value: stat.penalityCommitted?.toString() ?? '-',
                    normalizedValue: _norm(
                        stat.penalityCommitted?.toDouble() ?? 0,
                        penalitycommited.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.penalty_scored,
                    value: stat.penalityScored?.toString() ?? '-',
                    normalizedValue: _norm(stat.penalityScored?.toDouble() ?? 0,
                        penalityscored.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.penalty_missed,
                    value: stat.penalityMissed?.toString() ?? '-',
                    normalizedValue: _norm(stat.penalityMissed?.toDouble() ?? 0,
                        penalitymissed.toDouble()),
                  ),
                  Player_stat_lists_DetailColumn(
                    label: DemoLocalizations.penaltySaved,
                    value: stat.penalitySaved?.toString() ?? '-',
                    normalizedValue: _norm(stat.penalitySaved?.toDouble() ?? 0,
                        penalitysaved.toDouble()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatItem({required String label, required String value}) {
  final String displayValue =
      value.trim() == 'null' || value.isEmpty ? '-' : value;

  return Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextUtils.setTextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
      SizedBox(height: 10.h),
      Text(
        displayValue,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextUtils.setTextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );
}

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

Widget _buildRankItem({required String value}) {
  final double rating = double.tryParse(value) ?? 0.0;
  final Color baseColor = _getAdvancedColor(value);

  return Column(
    children: [
      Text(
        DemoLocalizations.rank, // or DemoLocalizations.rank
        textAlign: TextAlign.center,
        style: TextUtils.setTextStyle(
          fontSize: 13.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(
          height: 10.h), // Same spacing as other items for perfect alignment
      Container(
        width:
            40.w, // Slightly larger than before to match screenshot prominence
        height: 40.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseColor, baseColor.withBlue(180)],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: baseColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
