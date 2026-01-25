import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/oppositeColor.dart';
import '../../../localization/demo_localization.dart';
import '../../../models/fixtures/match_statistics.dart';
import '../../../pages/constants/colors.dart';
import '../../../pages/constants/text_utils.dart';
import 'shot_widget.dart';

class PossessionWgt extends StatelessWidget {
  const PossessionWgt(
      {super.key,
      required this.homeTeamColor,
      required this.awayTeamColor,
      required this.matchStat,
      required this.homeTeamId,
      required this.awayTeamId});

  final Color homeTeamColor;
  final Color awayTeamColor;
  final TeamsMatchStat matchStat;
  final int homeTeamId;
  final int awayTeamId;
  @override
  Widget build(BuildContext context) {
    // double homeTeamPos = 30;
    // double homeTeamWidth  = (homeTeamPos / 100 ) * 316;
    // double awayTeamPos = 70;
    //  double awayTeamWidth  = (awayTeamPos / 100 ) * 316;

    final homeTeamStat = homeTeamId == matchStat.teamOneMatchStatistics.id
        ? matchStat.teamOneMatchStatistics
        : matchStat.teamTwoMatchStatistics;
    final awayTeamStat = awayTeamId == matchStat.teamOneMatchStatistics.id
        ? matchStat.teamOneMatchStatistics
        : matchStat.teamTwoMatchStatistics;
    double homeTeamWidth = ((homeTeamStat.ballPossession ?? 0) /
            ((homeTeamStat.ballPossession ?? 0) +
                (awayTeamStat.ballPossession ?? 0) +
                0.1)) *
        316;
    double awayTeamWidth = ((awayTeamStat.ballPossession ?? 0) /
            ((homeTeamStat.ballPossession ?? 0) +
                (awayTeamStat.ballPossession ?? 0) +
                0.1)) *
        316;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        color: Theme.of(context).cardColor,
      ),
      // padding: EdgeInsets.symmetric(horizontal: 10.w ),
      child: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          Text(DemoLocalizations.ballPossession,
              style: TextUtils.setTextStyle(fontSize: 17.sp)),
          SizedBox(
            height: 15.h,
          ),
          SizedBox(
            width: 330.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 35.sp,
                  width: homeTeamWidth.w,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                      color: homeTeamColor,
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(50.w))),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // "${ homeTeamPos.toString().substring(0 ,2)}%",
                        '${homeTeamStat.ballPossession.toString()}%',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.abel(
                            color: getOppositeColor(homeTeamColor),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  width: 3.w,
                ),
                Container(
                  height: 35.sp,
                  width: awayTeamWidth.w,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                      color: awayTeamColor,
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(50.w))),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('${awayTeamStat.ballPossession.toString()}%',
                          // "",
                          // "${awayTeamPos.toString().substring(0 ,2)}%" ,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.abel(
                              color: getOppositeColor(awayTeamColor),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          ShotLine(
              homeTeamStat: homeTeamStat.totalShots ?? 0,
              //  15,
              label: DemoLocalizations.totalGoalTrials,
              awayTeamStat: awayTeamStat.totalShots ?? 0,
              // 13,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.passesAccurate ?? 0,
              // 11,
              label: DemoLocalizations.successfulPasses,
              awayTeamStat: awayTeamStat.passesAccurate ?? 0,
              //  13,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.fouls ?? 0,
              // 15,
              label: DemoLocalizations.fouls,
              awayTeamStat: awayTeamStat.fouls ?? 0,
              //  13,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.offsides ?? 0,
              // 11,
              label: DemoLocalizations.offsideGame,
              awayTeamStat: awayTeamStat.offsides ?? 0,
              // 11,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.cornerKicks ?? 0,
              label: DemoLocalizations.cornerKick,
              awayTeamStat: awayTeamStat.cornerKicks ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          SizedBox(
            height: 15.h,
          )
        ],
      ),
    );
  }
}
