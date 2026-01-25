import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bottom_navigation/standing/leagues_page/top_scorers/top_assists.dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_scorers.dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_red_card .dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_yellow_card.dart';

class TopTeamsPage extends StatefulWidget {
  final String logo;
  final int leagueId;
  const TopTeamsPage({super.key, required this.logo, required this.leagueId});

  @override
  State<TopTeamsPage> createState() => _TopTeamsPageState();
}

class _TopTeamsPageState extends State<TopTeamsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          TopScorersView(
            leagueId: widget.leagueId,
            logo: widget.logo,
          ),
          SizedBox(
            height: 4.h,
          ),
          TopAssistorsView(
            leagueId: widget.leagueId,
            logo: widget.logo,
          ),
          SizedBox(
            height: 4.h,
          ),
          TopYellowCardView(
            leagueId: widget.leagueId,
            logo: widget.logo,
          ),
          SizedBox(
            height: 4.h,
          ),
          TopRedCardView(
            leagueId: widget.leagueId,
            logo: widget.logo,
          ),
          SizedBox(
            height: 40.h,
          ),
        ],
      ),
    );
  }
}
