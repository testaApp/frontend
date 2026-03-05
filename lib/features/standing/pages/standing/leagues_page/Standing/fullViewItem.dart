import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/models/standings/standings.dart';
import 'package:blogapp/models/teamName.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class FullViewItem extends StatelessWidget {
  final TableItem tableItem;
  final Color color;

  const FullViewItem({super.key, required this.tableItem, required this.color});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Row(
          children: [
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
              padding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '${tableItem.position}',
                  style: TextUtils.setTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0.sp,
                      color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0.w),
              child: CachedNetworkImage(
                imageUrl: tableItem.avatar,
                width: 20.w,
                height: 20.h,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            SizedBox(
              width: 130.w,
              child: Text(
                tableItem.name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextUtils.setTextStyle(
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tableItem.gamePlayed.toString(),
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  tableItem.won.toString(),
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  tableItem.draw.toString(),
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  tableItem.lost.toString(),
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${tableItem.scored.toString()}-${tableItem.conceded.toString()}',
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  tableItem.goalDifference.toString(),
                  style: TextUtils.setTextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  tableItem.point.toString(),
                  style: TextUtils.setTextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
