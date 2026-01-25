import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/standings/bloc/content_bloc.dart';
import '../../../../../bloc/standings/bloc/content_event.dart';
import '../../../../../bloc/standings/bloc/content_state.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';
import 'fixures_list.dart';

class FixturesView extends StatefulWidget {
  final int leagueId;
  const FixturesView({super.key, required this.leagueId});

  @override
  State<FixturesView> createState() => _FixturesViewState();
}

class _FixturesViewState extends State<FixturesView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? currentSeasonString =
          context.read<AvailableSeasonsBloc>().state.currentSeason;
      int season = currentSeasonString != null
          ? int.tryParse(currentSeasonString) ??
              DateTime.now().year // Fallback to current year
          : DateTime.now().year; // Fallback to current year

      try {
        context.read<ContentBloc>().add(RequestFixtureListByLeagueId(
            leagueId: widget.leagueId, season: season));
      } catch (e) {
        print('❌ Error dispatching event: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentBloc, ContentState>(
      builder: (context, state) {
        print('Current state status: ${state.status}');
        print('Fixture list status: ${state.fixtureListStatus}');

        if (state.status == ContentStatus.requestInProgress) {
          return _buildLoadingView();
        } else if (state.status == ContentStatus.requestFailed) {
          print('❌ Request failed');
          return _buildErrorView();
        } else if (state.fixtureListStatus == ContentStatus.requestSuccessed) {
          final allMatches = [
            ...state.listOfLeagueFixtures.previousMatches,
            ...state.listOfLeagueFixtures.upcomingMatches
          ];

          print('📊 Total matches: ${allMatches.length}');
          print(
              '🏆 Previous matches: ${state.listOfLeagueFixtures.previousMatches.length}');
          print(
              '🎯 Upcoming matches: ${state.listOfLeagueFixtures.upcomingMatches.length}');

          if (allMatches.isEmpty) {
            return Center(
              child: Text(
                DemoLocalizations.error,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }

          return FixturesListForLeagues(
              matchesList: allMatches,
              previousIndex: state.listOfLeagueFixtures.previousMatches.length);
        }

        return _buildLoadingView();
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/chewatawoch.gif',
            height: 130.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 90.h),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/404.gif',
            height: 200.h,
            fit: BoxFit.fitHeight,
            color: Colorscontainer.greenColor,
            width: 300.w,
          ),
          Text(
            DemoLocalizations.networkProblem,
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
              fontSize: 15.sp,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Retry fetching data
              String? currentSeasonString =
                  context.read<AvailableSeasonsBloc>().state.currentSeason;
              int season = currentSeasonString != null
                  ? int.tryParse(currentSeasonString) ?? DateTime.now().year
                  : DateTime.now().year;

              context.read<ContentBloc>().add(RequestFixtureListByLeagueId(
                  leagueId: widget.leagueId, season: season));
            },
            child: Text(DemoLocalizations.tryAgain),
          ),
        ],
      ),
    );
  }
}
