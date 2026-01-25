import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../components/routenames.dart';
import '../models/standings/standings.dart';
import '../models/teamName.dart';
import '../pages/constants/text_utils.dart';

Widget tablesItem(
    BuildContext context, TableItem tableItem, double nameWidth, Color color,
    {bool teamProfile = false}) {
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
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        Padding(
          padding: teamProfile
              ? const EdgeInsets.only(left: 10, right: 4)
              : const EdgeInsets.symmetric(horizontal: 4.0),
          child: CachedNetworkImage(
            imageUrl: tableItem.avatar,
            width: 20.w,
            height: 20.w,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        SizedBox(
          width: nameWidth,
          child: Text(
            tableItem.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextUtils.setTextStyle(
              fontSize: 15.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 30.w,
            child: Text(
              tableItem.gamePlayed.toString(),
              style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 16.h,
              width: 60.0.w,
              padding: EdgeInsets.symmetric(horizontal: 3.0.w),
              child: Text(
                "${tableItem.goalDifference > 0 ? '+' : ''}${tableItem.goalDifference.toString()}",
                style: TextUtils.setTextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: SizedBox(
              width: 32.0.w,
              child: Text(
                tableItem.point.toString(),
                textAlign: TextAlign.center,
                style: TextUtils.setTextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
        )
      ],
    ),
  );
}
