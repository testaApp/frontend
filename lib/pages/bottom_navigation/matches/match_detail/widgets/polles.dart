import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/text_utils.dart';

class GradientPainter extends CustomPainter {
  final double percentage;

  GradientPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Colors.green, Colors.black],
        stops: [percentage, percentage],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const double curveHeight = 3.0;
    final Path path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(0, 0, curveHeight, 0)
      ..lineTo(size.width - curveHeight, 0)
      ..quadraticBezierTo(size.width, 0, size.width, size.height / 2)
      ..quadraticBezierTo(
          size.width, size.height, size.width - curveHeight, size.height)
      ..lineTo(curveHeight, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedColorChangeContainer extends StatefulWidget {
  final double percentage;
  const AnimatedColorChangeContainer({super.key, required this.percentage});

  @override
  _AnimatedColorChangeContainerState createState() =>
      _AnimatedColorChangeContainerState();
}

class _AnimatedColorChangeContainerState
    extends State<AnimatedColorChangeContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation =
        Tween<double>(begin: 0, end: widget.percentage).animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        Container(
          child: CustomPaint(
            painter: GradientPainter(percentage: _animation.value),
            child: SizedBox(
              width: 200.w,
              height: 7.5.h,
            ),
          ),
        ),
        SizedBox(
            width: 30.w), // Add some spacing between the container and the text
        Text(
          '${(_animation.value * 100).toStringAsFixed(0)}%',
          style: TextUtils.setTextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0.sp,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
