import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:blogapp/components/oppositeColor.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class ShotLine extends StatelessWidget {
  const ShotLine(
      {super.key,
      required this.homeTeamStat,
      required this.label,
      required this.awayTeamStat,
      required this.homeTeamColor,
      required this.awayTeamColor});
  final int homeTeamStat;
  final String label;
  final int awayTeamStat;
  final Color homeTeamColor;
  final Color awayTeamColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Container(
          color: Colors.transparent,
          width: 342.w,
          child: const SizedBox(
            height: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 296.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                ),
                decoration: homeTeamStat > awayTeamStat
                    ? BoxDecoration(
                        // shape: BoxShape.circle,
                        color: homeTeamColor,
                        borderRadius: BorderRadius.all(Radius.circular(25.w)))
                    : null,
                child: Text(homeTeamStat.toString(),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.abel(
                        fontSize: 18.sp,
                        color: homeTeamStat > awayTeamStat
                            ? getOppositeColor(homeTeamColor)
                            : Colors.grey.shade400)),
              ),
              Expanded(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: TextUtils.setTextStyle(
                          color: Colorscontainer.greenColor))),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                ),
                decoration: homeTeamStat < awayTeamStat
                    ? BoxDecoration(
                        // shape: BoxShape.circle,
                        color: awayTeamColor,
                        borderRadius: BorderRadius.all(Radius.circular(25.w)))
                    : null,
                child: Text(awayTeamStat.toString(),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.abel(
                        fontSize: 18.sp,
                        color: homeTeamStat < awayTeamStat
                            ? getOppositeColor(awayTeamColor)
                            : Colors.grey.shade400)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
