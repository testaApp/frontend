import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/domain/player/playerProfile.dart';
import 'package:blogapp/features/standing/pages/standing/leagues_page/knockout/knockout_widget.dart';

class QuarterFinalPageDown extends StatelessWidget {
  Team TeamOne;
  Team TeamTwo;

  QuarterFinalPageDown(
      {super.key, required this.TeamOne, required this.TeamTwo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              width: 179.w,
            ),
            Container(
              width: 2.w,
              height: 85.h,
              color: Colors.white,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 7.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KnockoutMatchWgt(
                  teamOne: TeamOne,
                  teamTwo: TeamTwo,
                  teamOneFail: true,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
