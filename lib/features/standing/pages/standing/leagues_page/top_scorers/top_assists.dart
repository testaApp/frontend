import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/state/bloc/availableSeasons/available_seasons_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_assist/top_assist_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_assist/top_assist_state.dart';
import 'package:blogapp/state/bloc/leagues_page/top_assist/top_assist_event.dart';
import 'package:blogapp/features/leagues/pages/list_maker.dart';
import 'package:blogapp/features/standing/pages/standing/top_teams_shimmer/Top_teams_shimmer.dart';

class TopAssistorsView extends StatefulWidget {
  final int leagueId;
  final String logo;

  const TopAssistorsView({
    super.key,
    required this.leagueId,
    required this.logo,
  });

  @override
  State<TopAssistorsView> createState() => _TopAssistorsViewState();
}

class _TopAssistorsViewState extends State<TopAssistorsView> {
  @override
  initState() {
    final currentSeason =
        context.read<AvailableSeasonsBloc>().state.currentSeason;

    context.read<TopAssistorsBloc>().add(
        TopAssistRequested(leagueId: widget.leagueId, season: currentSeason));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopAssistorsBloc, TopAssistState>(
      builder: (context, state) {
        if (state.status == AssistStatus.requestSuccessed &&
            state.topAssistors.isNotEmpty) {
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
                    topScorers: state.topAssistors,
                    leagueId: widget.leagueId,
                    logo: widget.logo,
                    type: 'assists',
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == AssistStatus.requestInProgress) {
          return const ShimmerScorerList();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
