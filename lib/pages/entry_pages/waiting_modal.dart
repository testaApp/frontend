import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../localization/demo_localization.dart';
import '../constants/colors.dart';

class WaitingModal extends StatelessWidget {
  const WaitingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/testa_appbar.png',
              width: 80.w,
              height: 80.h,
            ),
            SizedBox(height: 20.h),
            CircularProgressIndicator(
              color: Colorscontainer.greenColor,
            ),
            SizedBox(height: 16.h),
            Text(
              DemoLocalizations.pleaseWait,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colorscontainer.greenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
