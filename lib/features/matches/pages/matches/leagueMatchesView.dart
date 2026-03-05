import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:blogapp/models/fixtures/stat.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'match_results_list.dart';

class LeagueMatches extends StatelessWidget {
  final String leagueName;
  final List<Stat> matches;
  final Color? color;

  final String logo;
  const LeagueMatches(
      {super.key,
      required this.matches,
      required this.leagueName,
      required this.logo,
      this.color});

  String _getCorrectMatchStatus(Stat match) {
    if (match.dateString == null) return '';

    final matchDate = DateTime.parse(match.dateString!);
    final now = DateTime.now().toUtc();
    final isMatchInPast = now.difference(matchDate).inHours >= 3;

    // Handle special statuses
    final unchangeableStatuses = [
      'PST',
      'CANC',
      'ABD',
      'AWD',
      'TBD',
      'WO',
      'SUSP',
      'INT',
      'AET',
      'PEN'
    ];

    if (unchangeableStatuses.contains(match.status)) {
      return match.status ?? '';
    }

    // Force FT status for past matches
    if (isMatchInPast &&
        ['1H', '2H', 'HT', 'LIVE', '', null].contains(match.status)) {
      return 'FT';
    }

    return match.status ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final liveMatchStatuses = ['1H', '2H', 'ET', 'P', 'LIVE'];

    final liveMatchesCount = matches.where((match) {
      final correctStatus = _getCorrectMatchStatus(match);

      // If the corrected status is FT or special status, it's not live
      if (correctStatus == 'FT' || correctStatus == 'AET') {
        return false;
      }

      final isLiveStatus = liveMatchStatuses.contains(correctStatus);
      final hasElapsedTime = match.elapsed != null && match.elapsed! > 0;

      return isLiveStatus && hasElapsedTime;
    }).length;

    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Container(
        width: 330.w,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15), bottom: Radius.circular(15)),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2E)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Theme(
          data: theme,
          child: ListTileTheme(
            contentPadding: EdgeInsets.zero,
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
              initiallyExpanded: false,
              title: SizedBox(
                height: 28.r,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 🌟 Stroke Layer (larger, solid white version of the logo)
                              CachedNetworkImage(
                                imageUrl: logo,
                                // Increased thickness from +4 to +8
                                height: 35.h + 8,
                                width: 35.w + 8,
                                fit: BoxFit.contain,
                                color: Colors
                                    .white, // Stroke Color (White is bright)
                                placeholder: (context, url) => Container(
                                  height: 35.h + 8,
                                  width: 35.w + 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.sports_soccer,
                                  size: 25.sp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),
                              // Subtle glow effect layer
                              CachedNetworkImage(
                                imageUrl: logo,
                                height: 35.h,
                                width: 35.w,
                                fit: BoxFit.contain,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.white.withOpacity(0.05),
                                placeholder: (context, url) => Container(
                                  height: 35.h,
                                  width: 35.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.sports_soccer,
                                  size: 25.sp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),

                              // Original Logo Layer (on top of the stroke)
                              CachedNetworkImage(
                                imageUrl: logo,
                                height: 35.h,
                                width: 35.w,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Container(
                                  height: 35.h,
                                  width: 35.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.sports_soccer,
                                  size: 25.sp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            leagueName,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 0.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (liveMatchesCount > 0) ...[
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '●',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '$liveMatchesCount',
                                  style: TextUtils.setTextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' | ',
                                  style: TextUtils.setTextStyle(
                                    fontSize: 11.sp,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                              Text(
                                '${matches.length}',
                                style: TextUtils.setTextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              iconColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[700],
              collapsedIconColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
              tilePadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 0),
              children: [
                const Divider(
                  color: Colors.grey,
                ),
                MatchLists(
                  statList: matches,
                  leagueName: leagueName,
                )
              ],
            ),
          ),
        ));
  }
}
