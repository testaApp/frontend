import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../domain/player/playerProfile.dart';
import '../knockout/knockout_widget.dart';

class Round16 extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;
  final Team TeamThree;
  final Team TeamFour;
  final Team TeamFive;
  final Team TeamSix;
  final Team TeamSeven;
  final Team TeamEight;

  const Round16({
    super.key,
    required this.TeamOne,
    required this.TeamTwo,
    required this.TeamThree,
    required this.TeamFour,
    required this.TeamFive,
    required this.TeamSix,
    required this.TeamSeven,
    required this.TeamEight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: LinePainter(),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 326.w,
            child: Row(
              children: [
                Row(
                  children: [
                    KnockoutMatchWgt(
                      teamOne: TeamOne,
                      teamTwo: TeamTwo,
                      teamOneFail: true,
                    ),
                    SizedBox(width: 7.w),
                    KnockoutMatchWgt(
                      teamOne: TeamThree,
                      teamTwo: TeamFour,
                      teamOneFail: true,
                    ),
                  ],
                ),
                SizedBox(width: 22.w),
                Row(
                  children: [
                    KnockoutMatchWgt(
                      teamOne: TeamFive,
                      teamTwo: TeamSix,
                      teamOneFail: true,
                    ),
                    SizedBox(width: 7.w),
                    KnockoutMatchWgt(
                      teamOne: TeamSeven,
                      teamTwo: TeamEight,
                      teamOneFail: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final leftFirstX = 5.w + 65.w / 2;
    final leftSecondX = leftFirstX + 78.w + 7.w;
    final rightFirstX = leftSecondX + 78.w + 22.w;
    final rightSecondX = rightFirstX + 78.w + 7.w;

    final topY = size.height / 2 + 15.h;
    final midY = topY + 25.h;
    final bottomY = size.height + 30.h;

    canvas.drawLine(Offset(leftFirstX, topY), Offset(leftFirstX, midY), paint);
    canvas.drawLine(
        Offset(leftSecondX, topY), Offset(leftSecondX, midY), paint);
    canvas.drawLine(Offset(leftFirstX, midY), Offset(leftSecondX, midY), paint);

    canvas.drawLine(
        Offset(rightFirstX, topY), Offset(rightFirstX, midY), paint);
    canvas.drawLine(
        Offset(rightSecondX, topY), Offset(rightSecondX, midY), paint);
    canvas.drawLine(
        Offset(rightFirstX, midY), Offset(rightSecondX, midY), paint);
    final leftMidX = (leftFirstX + leftSecondX) / 2;
    final rightMidX = (rightFirstX + rightSecondX) / 2;

    canvas.drawLine(Offset(leftMidX, midY), Offset(leftMidX, bottomY), paint);
    canvas.drawLine(Offset(rightMidX, midY), Offset(rightMidX, bottomY), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
