import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../domain/player/playerProfile.dart';
import '../knockout/knockout_widget.dart';

class ThirdPlaceMatch extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;

  const ThirdPlaceMatch(
      {super.key, required this.TeamOne, required this.TeamTwo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 7.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KnockoutMatchWgt(
                  teamOne: TeamOne,
                  teamTwo: TeamTwo,
                  teamOneFail: false,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
