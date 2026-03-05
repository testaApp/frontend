import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/domain/player/playerProfile.dart';
import 'knockout_widget.dart';

class VerticalLinePainter extends CustomPainter {
  final double offsetX;

  VerticalLinePainter({required this.offsetX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final midX = (size.width / 2.0) + offsetX;
    canvas.drawLine(Offset(midX, -10), Offset(midX, size.height + 30), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FinalMatch extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;
  const FinalMatch({super.key, required this.TeamOne, required this.TeamTwo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: VerticalLinePainter(offsetX: 33.w),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 7.h,
            ),
            Row(
              children: [
                Container(
                  width: 65.w,
                ),
                KnockoutMatchWgt(
                  teamOne: TeamOne,
                  teamTwo: TeamTwo,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
