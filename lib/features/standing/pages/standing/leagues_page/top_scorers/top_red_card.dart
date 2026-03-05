import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:blogapp/state/bloc/availableSeasons/available_seasons_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_red/top_red_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_red/top_red_event.dart';
import 'package:blogapp/state/bloc/leagues_page/top_red/top_red_state.dart';
import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/features/leagues/pages/list_maker.dart';
import 'package:blogapp/features/standing/pages/standing/top_teams_shimmer/Top_teams_shimmer.dart';

class TopRedCardView extends StatefulWidget {
  final int leagueId;
  final String logo;

  const TopRedCardView({super.key, required this.leagueId, required this.logo});

  @override
  State<TopRedCardView> createState() => _TopRedCardViewState();
}

class _TopRedCardViewState extends State<TopRedCardView> {
  @override
  initState() {
    final availableSeasonsState = context.read<AvailableSeasonsBloc>().state;

    // Get the current season or fallback to the first available season
    final String seasonStr = availableSeasonsState.currentSeason != null &&
            availableSeasonsState.seasons
                .contains(availableSeasonsState.currentSeason)
        ? availableSeasonsState.currentSeason!
        : availableSeasonsState.seasons.isNotEmpty
            ? availableSeasonsState.seasons.first
            : '2024'; // Default fallback

    context.read<TopRedCardsBloc>().add(TopRedRequested(
          leagueId: widget.leagueId,
          season: seasonStr,
        ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopRedCardsBloc, TopRedState>(
      builder: (context, state) {
        if (state.status == RedStatus.requestSuccessed &&
            state.topRed.isNotEmpty) {
          return Column(
            children: [
              buildHeader(context),
              buildContentContainer(
                context,
                ListMaker(
                  topScorers: state.topRed,
                  leagueId: widget.leagueId,
                  logo: widget.logo,
                  type: 'red',
                ),
              ),
            ],
          );
        } else if (state.status == RedStatus.requestInProgress) {
          return const ShimmerScorerList();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, bottom: 5.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            context.pushNamed(RouteNames.playerStat, extra: {
              'leagueId': widget.leagueId.toString(),
              'logo': widget.logo,
              'type': 'red',
            });
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
        ),
      ),
    );
  }

  Widget buildContentContainer(BuildContext context, Widget child) {
    return ClipRRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            child,
          ],
        ),
      ),
    );
  }
}
