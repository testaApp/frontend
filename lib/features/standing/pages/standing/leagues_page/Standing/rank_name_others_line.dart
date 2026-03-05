import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class FirstRow extends StatelessWidget {
  const FirstRow({super.key, required this.nameWidth});
  final double nameWidth;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
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
                    width: nameWidth,
                    child: Text(
                      DemoLocalizations.teamName,
                      style: TextUtils.setTextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(
                    child: Text(
                      DemoLocalizations.played,
                      textAlign: TextAlign.end,
                      style: TextUtils.setTextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 55.w,
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        DemoLocalizations.goal,
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 32.0.w,
                      // padding:
                      //     const EdgeInsets.symmetric( horizontal: 16.0),
                      child: Text(
                        DemoLocalizations.point,
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
