import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_bloc.dart';
import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_event.dart';
import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_state.dart';
import '../../../../../models/fixtures/last_5_matches_model.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';

class LastFiveMatchesView extends StatefulWidget {
  final String teamId;
  const LastFiveMatchesView({super.key, required this.teamId});

  @override
  State<LastFiveMatchesView> createState() => _LastFiveMatchesViewState();
}

class _LastFiveMatchesViewState extends State<LastFiveMatchesView> {
  @override
  void initState() {
    super.initState();
    context
        .read<LastFiveMatchesBloc>()
        .add(LastFiveMatchesRequested(teamId: widget.teamId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LastFiveMatchesBloc, LastFiveMatchesState>(
      builder: (context, state) {
        if (state.status == fiveMatchesStatus.initial ||
            state.status == fiveMatchesStatus.requestInProgress ||
            state.status == fiveMatchesStatus.requestInProgress) {
          return const CircularProgressIndicator(strokeWidth: 4);
        } else if (state.status == fiveMatchesStatus.requestSuccess) {
          // Show all leagues vertically
          return Column(
            children: state.matchesByLeague.map((leagueMatches) {
              if (leagueMatches.matches.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League name header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Text(
                      leagueMatches.leagueName,
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Matches row
                  Container(
                    width: 350.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: leagueMatches.matches
                          .map((match) => _buildCard(match, widget.teamId))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCard(LastFiveMatch match, String teamId) {
    Color color = Colors.transparent;

    final isHome = match.homeTeamId == teamId;
    final scored = isHome ? (match.scoreHome ?? 0) : (match.scoreAway ?? 0);
    final conceded = isHome ? (match.scoreAway ?? 0) : (match.scoreHome ?? 0);

    // Determine color based on match result
    if (scored > conceded) {
      color = Colorscontainer.greenColor; // Win
    } else if (scored < conceded) {
      color = Colors.red; // Loss
    } else {
      color = Colorscontainer.blueShade; // Draw
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(5)),
          width: 50.w,
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(scored.toString(),
                  style: TextUtils.setTextStyle(color: Colors.white)),
              Text(' - ', style: TextUtils.setTextStyle(color: Colors.white)),
              Text(conceded.toString(),
                  style: TextUtils.setTextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50.w,
          child: CachedNetworkImage(
            imageUrl: isHome ? match.awayTeamLogo : match.homeTeamLogo,
            width: 30.w,
            height: 30.h,
            errorWidget: (context, url, error) =>
                const Icon(Icons.network_locked),
          ),
        ),
      ],
    );
  }
}
