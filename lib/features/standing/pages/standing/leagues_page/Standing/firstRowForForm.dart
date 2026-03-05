import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class FirstRowForForm extends StatelessWidget {
  const FirstRowForForm({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: Colors.grey)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Container(
                // width: nameWidth,
                child: Text(
                  DemoLocalizations.rank,
                  style: TextUtils.setTextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              width: 130.w,
              child: Text(
                // "የቡድን ስም"
                DemoLocalizations.teamName,
                overflow: TextOverflow.ellipsis,
                style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  DemoLocalizations.recentMatches,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextUtils.setTextStyle(
                      fontSize: 13.sp,
                      wordSpacing: 2.sp,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
