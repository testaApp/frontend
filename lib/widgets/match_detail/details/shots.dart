import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/demo_localization.dart';
import '../../../models/fixtures/match_statistics.dart';
import '../../../pages/constants/colors.dart';
import '../../../pages/constants/text_utils.dart';
import 'shot_widget.dart';

class ShotsWgt extends StatelessWidget {
  const ShotsWgt(
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
    final homeTeamStat = homeTeamId == matchStat.teamOneMatchStatistics.id
        ? matchStat.teamOneMatchStatistics
        : matchStat.teamTwoMatchStatistics;
    final awayTeamStat = awayTeamId == matchStat.teamOneMatchStatistics.id
        ? matchStat.teamOneMatchStatistics
        : matchStat.teamTwoMatchStatistics;
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
          Align(
            alignment: Alignment.center,
            child: Text(DemoLocalizations.goalTrials,
                style: TextUtils.setTextStyle(fontSize: 17.sp)),
          ),
          SizedBox(height: 3.h),
          ShotLine(
              homeTeamStat: homeTeamStat.totalShots ?? 0,
              label: DemoLocalizations.totalGoalTrialss,
              awayTeamStat: awayTeamStat.totalShots ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),

          SizedBox(
            height: 3.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              width: 320.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                color: Colors.grey.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 25.h,
                  ),
                  SizedBox(
                    width: 260.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(homeTeamStat.shotsOfGoal?.toString() ?? '',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.abel(
                                fontSize: 18.sp, color: Colors.white)),
                        Text(
                          DemoLocalizations.goalsOfftarget,
                          style: TextUtils.setTextStyle(color: Colors.white),
                        ),
                        Text(
                          awayTeamStat.shotsOfGoal?.toString() ?? '',
                          // "5" ,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.abel(
                              fontSize: 18.sp, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(5.w)),
                    child: Container(
                      width: 200.w,
                      decoration: const BoxDecoration(
                          border: Border(
                        top: BorderSide(
                          color: Colors.white,
                          width: 5,
                        ),
                        right: BorderSide(color: Colors.white, width: 5),
                        left: BorderSide(color: Colors.white, width: 5),
                      )),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 23.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 30.w,
                                child: Text(
                                  homeTeamStat.shotsOnGoal?.toString() ?? '0',
                                  // "5" ,

                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.abel(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        DemoLocalizations.goalsOntarget,
                                        style: TextUtils.setTextStyle(
                                            color: Colors.white),
                                      ))),
                              SizedBox(
                                width: 30.w,
                                child: Text(
                                  awayTeamStat.shotsOnGoal.toString(),
                                  // "5" ,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.abel(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 23.h,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          ShotLine(
            homeTeamStat: homeTeamStat.shotsOnGoal ?? 0,
            label: DemoLocalizations.goalsOnTarget,
            awayTeamStat:
                awayTeamStat.shotsOnGoal ?? 0, // ← Fixed: use actual data
            homeTeamColor: homeTeamColor,
            awayTeamColor: awayTeamColor,
          ),
          ShotLine(
              homeTeamStat: homeTeamStat.blockedShots ?? 0,
              label: DemoLocalizations.blockedGoalTrials,
              awayTeamStat: awayTeamStat.blockedShots ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),

          ShotLine(
              homeTeamStat: homeTeamStat.shotsInsideBox ?? 0,
              label: DemoLocalizations.goalTrialsInsideBox,
              awayTeamStat: awayTeamStat.shotsInsideBox ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          // SizedBox(height : 15.h),
          ShotLine(
              homeTeamStat: homeTeamStat.shotsOutsideBox ?? 0,
              label: DemoLocalizations.goalTrialsOutsideBox,
              awayTeamStat: awayTeamStat.shotsOutsideBox ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.totalPasses ?? 0,
              label: DemoLocalizations.totalPass,
              awayTeamStat: awayTeamStat.totalPasses ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.goalKeeperSaves ?? 0,
              label: DemoLocalizations.goalkeeperSaves,
              awayTeamStat: awayTeamStat.goalKeeperSaves ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.yellowCards ?? 0,
              label: DemoLocalizations.yellowCards,
              awayTeamStat: awayTeamStat.yellowCards ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),
          ShotLine(
              homeTeamStat: homeTeamStat.redCards ?? 0,
              label: DemoLocalizations.redCard,
              awayTeamStat: awayTeamStat.redCards ?? 0,
              homeTeamColor: homeTeamColor,
              awayTeamColor: awayTeamColor),

          SizedBox(
            height: 5.h,
          )
        ],
      ),
    );
  }
}
