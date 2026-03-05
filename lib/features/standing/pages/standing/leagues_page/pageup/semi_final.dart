import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/domain/player/playerProfile.dart';
import 'package:blogapp/features/standing/pages/standing/leagues_page/knockout/knockout_widget.dart';

class SemifinalPageUp extends StatelessWidget {
  final Team TeamOne;
  final Team TeamTwo;
  final Team TeamThree;
  final Team TeamFour;

  const SemifinalPageUp({
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
            painter: LinePainter(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                KnockoutMatchWgt(
                  teamOne: TeamOne,
                  teamTwo: TeamTwo,
                ),
                KnockoutMatchWgt(
                  teamOne: TeamThree,
                  teamTwo: TeamFour,
                ),
              ],
            ),
          ],
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

    final centerX = size.width / 2;
    final lineWidth = 160.w; // Increased width of each line section
    final spacing = 14.w; // Increased spacing between line sections
    final totalWidth = 2 * lineWidth + spacing;

    final leftFirstX = centerX - totalWidth / 2 + lineWidth / 2;
    final leftSecondX = leftFirstX + lineWidth + spacing;

    final topY = size.height / 2 + 18.h;
    final midY = topY + 25.h;
    final bottomY = size.height + 40.h;

    canvas.drawLine(Offset(leftFirstX, topY), Offset(leftFirstX, midY), paint);
    canvas.drawLine(
        Offset(leftSecondX, topY), Offset(leftSecondX, midY), paint);
    canvas.drawLine(Offset(leftFirstX, midY), Offset(leftSecondX, midY), paint);

    final leftMidX = (leftFirstX + leftSecondX) / 2;

    canvas.drawLine(Offset(leftMidX, midY), Offset(leftMidX, bottomY), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
