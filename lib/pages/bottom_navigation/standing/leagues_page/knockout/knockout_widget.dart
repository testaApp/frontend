import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../domain/player/playerProfile.dart';

class KnockoutMatchWgt extends StatelessWidget {
  Team teamOne;
  Team teamTwo;
  bool teamOneFail;

  KnockoutMatchWgt(
      {super.key,
      required this.teamOne,
      required this.teamTwo,
      this.teamOneFail = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.w),
      child: Container(
        width: 70.w,
        height: 65.h,
        color: Colors.grey.shade800,
        padding: EdgeInsets.symmetric(horizontal: 3.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CachedNetworkImage(imageUrl: teamOne.logo ?? ''),
                    ),
                    Text(
                      teamOne.shortName != null
                          ? teamOne.shortName!.substring(
                              0,
                              teamOne.shortName!.length > 3
                                  ? 3
                                  : teamOne.shortName!.length)
                          : '',
                      style: teamTwo == false ? shortNamesOne : shortNames,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CachedNetworkImage(imageUrl: teamTwo.logo ?? ''),
                    ),
                    Text(
                      teamTwo.shortName != null
                          ? teamTwo.shortName!.substring(
                              0,
                              teamTwo.shortName!.length > 3
                                  ? 3
                                  : teamTwo.shortName!.length)
                          : '',
                      style: teamOneFail == false ? shortNamesOne : shortNames,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 20.w,
                  child: Text(
                    '1',
                    textAlign: TextAlign.center,
                    style: teamOneFail == true ? blurredNum : shortNames,
                  ),
                ),
                SizedBox(
                    width: 20.w,
                    child: Text(
                      '-',
                      textAlign: TextAlign.center,
                      style: shortNames,
                    )),
                SizedBox(
                    width: 20.w,
                    child: Text(
                      '2',
                      textAlign: TextAlign.center,
                      style: teamOneFail == false ? blurredNum : shortNames,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

TextStyle shortNames = TextStyle(
    color: Colors.white, fontSize: 13.sp, overflow: TextOverflow.clip);

TextStyle shortNamesOne = TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
    fontSize: 13.sp,
    overflow: TextOverflow.clip);

TextStyle blurredNum = TextStyle(color: Colors.grey, fontSize: 14.sp);
