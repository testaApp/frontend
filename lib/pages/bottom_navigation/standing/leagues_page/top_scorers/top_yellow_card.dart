import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/leagues_page/top_yellow_card/top_yellow_bloc.dart';
import '../../../../../bloc/leagues_page/top_yellow_card/top_yellow_event.dart';
import '../../../../../bloc/leagues_page/top_yellow_card/top_yellow_state.dart';
import '../../../../leagues_page/list_maker.dart';

class TopYellowCardView extends StatefulWidget {
  final int leagueId;
  final String logo;

  const TopYellowCardView(
      {super.key, required this.leagueId, required this.logo});

  @override
  State<TopYellowCardView> createState() => _TopYellowCardViewState();
}

class _TopYellowCardViewState extends State<TopYellowCardView> {
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

    context.read<TopYellowCardsBloc>().add(TopYellowCardsRequested(
        leagueId: widget.leagueId, season: int.parse(seasonStr)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopYellowCardsBloc, TopYellowCardsState>(
      builder: (context, state) {
        if (state.status == CardScorerStatus.requestSuccessed &&
            state.topYellowCards.isNotEmpty) {
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
                    topScorers: state.topYellowCards,
                    leagueId: widget.leagueId,
                    logo: widget.logo,
                    type: 'yellow',
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
