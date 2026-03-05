import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/main.dart';
import 'package:blogapp/models/leagues_page/top_scorer.model.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/leagues/pages/player_details_dialog.dart';
import 'package:blogapp/shared/constants/colors.dart';

// ignore: must_be_immutable
class ScorerRow extends StatelessWidget {
  final TopScorerModel scorerModel;
  final int index;
  final int rank;
  final bool removeNumber;

  const ScorerRow({
    super.key,
    required this.scorerModel,
    required this.index,
    required this.rank,
    this.removeNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    String playerName = '';
    String deviceLanguage = localLanguageNotifier.value;

    if (deviceLanguage == 'am' || deviceLanguage == 'tr') {
      playerName = scorerModel.name.amharicName?.isNotEmpty == true
          ? scorerModel.name.amharicName!
          : scorerModel.name.englishName ?? '';
    } else if (deviceLanguage == 'or') {
      playerName = scorerModel.name.oromoName?.isNotEmpty == true
          ? scorerModel.name.oromoName!
          : scorerModel.name.englishName ?? '';
    } else if (deviceLanguage == 'so') {
      playerName = scorerModel.name.somaliName?.isNotEmpty == true
          ? scorerModel.name.somaliName!
          : scorerModel.name.englishName ?? '';
    } else {
      playerName = scorerModel.name.englishName ?? '';
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PlayerDetailsDialog(
            player: scorerModel,
            deviceLanguage: deviceLanguage,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            if (!removeNumber) ...[
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color:
                      index < 3 ? Colorscontainer.greenColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: TextUtils.setTextStyle(
                      color: index < 3
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colorscontainer.greenColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: scorerModel.pic.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: scorerModel.pic,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.person,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/playershimmer.png',
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/playershimmer.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                playerName,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CachedNetworkImage(
                imageUrl: scorerModel.teamLogo,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Icons.sports_soccer,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.sports_soccer,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: index == 0
                    ? Colorscontainer.greenColor
                    : Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? Colorscontainer.greenColor.withOpacity(0.2)
                        : Colorscontainer.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                scorerModel.goal.toString(),
                style: TextUtils.setTextStyle(
                  color: index == 0 ? Colors.white : Colorscontainer.greenColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
