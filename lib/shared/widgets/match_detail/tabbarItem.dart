import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

Widget TabBarItem(
    {required String tabName,
    required Function() onTap,
    required currentIdx,
    required int selectedIdx}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: currentIdx == selectedIdx
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colorscontainer.greenColor, width: 2.h)))
          : null,
      child: Text(tabName,
          overflow: TextOverflow.ellipsis,
          style: selectedIdx == currentIdx
              ? TextUtils.setTextStyle(
                  fontSize: 17.sp, color: Colors.white, engFont: 13.sp)
              : TextUtils.setTextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey.shade300,
                  engFont: 11.sp)),
    ),
  );
}
