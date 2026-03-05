import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class SeasonsCard extends StatelessWidget {
  const SeasonsCard({super.key});

  // Seasons season;
// SeasonsCard({required this.season});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15.h,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Container(
              color: Colorscontainer.greyShade,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '2022/23',
                      style: TextUtils.setTextStyle(
                          fontSize: 14.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.white.withOpacity(0),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://media.api-sports.io/football/teams/50.png',
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.network_locked),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ማንችስተር ሲቲ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                          ),
                          Text(
                            'አሸናፊ',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13.sp),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.white.withOpacity(0),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://media.api-sports.io/football/teams/42.png',
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.network_locked),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'አርሰናል',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                          ),
                          Text(
                            '2ኛ',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13.sp),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ሰንጠረዥ',
                      style: TextUtils.setTextStyle(
                          color: Colorscontainer.greenColor, fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
