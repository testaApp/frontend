import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/matchdetail/head_to_head/head_to_head_bloc.dart';
import '../../../../application/matchdetail/head_to_head/head_to_head_event.dart';
import '../../../../application/matchdetail/head_to_head/head_to_head_state.dart';
import '../../../../localization/demo_localization.dart';
import '../../../../models/fixtures/stat.dart';
import '../../../constants/text_utils.dart';
import 'H2HMatchList.dart';

class HeadToHeadPage extends StatefulWidget {
  final int homeTeamId;
  final int awayTeamId;
  final int? currentFixtureId;
  const HeadToHeadPage(
      {super.key,
      required this.homeTeamId,
      required this.awayTeamId,
      required this.currentFixtureId});

  @override
  State<HeadToHeadPage> createState() => _HeadToHeadPageState();
}

class _HeadToHeadPageState extends State<HeadToHeadPage> {
  @override
  void initState() {
    super.initState();
    // Reset state first, then request new data
    context.read<HeadToHeadBloc>().add(ResetHeadToHead());
    context.read<HeadToHeadBloc>().add(HeadToHeadRequested(
          homeTeamId: widget.homeTeamId,
          awayTeamId: widget.awayTeamId,
          currentFixtureId: widget.currentFixtureId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeadToHeadBloc, HeadToHeadState>(
      builder: (context, state) {
        if (state.status == h2hStatus.requestInProgress ||
            state.status == h2hStatus.initial) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (state.matches.isNotEmpty) {
          // 1. SORTING: Descending (Recent first)
          final sortedMatches = List<Stat>.from(state.matches);
          sortedMatches.sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a.dateString ?? '') ?? DateTime(1900);
            DateTime dateB =
                DateTime.tryParse(b.dateString ?? '') ?? DateTime(1900);
            return dateB.compareTo(dateA);
          });

          // 2. SCROLLING: SingleChildScrollView fixes the "not scrolling" issue
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                H2HMatchList(statList: sortedMatches),
                SizedBox(height: 40.h), // Extra space at bottom
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              DemoLocalizations.unableToFindSharedGames,
              style: TextUtils.setTextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}
