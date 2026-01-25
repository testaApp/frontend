import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../localization/demo_localization.dart';
import '../../../../constants/text_utils.dart';

TextStyle headlineStyle =
    GoogleFonts.abyssinicaSil(color: Colors.grey, fontSize: 11.sp);

class FirstRowForFullView extends StatelessWidget {
  const FirstRowForFullView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          border: Border.all(color: Colors.grey)),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: SizedBox(
              width: 50.w,
              child: Text(
                DemoLocalizations.rank,
                style: TextUtils.setTextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
          //  SizedBox(
          //   width: 20.w
          //  ),
          Container(
            width: 130.w,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              DemoLocalizations.teamName,
              style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DemoLocalizations.played,
                style: headlineStyle,
              ),
              Text(
                DemoLocalizations.won,
                style: headlineStyle,
              ),
              Text(
                DemoLocalizations.draw,
                style: headlineStyle,
              ),
              Text(
                DemoLocalizations.lost,
                style: headlineStyle,
              ),
              Text(
                '+/-',
                style: headlineStyle,
              ),
              Text(
                DemoLocalizations.goal,
                style: headlineStyle,
              ),
              Text(
                DemoLocalizations.point,
                style: headlineStyle,
              ),
            ],
          ))
        ],
      ),
    );
  }
}
