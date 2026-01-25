import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../bloc/standings/bloc/content_bloc.dart';
import '../../../../../../bloc/standings/bloc/content_state.dart';
import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/availableSeasons/available_seasons_event.dart';
import '../../../../../bloc/availableSeasons/available_seasons_state.dart';
import '../../../../../bloc/standings/bloc/content_event.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';

class LeagueStandingsSection extends StatefulWidget {
  const LeagueStandingsSection({super.key});

  @override
  _LeagueStandingsSectionState createState() => _LeagueStandingsSectionState();
}

class _LeagueStandingsSectionState extends State<LeagueStandingsSection> {
  final PageController _standingsPageController = PageController();
  int _currentStandingsPage = 0;

  @override
  void initState() {
    super.initState();
    // Request available seasons for initial league (Premier League)
    const initialLeagueId = 39;
    print('📱 Initializing standings with League ID: $initialLeagueId');
    context
        .read<AvailableSeasonsBloc>()
        .add(AvailableSeasonsRequested(leagueId: initialLeagueId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for seasons response
        BlocListener<AvailableSeasonsBloc, AvailableSeasonsState>(
          listener: (context, seasonsState) {
            if (seasonsState.status ==
                AvailableSeasonsStatus.requestSuccessed) {
              print('🔄 Seasons loaded for league');
              print('📅 Available Seasons: ${seasonsState.seasons}');

              // Get the second most recent season if current season is not available
              final selectedSeason = seasonsState.currentSeason != null &&
                      seasonsState.seasons.contains(seasonsState.currentSeason)
                  ? seasonsState.currentSeason
                  : seasonsState.seasons.length > 1
                      ? seasonsState.seasons[1]
                      : seasonsState.seasons.first;

              print('📌 Selected Season: $selectedSeason');

              // Now that we have seasons, request standings
              int leagueId = _currentStandingsPage == 0
                  ? 39
                  : (_currentStandingsPage == 1 ? 2 : 363);

              context.read<ContentBloc>().add(
                    StandingRequested(
                      leagueId: leagueId,
                      season: selectedSeason,
                    ),
                  );
            }
          },
        ),
      ],
      child: BlocBuilder<AvailableSeasonsBloc, AvailableSeasonsState>(
        builder: (context, seasonsState) {
          return BlocBuilder<ContentBloc, ContentState>(
            builder: (context, standingsState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildStandingsPageView(standingsState),
                  _buildPageIndicator(),
                  SizedBox(height: 16.h),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Simplified to only handle page change and request seasons
  void _handlePageChange(int index) {
    setState(() {
      _currentStandingsPage = index;
    });

    int leagueId = index == 0 ? 39 : (index == 1 ? 2 : 363);
    print('📱 Switching to League ID: $leagueId');

    // Only request seasons - standings will be requested after seasons load
    context
        .read<AvailableSeasonsBloc>()
        .add(AvailableSeasonsRequested(leagueId: leagueId));
  }

  Widget _buildStandingsPageView(ContentState state) {
    return SizedBox(
      height: 200.h,
      child: PageView(
        controller: _standingsPageController,
        onPageChanged: _handlePageChange,
        children: [
          StandingsPage(
            state: state,
            leagueId: 39,
            leagueName: DemoLocalizations.premierLeagueShort,
            onRetry: () {
              // First request seasons again
              context
                  .read<AvailableSeasonsBloc>()
                  .add(AvailableSeasonsRequested(leagueId: 39));
            },
          ),
          StandingsPage(
            state: state,
            leagueId: 2,
            leagueName: DemoLocalizations.championsLeagueShort,
            onRetry: () {
              // First request seasons again
              context
                  .read<AvailableSeasonsBloc>()
                  .add(AvailableSeasonsRequested(leagueId: 2));
            },
          ),
          StandingsPage(
            state: state,
            leagueId: 363,
            leagueName: DemoLocalizations.ethiopianPremierLeagueShort,
            onRetry: () {
              // First request seasons again
              context
                  .read<AvailableSeasonsBloc>()
                  .add(AvailableSeasonsRequested(leagueId: 363));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 16.sp,
            color: Colors.grey[700],
          ),
          SizedBox(width: 4.w),
          Text(
            DemoLocalizations.table,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              color: Colors.grey[700],
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentStandingsPage
                  ? Colorscontainer.greenColor
                  : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}

class StandingsPage extends StatelessWidget {
  final ContentState state;
  final int leagueId;
  final String leagueName;
  final VoidCallback onRetry;

  const StandingsPage({
    super.key,
    required this.state,
    required this.leagueId,
    required this.leagueName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (state.nestedList.isEmpty ||
        state.status == ContentStatus.requestInProgress) {
      return const StandingsLoadingState();
    }

    final standings = state.nestedList['overall']?.firstOrNull;
    if (standings == null || standings.isEmpty) {
      return StandingsErrorState(
        onRetry: onRetry,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLeagueHeader(isDarkMode),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          StandingsTableHeader(isDarkMode: isDarkMode),
          Expanded(
            child: ListView(
              children: standings
                  .take(6)
                  .map((team) => StandingsTableRow(
                        team: team,
                        isDarkMode: isDarkMode,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueHeader(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://media.api-sports.io/football/leagues/$leagueId.png',
            width: 24.w,
            height: 24.w,
            placeholder: (context, url) => SizedBox(
              width: 24.w,
              height: 24.w,
            ),
            errorWidget: (context, url, error) => SizedBox(
              width: 24.w,
              height: 24.w,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            leagueName,
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class StandingsTableHeader extends StatelessWidget {
  final bool isDarkMode;

  const StandingsTableHeader({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '#',
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              DemoLocalizations.team,
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              DemoLocalizations.played,
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              DemoLocalizations.goal,
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              DemoLocalizations.point,
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StandingsTableRow extends StatelessWidget {
  final dynamic team;
  final bool isDarkMode;

  const StandingsTableRow({
    super.key,
    required this.team,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              team.position.toString(),
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: team.position <= 4
                    ? Colorscontainer.greenColor
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: team.avatar,
                  width: 16.w,
                  height: 16.w,
                  placeholder: (context, url) => SizedBox(
                    width: 16.w,
                    height: 16.w,
                  ),
                  errorWidget: (context, url, error) => SizedBox(
                    width: 16.w,
                    height: 16.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    team.name,
                    style: TextUtils.setTextStyle(
                      fontSize: 10.sp,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              team.gamePlayed.toString(),
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              team.goalDifference.toString(),
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 30.w,
            child: Text(
              team.point.toString(),
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StandingsLoadingState extends StatelessWidget {
  const StandingsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Colorscontainer.greenColor,
      ),
    );
  }
}

class StandingsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const StandingsErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load standings',
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextUtils.setTextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
