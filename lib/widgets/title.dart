import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_scroll/text_scroll.dart';

import '../pages/constants/text_utils.dart';
import '../services/page_manager.dart';
import '../services/service_locator.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
        valueListenable: pageManager.currentSongTitleNotifier,
        builder: (_, title, __) {
          return Align(
            alignment: Alignment.center,
            child: TextScroll(
              title,
              velocity: const Velocity(pixelsPerSecond: Offset(13, 0)),
              style: TextUtils.setTextStyle(
                color: Colors.grey[400],
                fontSize: 18.sp,
              ),
            ),
          );
        });
  }
}
