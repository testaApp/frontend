import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../localization/demo_localization.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/text_utils.dart';
import 'All_transfer.dart';

class Transfertab extends StatelessWidget {
  const Transfertab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 32.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CircleAvatar(
                      radius: 15.sp,
                      backgroundColor:
                          Colorscontainer.greyShade.withOpacity(0.4),
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_back,
                            color: Colorscontainer.greenColor),
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                DemoLocalizations.transfer_window,
                style: TextUtils.setTextStyle(
                  color: Colorscontainer.greenColor,
                  fontSize: 18.sp,
                  decoration: TextDecoration.none,
                ),
              ),
              floating: true,
              snap: true,
              flexibleSpace: Opacity(
                opacity: 1.0,
                child: FlexibleSpaceBar(
                  background: Container(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ];
        },
        body: const Transferdetail(),
      ),
    );
  }
}
