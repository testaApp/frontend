import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../domain/player/playerProfile.dart';
import '../knockout/knockout_widget.dart';

class BottomLinePainter extends CustomPainter {
  final double offsetX;

  BottomLinePainter({required this.offsetX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final midX = (size.width / 2.0) + offsetX;
    canvas.drawLine(Offset(midX, size.height), Offset(midX, size.height + 10),
        paint); // Extend the line below the widget
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QuarterFinalPageUp extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;

  const QuarterFinalPageUp(
      {super.key, required this.TeamOne, required this.TeamTwo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: BottomLinePainter(
                offsetX: 0), // Adjust offsetX to position the line
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10.h,
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
