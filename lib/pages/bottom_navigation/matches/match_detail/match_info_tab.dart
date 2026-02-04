import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/matchdetail/fixtureEvents/events/bloc/fixtureevent_bloc.dart';
import '../../../../application/matchdetail/fixtureEvents/events/bloc/fixtureevent_event.dart';
import '../../../../application/matchdetail/fixtureEvents/events/bloc/fixtureevent_state.dart';
import '../../../../application/matchdetail/matchStatistics/match_statistics_bloc.dart';
import '../../../../application/matchdetail/matchStatistics/match_statistics_event.dart';
import '../../../../application/matchdetail/matchStatistics/match_statistics_state.dart';
import '../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_bloc.dart';
import '../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_event.dart';
import '../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_state.dart';
import '../../../../components/getAmharicDay.dart';
import '../../../../localization/demo_localization.dart';
import '../../../../widgets/match_detail/homeandawayTeamScore.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
import '../../Tv/highlight/highlight-special-card.dart';

class MatchInfoTab extends StatefulWidget {
  const MatchInfoTab({
    super.key,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.venue,
    required this.referee,
    required this.city,
    required this.homeTeamGoal,
    required this.awayTeamGoal,
    required this.fixtureId,
    required this.status,
    required this.awayTeamLogo,
    required this.homeTeamLogo,
    required this.awayTeamName,
    required this.homeTeamName,
    required this.matchDate,
    required this.matchTime,
    required this.displayLeagueName, // ← NEW: the one from previous page
    required this.round,
    required this.leagueLogo,
    this.VideoId,
  });

  final int homeTeamId;
  final int awayTeamId;
  final String? venue;
  final String? referee;
  final String? city;
  final int? homeTeamGoal;
  final int? awayTeamGoal;
  final int? fixtureId;
  final String? status;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? matchDate;
  final String? matchTime;
  final String displayLeagueName;
  final String? round;
  final String? leagueLogo;
  final String? VideoId;

  @override
  State<MatchInfoTab> createState() => _MatchInfoTabState();
}

class _MatchInfoTabState extends State<MatchInfoTab> {
  late LastFiveMatchesBloc _homeTeamBloc;
  late LastFiveMatchesBloc _awayTeamBloc;
  @override
  void initState() {
    super.initState();
    // Initialize separate blocs for each team
    _homeTeamBloc = LastFiveMatchesBloc();
    _awayTeamBloc = LastFiveMatchesBloc();
    // Load recent form only if match is not started
    if (widget.status == 'NS') {
      _homeTeamBloc.add(LastFiveMatchesRequested(
        teamId: widget.homeTeamId.toString(),
      ));
      _awayTeamBloc.add(LastFiveMatchesRequested(
        teamId: widget.awayTeamId.toString(),
      ));
    }
    // Load match events
    if (context.read<FixtureeventBloc>().state.status !=
        EventStatus.requestInProgress) {
      context
          .read<FixtureeventBloc>()
          .add(FixtureEventsRequested(fixtureId: widget.fixtureId));
    }

    // Load match statistics
    if (context.read<MatchStatisticsBloc>().state.status !=
        matchesStatsStatus.requestInProgess) {
      context
          .read<MatchStatisticsBloc>()
          .add(MatchStatisticsRequested(fixtureId: widget.fixtureId));
    }
  }

  @override
  void dispose() {
    _homeTeamBloc.close();
    _awayTeamBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildMatchDetails(context),
          _buildLeagueRoundBox(context),
          // VIDEO HIGHLIGHTS SECTION - Show if VideoId is not null
          if (widget.VideoId != null && widget.VideoId!.isNotEmpty) ...[
            _buildVideoHighlightsSection(),
            SizedBox(height: 8.h),
          ],
          // RECENT FORM SECTION - Only show for NS (Not Started) matches
          if (widget.status == 'NS') ...[
            _buildRecentFormSection(),
            SizedBox(height: 8.h),
          ],

          _buildQuickStats(context),
          _buildMatchEventsSection(context),
          _buildEventMeanings(context),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildVideoHighlightsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.video_library_rounded,
                  color: Colorscontainer.greenColor,
                  size: 20.sp,
                ),
                SizedBox(width: 18.w),
                Text(
                  DemoLocalizations.highlight ?? 'Match Highlights',
                  style: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          HighlightSpecialCard(
            videoUrl: widget.VideoId,
            description:
                '${widget.homeTeamName} ${widget.homeTeamGoal} - ${widget.awayTeamGoal} ${widget.awayTeamName}',
          ),
        ],
      ),
    );
  }

