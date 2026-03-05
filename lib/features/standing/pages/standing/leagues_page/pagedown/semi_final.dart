import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/domain/player/playerProfile.dart';
import 'package:blogapp/features/standing/pages/standing/leagues_page/knockout/knockout_widget.dart';

class SemifinalPageDown extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;
  final Team TeamThree;
  final Team TeamFour;

  const SemifinalPageDown({
    super.key,
    required this.TeamOne,
    required this.TeamTwo,
    required this.TeamThree,
    required this.TeamFour,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: LinePainterUp(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  KnockoutMatchWgt(
                    teamOne: TeamOne,
                    teamTwo: TeamTwo,
                  ),
                  KnockoutMatchWgt(
                    teamOne: TeamThree,
                    teamTwo: TeamFour,
                    teamOneFail: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LinePainterUp extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final leftX = size.width / 4.0;
    final rightX = 3.0 * size.width / 4.0;
    final bottomY = size.height - 60.0;
    final midY =
        bottomY - 25.0; // Adjust this value to control the vertical spacing

    canvas.drawLine(Offset(leftX, bottomY), Offset(leftX, midY), paint);
    canvas.drawLine(Offset(rightX, bottomY), Offset(rightX, midY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, midY), paint);

    final midX = (leftX + rightX) / 2.0;

    canvas.drawLine(Offset(midX, midY), Offset(midX, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
