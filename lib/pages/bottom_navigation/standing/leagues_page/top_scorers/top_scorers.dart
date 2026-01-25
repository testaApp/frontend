import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/leagues_page/top_scorer/top_scorers_bloc.dart';
import '../../../../../bloc/leagues_page/top_scorer/top_scorers_event.dart';
import '../../../../../bloc/leagues_page/top_scorer/top_scorers_state.dart';
import '../../../../leagues_page/list_maker.dart';
import '../../top_teams_shimmer/Top_teams_shimmer.dart';

class TopScorersView extends StatefulWidget {
  final int leagueId;
  final String logo;

  const TopScorersView({super.key, required this.leagueId, required this.logo});

  @override
  State<TopScorersView> createState() => _TopScorersViewState();
}

class _TopScorersViewState extends State<TopScorersView> {
  @override
  initState() {
    final availableSeasonsState = context.read<AvailableSeasonsBloc>().state;

    // Get the current season or fallback to the first available season
    final season = availableSeasonsState.currentSeason != null &&
            availableSeasonsState.seasons
                .contains(availableSeasonsState.currentSeason)
        ? availableSeasonsState.currentSeason
        : availableSeasonsState.seasons.isNotEmpty
            ? availableSeasonsState.seasons.first
            : '2024'; // Default fallback

    context
        .read<TopScorersBloc>()
        .add(TopScorersRequested(leagueId: widget.leagueId, season: season));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopScorersBloc, TopScorersState>(
      builder: (context, state) {
        if (state.status == ScorerStatus.requestSuccessed &&
            state.topScorers.isNotEmpty) {
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
                  ListMaker(
                    topScorers: state.topScorers,
                    leagueId: widget.leagueId,
                    logo: widget.logo,
                    type: 'goals',
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == ScorerStatus.requestInProgress) {
          return const ShimmerScorerList();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
