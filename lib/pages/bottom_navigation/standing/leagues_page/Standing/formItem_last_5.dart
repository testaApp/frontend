import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../components/routenames.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../models/standings/standings.dart';
import '../../../../../models/teamName.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';

class FormItem extends StatelessWidget {
  final TableItem tableItem;
  final Color color;

  const FormItem({super.key, required this.tableItem, required this.color});

  @override
  Widget build(BuildContext context) {
    final nameWidth = MediaQuery.of(context).size.width / 2.4;
    // String amharicName = getNameById(tableItem.id);

    List<Widget> widgetList = [];

    for (int i = 0; i < tableItem.form.length; i++) {
      final letter = tableItem.form[i];
      if (i == tableItem.form.length - 1 && letter == 'W') {
        widgetList.add(Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 18.w,
              decoration: BoxDecoration(
                  color: Colorscontainer.greenColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.r))),
              child: Text(
                DemoLocalizations.w,
                textAlign: TextAlign.center,
                style: TextUtils.setTextStyle(
                    color: Colors.white, fontSize: 15.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 18.w,
                  height: 2,
                  color: Colorscontainer.greenColor,
                ),
              ),
            )
          ],
        ));
      } else if (i == tableItem.form.length - 1 && letter == 'D') {
        widgetList.add(Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 18.w,
              decoration: BoxDecoration(
                  color: Colorscontainer.greenColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.r))),
              child: Text(
                DemoLocalizations.w,
                textAlign: TextAlign.center,
                style: TextUtils.setTextStyle(
                    color: Colors.white, fontSize: 15.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 18.w,
                  height: 2,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ));
      } else if (i == tableItem.form.length - 1 && letter == 'L') {
        widgetList.add(Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 18.w,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(5.r))),
              child: Text(
                DemoLocalizations.l,
                textAlign: TextAlign.center,
                style: TextUtils.setTextStyle(
                    color: Colors.white, fontSize: 15.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 18.w,
                  height: 2,
                  color: Colors.red,
                ),
              ),
            )
          ],
        ));
      } else if (letter == 'W') {
        widgetList.add(Container(
          width: 18.w,
          decoration: BoxDecoration(
              color: Colorscontainer.greenColor,
              borderRadius: BorderRadius.all(Radius.circular(5.r))),
          child: Text(
            DemoLocalizations.w,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ));
      } else if (letter == 'D') {
        widgetList.add(Container(
          width: 18.w,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(5.r))),
          child: Text(
            DemoLocalizations.d,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ));
      } else if (letter == 'L') {
        widgetList.add(Container(
          width: 18.w,
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(5.r))),
          child: Text(
            DemoLocalizations.l,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ));
      }
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteNames.teamProfilePage,
            extra: TeamName(
                id: tableItem.id,
                logo: tableItem.avatar,
                amharicName: tableItem.name,
                oromoName: tableItem.name,
                somaliName: tableItem.name,
                englishName: tableItem.name));
      },
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3.w),
                  bottomRight: Radius.circular(3.w)),
              child: Container(
                height: 26.h,
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(
                  color: color,
                  width: 3.w,
                ))),
              ),
            ),
          ),
          Container(
            height: 20.h,
            width: 27.0.w,
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${tableItem.position}',
                style: TextUtils.setTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CachedNetworkImage(
              imageUrl: tableItem.avatar,
              width: 20.r,
              height: 20.h,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          SizedBox(
            width: nameWidth,
            child: Text(
              // amharicName == "" ?

              tableItem.name
              //  :amharicName
              ,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextUtils.setTextStyle(
                fontSize: 15.sp,
                // fontWeight: FontWeight.w400 ,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: 160.w,
              padding: EdgeInsets.only(top: 3.h),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgetList),
            ),
          ),
          SizedBox(
            width: 10.w,
          )
        ],
      ),
    );
  }
}
