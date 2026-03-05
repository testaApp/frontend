import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/All_transfer.dart';

class Transfertab extends StatelessWidget {
  const Transfertab({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = Colorscontainer.greenColor;
    final pageGradient = LinearGradient(
      colors: isLight
          ? const [
              Color(0xFFF7FAFC),
              Color(0xFFE8F4F0),
              Color(0xFFF7FAFC),
            ]
          : const [
              Color(0xFF04070C),
              Color(0xFF0B1B1A),
              Color(0xFF04070C),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: pageGradient),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: isLight
                    ? Colors.white.withOpacity(0.92)
                    : const Color(0xFF0B1216).withOpacity(0.92),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                floating: false,
                leading: Padding(
                  padding: EdgeInsets.only(left: 12.w, top: 6.h, bottom: 6.h),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
                centerTitle: true,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DemoLocalizations.transfer_window,
                      style: TextUtils.setTextStyle(
                        color: isLight ? Colors.black87 : Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      'Latest deals & rumours',
                      style: TextUtils.setTextStyle(
                        color: isLight ? Colors.black45 : Colors.white70,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              
              ),
            ];
          },
          body: const Transferdetail(),
        ),
      ),
    );
  }
}