// ==================== RECENT FORM SECTION ====================
  Widget _buildRecentFormSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.chart_bar_square,
                    color: Colorscontainer.greenColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    DemoLocalizations.last5Games ?? 'Recent Form',
                    style: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Home Team Form
              BlocProvider.value(
                value: _homeTeamBloc,
                child: _buildTeamForm(
                  teamId: widget.homeTeamId.toString(),
                  teamName: widget.homeTeamName ?? '',
                  teamLogo: widget.homeTeamLogo ?? '',
                ),
              ),

              SizedBox(height: 16.h),

              // Away Team Form
              BlocProvider.value(
                value: _awayTeamBloc,
                child: _buildTeamForm(
                  teamId: widget.awayTeamId.toString(),
                  teamName: widget.awayTeamName ?? '',
                  teamLogo: widget.awayTeamLogo ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamForm({
    required String teamId,
    required String teamName,
    required String teamLogo,
  }) {
    return BlocBuilder<LastFiveMatchesBloc, LastFiveMatchesState>(
      builder: (context, state) {
        if (state.status != fiveMatchesStatus.requestSuccess) {
          return Container(
            height: 80.h,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          );
        }

        final matchesByLeague = state.matchesByLeague;
        if (matchesByLeague.isEmpty) return const SizedBox.shrink();

        // Combine all matches from all leagues
        List<dynamic> allMatches = [];
        for (var league in matchesByLeague) {
          allMatches.addAll(league.matches);
        }

        // Take only last 5 matches
        final last5Matches = allMatches.take(5).toList();
        if (last5Matches.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CachedNetworkImage(
  height: 24.h,
  width: 24.w,
  imageUrl: teamLogo,
  fit: BoxFit.contain,
  errorWidget: (context, url, error) => CachedNetworkImage(
    imageUrl: "https://media.api-sports.io/football/teams/${teamId}.png",
    height: 24.h,
    width: 24.w,
    fit: BoxFit.contain,
    // Final fallback to the Icon
    errorWidget: (_, __, ___) => Icon(
      Icons.shield,
      size: 24.sp,
      color: Colors.grey,
    ),
  ),
),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    teamName,
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 90.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: last5Matches.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final match = last5Matches[index];
                  final bool isHome = match.homeTeamId == teamId;

                  final int scored =
                      isHome ? (match.scoreHome ?? 0) : (match.scoreAway ?? 0);
                  final int conceded =
                      isHome ? (match.scoreAway ?? 0) : (match.scoreHome ?? 0);

                  final String myTeamLogo = isHome
                      ? (match.homeTeamLogo.isNotEmpty
                          ? match.homeTeamLogo
                          : 'https://media.api-sports.io/football/teams/$teamId.png')
                      : (match.awayTeamLogo.isNotEmpty
                          ? match.awayTeamLogo
                          : 'https://media.api-sports.io/football/teams/$teamId.png');

                  final String opponentId =
                      isHome ? match.awayTeamId : match.homeTeamId;

                  final String opponentLogo = isHome
                      ? (match.awayTeamLogo.isNotEmpty
                          ? match.awayTeamLogo
                          : 'https://media.api-sports.io/football/teams/$opponentId.png')
                      : (match.homeTeamLogo.isNotEmpty
                          ? match.homeTeamLogo
                          : 'https://media.api-sports.io/football/teams/$opponentId.png');

                  return _buildFormItem(
                    context,
                    scored,
                    conceded,
                    myTeamLogo,
                    opponentLogo,
                    isHome,
                    teamId,
                    opponentId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormItem(
    BuildContext context,
    int scored,
    int conceded,
    String myTeamLogo,
    String opponentLogo,
    bool isHome,
    String myTeamId,
    String opponentId,
  ) {
    Color resultColor;
    if (scored > conceded) {
      resultColor = Colors.green;
    } else if (scored < conceded) {
      resultColor = Colors.red;
    } else {
      resultColor = Colors.grey;
    }

    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$scored - $conceded',
              style: TextUtils.setTextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                height: 24.h,
                width: 24.w,
                imageUrl: myTeamLogo,
                placeholder: (_, __) =>
                    const Icon(Icons.shield, color: Colors.grey, size: 20),
                errorWidget: (_, __, ___) => Image.network(
                  'https://media.api-sports.io/football/teams/$myTeamId.png',
                  height: 24.h,
                  width: 24.w,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shield,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              CachedNetworkImage(
                height: 24.h,
                width: 24.w,
                imageUrl: opponentLogo,
                placeholder: (_, __) =>
                    const Icon(Icons.shield, color: Colors.grey, size: 20),
                errorWidget: (_, __, ___) => Image.network(
                  'https://media.api-sports.io/football/teams/$opponentId.png',
                  height: 24.h,
                  width: 24.w,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shield,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVenueWithCity() {
    final venue = widget.venue?.trim();
    final city = widget.city?.trim();

    if (venue == null || venue.isEmpty) return '';

    if (city == null || city.isEmpty) {
      return venue; // Only venue if no city
    }

    // Avoid duplication if city is already in venue name
    if (venue.toLowerCase().contains(city.toLowerCase())) {
      return venue;
    }

    return '$venue, $city';
  }

  // Match Details (Referee, Venue, Date, Time)
  Widget _buildMatchDetails(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                // Referee
                if (widget.referee?.isNotEmpty ?? false) ...[
                  _buildDetailRow(CupertinoIcons.person_crop_circle,
                      DemoLocalizations.judge, widget.referee!),
                  // Only add divider if there's something below
                  if (_hasMoreDetailsAfterReferee())
                    Divider(height: 16.h, color: Colors.white12),
                ],

                // Venue with City
                if (widget.venue?.isNotEmpty ?? false) ...[
                  _buildDetailRow(
                    CupertinoIcons.sportscourt,
                    DemoLocalizations.field,
                    _formatVenueWithCity(),
                  ),
                  // Only add divider if date or time is shown
                  if (widget.matchDate?.isNotEmpty == true ||
                      widget.matchTime?.isNotEmpty == true)
                    Divider(height: 16.h, color: Colors.white12),
                ],

                // Date
                if (widget.matchDate?.isNotEmpty == true) ...[
                  _buildDetailRow(CupertinoIcons.calendar,
                      DemoLocalizations.day, widget.matchDate!),
                  // Only add divider if time is also shown
                  if (widget.matchTime?.isNotEmpty == true)
                    Divider(height: 16.h, color: Colors.white12),
                ],

                // Time (last one — no divider needed after)
                if (widget.matchTime?.isNotEmpty == true)
                  _buildDetailRow(CupertinoIcons.clock, DemoLocalizations.hours,
                      widget.matchTime!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueRoundBox(BuildContext context) {
    if (widget
            .displayLeagueName // ← Pass the one from previous page
            ?.isNotEmpty !=
        true) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5),
          child: Row(
            children: [
              // League logo with fallback
              SizedBox(
                child: widget.leagueLogo?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: widget.leagueLogo!,
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.shield,
                            color: Colorscontainer.greenColor,
                            size: 24.w,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            CupertinoIcons.shield,
                            color: Colorscontainer.greenColor,
                            size: 28.w,
                          ),
                        ),
                      )
                    : Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.shield,
                          color: Colorscontainer.greenColor,
                          size: 28.w,
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // League name
                    Text(
                      widget
                          .displayLeagueName!, // ← Pass the one from previous page
                      style: TextUtils.setTextStyle(
                        fontSize: 16.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Translated round — already handled by replaceText()
                    if (widget.round?.isNotEmpty ?? false) ...[
                      SizedBox(height: 6.h),
                      Text(
                        widget.round!, // ← Already translated!
                        style: TextUtils.setTextStyle(
                          color: Colorscontainer.greenColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    String displayValue = value;
    if (label == DemoLocalizations.day && value.isNotEmpty) {
      displayValue = getAmharicMonthName(value);
    }

    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 22.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextUtils.setTextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                displayValue,
                style: TextUtils.setTextStyle(
                  color: Colorscontainer.greenColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
                maxLines: 1, // ← Limit to 3 lines max
                overflow: TextOverflow.ellipsis, // ← Add "..." if too long
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Quick Stats (Ball Possession & Shots)
  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<MatchStatisticsBloc, MatchStatisticsState>(
      builder: (context, state) {
        String possession = '-';
        String homeShots = '-';
        String awayShots = '-';

        if (state.status == matchesStatsStatus.requestSuccessed &&
            state.teamsMatchStat != null) {
          try {
            final homePossession =
                state.teamsMatchStat?.teamOneMatchStatistics.ballPossession ??
                    '-';
            final awayPossession =
                state.teamsMatchStat?.teamTwoMatchStatistics.ballPossession ??
                    '-';
            possession = '$homePossession - $awayPossession';

            final homeTeamStats =
                state.teamsMatchStat?.teamOneMatchStatistics.totalShots ?? 0;
            final awayTeamStats =
                state.teamsMatchStat?.teamTwoMatchStatistics.totalShots ?? 0;
            homeShots = homeTeamStats.toString();
            awayShots = awayTeamStats.toString();
          } catch (e) {
            // ignore
          }
        }

        List<Widget> quickStatWidgets = [];

        if (possession != '-') {
          quickStatWidgets.add(_buildQuickStat(
            label: DemoLocalizations.ballPossession,
            value: possession,
            showLogos: true,
          ));
        }

        if (homeShots != '-' && awayShots != '-') {
          if (quickStatWidgets.isNotEmpty)
            quickStatWidgets.add(_buildVerticalDivider());
          quickStatWidgets.add(_buildQuickStat(
            label: DemoLocalizations.shots,
            value: '$homeShots - $awayShots',
            showLogos: true,
          ));
        }

        if (quickStatWidgets.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: quickStatWidgets,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: Colors.grey,
    );
  }

  Widget _buildQuickStat({
    required String label,
    required String value,
    bool showLogos = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextUtils.setTextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 12.h),
          if (showLogos) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home team logo
                if (widget.homeTeamLogo != null)
                  ClipOval(
                    child: Image.network(
                      widget.homeTeamLogo!,
                      width: 18.w,
                      height: 18.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.sports_soccer, size: 24.w),
                    ),
                  ),
                SizedBox(width: 8.w),
                Text(
                  value,
                  style: TextUtils.setTextStyle(
                    color: Colorscontainer.greenColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                // Away team logo
                if (widget.awayTeamLogo != null)
                  ClipOval(
                    child: Image.network(
                      widget.awayTeamLogo!,
                      width: 18.w,
                      height: 18.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.sports_soccer, size: 24.w),
                    ),
                  ),
              ],
            ),
          ] else
            Text(
              value,
              style: TextUtils.setTextStyle(
                color: Colorscontainer.greenColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchEventsSection(BuildContext context) {
    if (widget.status == 'NS') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5),
          child: _buildMatchEvents(context),
        ),
      ),
    );
  }

  Widget _buildMatchEvents(BuildContext context) {
    return BlocBuilder<FixtureeventBloc, FixtureEventState>(
      builder: (context, state) {
        if (state.status == EventStatus.requestInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == EventStatus.requestSuccess &&
            state.events.isNotEmpty) {
          final events = state.events;

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                /// 1. THE VERTICAL LINE
                /// Adjust 'top' to start after the score (around 85h)
                /// and 'bottom' to end at the bottom text (around 40h)
                Positioned(
                  top: 85.h,
                  bottom: 40.h,
                  child: Container(
                    width: 2.w,
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),

                /// 2. THE CONTENT LAYER
                Column(
                  children: [
                    // Team logos + current score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.homeTeamLogo != null)
                          ClipOval(
                            child: Image.network(
                              widget.homeTeamLogo!,
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.sports_soccer, size: 40.w),
                            ),
                          ),
                        SizedBox(width: 36.w),
                        Text(
                          '${widget.homeTeamGoal ?? 0} - ${widget.awayTeamGoal ?? 0}',
                          style: TextUtils.setTextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 36.w),
                        if (widget.awayTeamLogo != null)
                          ClipOval(
                            child: Image.network(
                              widget.awayTeamLogo!,
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.sports_soccer, size: 40.w),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // TOP TEXT: 90' End (only shown if Full Time)
                    if (widget.status == 'FT')
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          color: Theme.of(context)
                              .scaffoldBackgroundColor, // Masks the line
                          child: Text(
                            DemoLocalizations.minutes90End,
                            style: TextUtils.setTextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),

                    // Events List
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            // Use slightly opaque color so the line is subtly visible or hidden
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: event.team.id == widget.homeTeamId
                              ? HomeTeamEvent(
                                  mainPlayer: event.player,
                                  extra: event.time.extra,
                                  assistPlayer: event.assist,
                                  detail: event.detail ?? '',
                                  minutes: event.time.elapsed,
                                  type: event.type,
                                  comments: event.comments,
                                )
                              : AwayTeamEvent(
                                  mainPlayer: event.player,
                                  extra: event.time.extra,
                                  assistPlayer: event.assist,
                                  detail: event.detail ?? '',
                                  minutes: event.time.elapsed,
                                  type: event.type,
                                  comments: event.comments,
                                ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // BOTTOM TEXT: Match Started 00:00
                    if (widget.status == 'FT' || widget.status == 'LIVE')
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          color: Theme.of(context)
                              .scaffoldBackgroundColor, // Masks the line
                          child: Text(
                            '${DemoLocalizations.matchStarted} 00:00 ${DemoLocalizations.minutes}',
                            style: TextUtils.setTextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Event Legend (Goal, Cards, Sub, etc.)
  Widget _buildEventMeanings(BuildContext context) {
    return BlocBuilder<FixtureeventBloc, FixtureEventState>(
      builder: (context, state) {
        if (state.status != EventStatus.requestSuccess ||
            state.events.isEmpty) {
          return const SizedBox.shrink();
        }

        final events = state.events;
        final hasGoal = events.any((e) => e.type == 'Goal');
        final hasMissedPenalty =
            events.any((e) => e.detail == 'Missed Penalty');
        final hasYellowCard =
            events.any((e) => e.type == 'Card' && e.detail == 'Yellow Card');
        final hasRedCard =
            events.any((e) => e.type == 'Card' && e.detail == 'Red Card');
        final hasVAR = events.any((e) => e.type == 'Var');
        final hasPenalty = events.any((e) => e.detail == 'Penalty');
        final hasSubstitution = events.any((e) => e.type == 'subst');
        final hasAssist = events.any((e) => e.assist != null);

        if (!hasGoal &&
            !hasMissedPenalty &&
            !hasYellowCard &&
            !hasRedCard &&
            !hasVAR &&
            !hasPenalty &&
            !hasSubstitution &&
            !hasAssist) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Wrap(
            spacing: 16.w,
            runSpacing: 12.h,
            children: [
              if (hasGoal)
                _buildEventMeaningItem(
                    'assets/ball.png', DemoLocalizations.goal),
              if (hasMissedPenalty)
                _buildEventMeaningItem('assets/missedPenality.png',
                    DemoLocalizations.penalty_missed),
              if (hasYellowCard)
                _buildEventMeaningItem(
                    'assets/yellow_card.png', DemoLocalizations.yellowCard),
              if (hasPenalty)
                _buildEventMeaningItem(
                    'assets/penality.png', DemoLocalizations.penality),
              if (hasRedCard)
                _buildEventMeaningItem(
                    'assets/red_card.png', DemoLocalizations.redCard),
              if (hasVAR)
                _buildEventMeaningItem(
                    'assets/var.png', DemoLocalizations.varEvent),
              if (hasSubstitution)
                _buildEventMeaningItem('assets/substitute.png',
                    DemoLocalizations.substitutionPlayers),
              if (hasAssist)
                _buildEventMeaningItem(
                    'assets/chama.png', DemoLocalizations.topAssist),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventMeaningItem(String iconPath, String meaning) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Special handling only for the ball icon
    if (iconPath == 'assets/ball.png') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDark
                  ? Colors.white
                  : Colors.black87, // white in dark, black in light
              BlendMode.srcIn,
            ),
            child: Image.asset(
              iconPath,
              width: 20.w,
              height: 20.w,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              meaning,
              style: TextUtils.setTextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      );
    }

    // All other icons (yellow card, red card, etc.) remain unchanged
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconPath, width: 20.w, height: 20.w),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            meaning,
            style: TextUtils.setTextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  // ADD THIS METHOD HERE
  bool _hasMoreDetailsAfterReferee() {
    return (widget.venue?.isNotEmpty ?? false) ||
        (widget.matchDate?.isNotEmpty == true) ||
        (widget.matchTime?.isNotEmpty == true);
  }
} // ← End of class
