import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../application/matchdetail/matchStatistics/match_statistics_bloc.dart';
import '../../../../../application/matchdetail/matchStatistics/match_statistics_event.dart';
import '../../../../../application/matchdetail/matchStatistics/match_statistics_state.dart';
import '../../../../../components/dominant_color_generator.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../widgets/match_detail/details/possession.dart';
import '../../../../../widgets/match_detail/details/shots.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';

class TeamsStat extends StatefulWidget {
  const TeamsStat(
      {super.key,
      required this.homeTeamLogo,
      required this.awayTeamLogo,
      required this.homeTeamId,
      required this.awayTeamId,
      required this.fixtureId});

  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final int homeTeamId;
  final int? fixtureId;
  final int awayTeamId;
  @override
  State<TeamsStat> createState() => _TeamStatState();
}

class _TeamStatState extends State<TeamsStat> {
  int selectedIdx = 0;

  Color? homeTeamColor;
  Color? awayTeamColor;

  @override
  void initState() {
    context
        .read<MatchStatisticsBloc>()
        .add(MatchStatisticsRequested(fixtureId: widget.fixtureId));
    generateColors();
    super.initState();
  }

  Future<void> generateColors() async {
    Color dominantOne =
        await generateDominantColor(imageUrl: widget.homeTeamLogo);
    Color dominantTwo =
        await generateDominantColor(imageUrl: widget.awayTeamLogo);
    setState(() {
      homeTeamColor = dominantOne;
      awayTeamColor = dominantTwo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Container(
            //      padding: EdgeInsets.symmetric(vertical: 2.h),
            //   decoration: BoxDecoration(
            //     // color:  Colorscontainer.greyShade.withOpacity(0.4),
            //       color:  Colorscontainer.greyShade,
            //     borderRadius: BorderRadius.circular(20.w)
            //   ),
            //   child: Row(
            //     children: [
            //         GestureDetector(
            //             onTap: (){
            //     setState(() {
            //       selectedIdx = 0;
            //     });
            //   },
            //           child: Container(
            //                padding: EdgeInsets.symmetric( vertical: 8.h , ),
            //                        width: 112.5.w,
            //              decoration: selectedIdx == 0  ?  BoxDecoration(
            //                     borderRadius: BorderRadius.circular(20.w),
            //            color: Colors.grey.shade600,
            //                   ) : null,
            //                   child: Text('የሙሉ ጨዋታ' ,
            //                   textAlign: TextAlign.center,
            //                    style: TextUtils.setTextStyle(color: Colors.white , fontSize: 12.sp)),
            //           ),
            //         ) ,
            //          GestureDetector(
            //             onTap: (){
            //     setState(() {
            //       selectedIdx = 1;
            //     });
            //   },
            //            child: Container(
            //              padding: EdgeInsets.symmetric( vertical: 8.h),
            //               width: 112.5.w,

            //                    decoration: selectedIdx == 1  ?  BoxDecoration(
            //                     borderRadius: BorderRadius.circular(20.w),
            //            color: Colors.grey.shade600,
            //                   ) : null,
            //                    child: Text('የመጀመሪያ አጋማሽ' ,
            //                      textAlign: TextAlign.center,
            //                     style: TextUtils.setTextStyle(color: Colors.white , fontSize: 12.sp)),
            //                          ),
            //          ),
            //         GestureDetector(
            //             onTap: (){
            //     setState(() {
            //       selectedIdx = 2;
            //     });
            //   },
            //           child: Container(
            //              padding: EdgeInsets.symmetric( vertical: 8.h),
            //               width: 116.5.w,
            //            decoration: selectedIdx == 2 ?  BoxDecoration(
            //                     borderRadius: BorderRadius.circular(20.w),
            //            color: Colors.grey.shade600,
            //                   ) : null,
            //                   child: Text('ሁለተኛ አጋማሽ' ,
            //                     textAlign: TextAlign.center,
            //                   style: TextUtils.setTextStyle(color: Colors.white , fontSize: 12.sp)),
            //           ),
            //         )
            //     ],
            //   ),

            // ) ,
            SizedBox(height: 15.h),
            BlocBuilder<MatchStatisticsBloc, MatchStatisticsState>(
              builder: (context, state) {
                print(state.status);
                if (state.status == matchesStatsStatus.requestSuccessed) {
                  return Column(
                    children: [
                      PossessionWgt(
                          // ,
                          homeTeamId: widget.homeTeamId,
                          awayTeamId: widget.awayTeamId,
                          matchStat: state.teamsMatchStat!,
                          homeTeamColor:
                              homeTeamColor ?? Colorscontainer.greenColor,
                          awayTeamColor:
                              awayTeamColor ?? Colorscontainer.greenColor),
                      SizedBox(
                        height: 15.h,
                      ),
                      ShotsWgt(
                          homeTeamId: widget.homeTeamId,
                          awayTeamId: widget.awayTeamId,
                          matchStat: state.teamsMatchStat!,
                          homeTeamColor:
                              homeTeamColor ?? Colorscontainer.greenColor,
                          awayTeamColor:
                              awayTeamColor ?? Colorscontainer.greenColor),
                      SizedBox(
                        height: 80.h,
                      ),
                    ],
                  );
                } else if (state == matchesStatsStatus.networkProblem) {
                  return Center(
                    child: Text(
                      DemoLocalizations.networkProblem,
                      style: TextUtils.setTextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
