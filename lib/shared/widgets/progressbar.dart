import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/services/notifiers/progress_notifier.dart';
import 'package:blogapp/services/page_manager.dart';
import 'package:blogapp/services/service_locator.dart';

class AudioProgressBarr extends StatelessWidget {
  const AudioProgressBarr({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 20,
            width: 270.w,
            child: ProgressBar(
              progressBarColor: Colors.grey.shade300,
              // thumbColor: Colors.amber,
              thumbRadius: 0,
              baseBarColor: Colors.grey,
              progress: value.current,
              buffered: value.buffered,
              total: value.total,
              onSeek: pageManager.seek,
              barHeight: 6.5,
              bufferedBarColor: Colorscontainer.greenColor,
              thumbCanPaintOutsideBar: true,
              timeLabelTextStyle:
                  TextStyle(color: Colors.grey, fontSize: 12.sp),
              timeLabelType: TimeLabelType.remainingTime,
              timeLabelPadding: 12.sp,
            ),
          ),
        );
      },
    );
  }
}
