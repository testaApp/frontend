import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/services/page_manager.dart';
import 'package:blogapp/services/service_locator.dart';

class ArtistWidget extends StatelessWidget {
  const ArtistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
        valueListenable: pageManager.currentSongArtistNotifier,
        builder: (_, artist, __) {
          return Align(
            alignment: Alignment.center,
            child: Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextUtils.setTextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        });
  }
}
