import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/state/bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_event.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/favourites_page/teams/teamstas/teamProfileStat.dart';
import 'package:blogapp/models/leagueNames.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class TeamStatisticsPage extends StatefulWidget {
  final int teamId;

  const TeamStatisticsPage({Key? key, required this.teamId}) : super(key: key);

  @override
  State<TeamStatisticsPage> createState() => _TeamStatisticsPageState();
}

class _TeamStatisticsPageState extends State<TeamStatisticsPage> {
  LeagueName? _selectedLeague;

  String _getLocalizedLeagueName(LeagueName league) {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' || 'tr' => league.amharicName ?? league.englishName ?? '',
      'om' => league.oromoName ?? league.englishName ?? '',
      'so' => league.somaliName ?? league.englishName ?? '',
      _ => league.englishName ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final valueTextColor = colorScheme.onSurface;

    return BlocProvider(
      create: (_) => TeamProfileStatisticsBloc()
        ..add(TeamProfileStatisticsRequested(teamId: widget.teamId)),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body:
            BlocBuilder<TeamProfileStatisticsBloc, TeamProfileStatisticsState>(
          builder: (context, state) {
            if (state.status == teamProfileStatus.requested) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == teamProfileStatus.failure ||
                state.status == teamProfileStatus.networkFailed) {
              return Center(
                child: Text(
                  DemoLocalizations.networkProblem,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (state.teamStats.isEmpty) {
              return Center(
                child: Text(
                  DemoLocalizations.informationNotFound,
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            // Get unique leagues from the stats
            final availableLeagues = state.teamStats
                .where((stat) => stat.league != null)
                .map((stat) => stat.league!)
                .toList();

            // Set initial selected league if not set
            if (_selectedLeague == null && availableLeagues.isNotEmpty) {
              _selectedLeague = availableLeagues.first;
            }

            // Get stats for selected league
            final stats = _selectedLeague != null
                ? state.teamStats.firstWhere(
                    (stat) =>
                        stat.league?.leagueId == _selectedLeague?.leagueId,
                    orElse: () => state.teamStats.first,
                  )
                : state.teamStats.first;

            return Column(
              children: [
                // League Selector Dropdown
                if (availableLeagues.length > 1)
                  _buildLeagueDropdown(
                    availableLeagues,
                    colorScheme,
                    isDark,
                  ),

                // Scrollable Stats Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                            title: DemoLocalizations.goalsScored,
                            icon: Icons.sports_soccer,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildGoalsSection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title: DemoLocalizations.cleanSheet,
                            icon: Icons.cleaning_services,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildCleanSheetSection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title: DemoLocalizations.longestStreak,
                            icon: Icons.trending_up,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildBiggestSection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title: DemoLocalizations.penaltiesTaken,
                            icon: Icons.sports_handball,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildPenaltySection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title: DemoLocalizations.mostUsedFormation,
                            icon: Icons.grid_4x4,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildFormationSection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title:
                                "${DemoLocalizations.yellowCard} & ${DemoLocalizations.redCard}",
                            icon: Icons.flag,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildCardsSection(
                                stats, mutedTextColor, valueTextColor),
                            colorScheme: colorScheme),
                        SizedBox(height: 18.h),
                        _buildSectionTitle(
                            title:
                                '${DemoLocalizations.goalsScored} ${DemoLocalizations.byMinute}',
                            icon: Icons.access_time,
                            accentColor: colorScheme.primary),
                        _buildModernCard(
                            child: _buildMinuteBreakdown(
                                stats, colorScheme, isDark),
                            colorScheme: colorScheme),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // NEW: Beautiful Compact League Dropdown
  // Replace the _buildLeagueDropdown method with this PopupMenuButton solution:

  Widget _buildLeagueDropdown(
    List<LeagueName> leagues,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      width: double.infinity,
      child: PopupMenuButton<LeagueName>(
        initialValue: _selectedLeague,
        position: PopupMenuPosition.under, // Always show below
        offset: Offset(0, 4.h),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32.w,
          maxWidth: MediaQuery.of(context).size.width - 32.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        elevation: 8,
        onSelected: (LeagueName newLeague) {
          setState(() {
            _selectedLeague = newLeague;
          });
        },
        itemBuilder: (BuildContext context) {
          return leagues.map((league) {
            return PopupMenuItem<LeagueName>(
              value: league,
              child: Row(
                children: [
                  if (league.logo != null) ...[
                    Container(
                      width: 26.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      padding: EdgeInsets.all(2.w),
                      child: Image.network(
                        league.logo!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.sports_soccer,
                          size: 16.sp,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Expanded(
                    child: Text(
                      _getLocalizedLeagueName(league),
                      overflow: TextOverflow.ellipsis,
                      style: TextUtils.setTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_selectedLeague?.logo != null) ...[
                Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  padding: EdgeInsets.all(2.w),
                  child: Image.network(
                    _selectedLeague!.logo!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.sports_soccer,
                      size: 16.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Text(
                  _selectedLeague != null
                      ? _getLocalizedLeagueName(_selectedLeague!)
                      : 'Select League',
                  style: TextUtils.setTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withOpacity(0.7),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, top: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: accentColor.withOpacity(0.9)),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextUtils.setTextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required Widget child,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: child,
      ),
    );
  }

  Widget _buildStatRow(
      String label, dynamic value, Color labelColor, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextUtils.setTextStyle(fontSize: 14.sp, color: labelColor),
            ),
          ),
          Text(
            value.toString(),
            style: TextUtils.setTextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(
      TeamStats stats, Color labelColor, Color valueColor) {
    return Column(
      children: [
        _buildStatRow(
            "${DemoLocalizations.goalsScored} (${DemoLocalizations.total})",
            stats.goalsFor?.total?.total ?? 0,
            labelColor,
            valueColor),
        _buildStatRow("${DemoLocalizations.home}",
            stats.goalsFor?.total?.home ?? 0, labelColor, valueColor),
        _buildStatRow("${DemoLocalizations.away}",
            stats.goalsFor?.total?.away ?? 0, labelColor, valueColor),
        _buildStatRow(
            "${DemoLocalizations.averageGoals} (${DemoLocalizations.goalsScored})",
            stats.goalsFor?.average?.total ?? "0",
            labelColor,
            valueColor),
        Divider(height: 28.h, color: Colors.grey.withOpacity(0.3)),
        _buildStatRow(
            "${DemoLocalizations.goalsConceded} (${DemoLocalizations.total})",
            stats.goalsAgainst?.total?.total ?? 0,
            labelColor,
            valueColor),
        _buildStatRow("${DemoLocalizations.home}",
            stats.goalsAgainst?.total?.home ?? 0, labelColor, valueColor),
        _buildStatRow("${DemoLocalizations.away}",
            stats.goalsAgainst?.total?.away ?? 0, labelColor, valueColor),
      ],
    );
  }

  Widget _buildCleanSheetSection(
      TeamStats stats, Color labelColor, Color valueColor) {
    return Column(
      children: [
        _buildStatRow(
            "${DemoLocalizations.cleanSheet} (${DemoLocalizations.total})",
            stats.cleanSheetTotal ?? 0,
            labelColor,
            valueColor),
        _buildStatRow("${DemoLocalizations.home}", stats.cleanSheetHome ?? 0,
            labelColor, valueColor),
        _buildStatRow("${DemoLocalizations.away}", stats.cleanSheetAway ?? 0,
            labelColor, valueColor),
        Divider(height: 28.h, color: Colors.grey.withOpacity(0.3)),
        _buildStatRow(
            "${DemoLocalizations.failedToScore} (${DemoLocalizations.total})",
            stats.failedToScoreTotal ?? 0,
            labelColor,
            valueColor),
        _buildStatRow("${DemoLocalizations.home}", stats.failedToScoreHome ?? 0,
            labelColor, valueColor),
        _buildStatRow("${DemoLocalizations.away}", stats.failedToScoreAway ?? 0,
            labelColor, valueColor),
      ],
    );
  }

  Widget _buildBiggestSection(
      TeamStats stats, Color labelColor, Color valueColor) {
    return Column(
      children: [
        _buildStatRow(DemoLocalizations.winStreak,
            stats.biggest?.streak?.wins ?? 0, labelColor, valueColor),
        _buildStatRow(DemoLocalizations.drawStreak,
            stats.biggest?.streak?.draws ?? 0, labelColor, valueColor),
        _buildStatRow(DemoLocalizations.loseStreak,
            stats.biggest?.streak?.loses ?? 0, labelColor, valueColor),
        Divider(height: 28.h, color: Colors.grey.withOpacity(0.3)),
        _buildStatRow(
            "${DemoLocalizations.biggestWin} (${DemoLocalizations.home})",
            stats.biggest?.wins?.home ?? "-",
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.biggestWin} (${DemoLocalizations.away})",
            stats.biggest?.wins?.away ?? "-",
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.biggestLoss} (${DemoLocalizations.home})",
            stats.biggest?.loses?.home ?? "-",
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.biggestLoss} (${DemoLocalizations.away})",
            stats.biggest?.loses?.away ?? "-",
            labelColor,
            valueColor),
      ],
    );
  }

  Widget _buildPenaltySection(
      TeamStats stats, Color labelColor, Color valueColor) {
    return Column(
      children: [
        _buildStatRow(DemoLocalizations.penaltiesTaken,
            stats.penalty?.total ?? 0, labelColor, valueColor),
        _buildStatRow(
            DemoLocalizations.penalty_scored,
            "${stats.penalty?.scored?.total ?? 0} (${stats.penalty?.scored?.percentage ?? '0%'})",
            labelColor,
            valueColor),
        _buildStatRow(
            DemoLocalizations.penalty_missed,
            "${stats.penalty?.missed?.total ?? 0} (${stats.penalty?.missed?.percentage ?? '0%'})",
            labelColor,
            valueColor),
      ],
    );
  }

  Widget _buildFormationSection(
      TeamStats stats, Color labelColor, Color valueColor) {
    final mostUsed = stats.lineups?.isNotEmpty == true
        ? stats.lineups!
            .reduce((a, b) => (a.played ?? 0) > (b.played ?? 0) ? a : b)
        : null;

    return Column(
      children: [
        _buildStatRow(DemoLocalizations.mostUsedFormation,
            mostUsed?.formation ?? "N/A", labelColor, valueColor),
        _buildStatRow(DemoLocalizations.timesPlayed,
            mostUsed?.played?.toString() ?? "0", labelColor, valueColor),
      ],
    );
  }

  Widget _buildCardsSection(
      TeamStats stats, Color labelColor, Color valueColor) {
    return Column(
      children: [
        _buildStatRow(
            "${DemoLocalizations.yellowCard} 0-15'",
            stats.cards?.yellow?.interval0To15?.total ?? 0,
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.yellowCard} 16-30'",
            stats.cards?.yellow?.interval16To30?.total ?? 0,
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.redCard} 0-15'",
            stats.cards?.red?.interval0To15?.total ?? 0,
            labelColor,
            valueColor),
        _buildStatRow(
            "${DemoLocalizations.redCard} 16-30'",
            stats.cards?.red?.interval16To30?.total ?? 0,
            labelColor,
            valueColor),
      ],
    );
  }

  Widget _buildMinuteBreakdown(
      TeamStats stats, ColorScheme colorScheme, bool isDark) {
    final positiveColor = colorScheme.primary.withOpacity(0.8);
    final negativeColor = colorScheme.error.withOpacity(0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DemoLocalizations.goalsScored,
          style: TextUtils.setTextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: positiveColor,
          ),
        ),
        SizedBox(height: 10.h),
        _buildMinuteChips(stats.goalsFor?.minute,
            colorScheme: colorScheme, isPositive: true),
        SizedBox(height: 24.h),
        Text(
          DemoLocalizations.goalsConceded,
          style: TextUtils.setTextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: negativeColor,
          ),
        ),
        SizedBox(height: 10.h),
        _buildMinuteChips(stats.goalsAgainst?.minute,
            colorScheme: colorScheme, isPositive: false),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildMinuteChips(MinuteData? data,
      {required ColorScheme colorScheme, required bool isPositive}) {
    if (data == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          DemoLocalizations.informationNotFound,
          style: TextUtils.setTextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    final intervals = [
      data.interval0To15,
      data.interval16To30,
      data.interval31To45,
      data.interval46To60,
      data.interval61To75,
      data.interval76To90,
      data.interval91To105,
      data.interval106To120,
    ];

    final labels = [
      "0-15",
      "16-30",
      "31-45",
      "46-60",
      "61-75",
      "76-90",
      "91-105",
      "106-120"
    ];

    final chipColor = isPositive ? colorScheme.primary : colorScheme.error;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(intervals.length, (index) {
          final interval = intervals[index];
          final count = interval?.total ?? 0;

          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: count > 0
                    ? chipColor.withOpacity(0.18)
                    : colorScheme.surfaceContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: count > 0
                      ? chipColor.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    labels[index],
                    style: TextUtils.setTextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "$count",
                    style: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: count > 0
                          ? chipColor
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
