import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/routenames.dart';
import '../../domain/player/playerName.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import '../../pages/bottom_navigation/favourites_page/favourites_page/player/details/player_position_translation.dart';
import '../../pages/constants/colors.dart';
import '../../pages/constants/text_utils.dart';
import '../../pages/functions/localisedPlayerName.dart';

Widget SubstitutesTable(List<PlayerName> substitutePlayers) {
  return Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        // Table Header (unchanged)
        Container(
          padding: EdgeInsets.symmetric(vertical: 25.h),
          child: Row(
            children: [
              SizedBox(
                width: 120.w,
                child: Text(DemoLocalizations.jerseyNumber,
                    style: TextUtils.setTextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                width: 80.w,
                child: Text(DemoLocalizations.name,
                    style: TextUtils.setTextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                width: 80.w,
                child: Text(DemoLocalizations.playground,
                    style: TextUtils.setTextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),

        // Table Body
        ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: substitutePlayers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final player = substitutePlayers[index];

            // QUICK FIX: Use language-based selection with fallback
            final lang =
                localLanguageNotifier.value; // ← make sure this is accessible

            String name = switch (lang) {
              'am' || 'tr' => player.amharicName.isNotEmpty
                  ? player.amharicName
                  : (player.name ?? 'Unknown'),
              'or' => player.oromoName.isNotEmpty
                  ? player.oromoName
                  : (player.englishName.isNotEmpty
                      ? player.englishName
                      : player.name ?? 'Unknown'),
              'so' => player.somaliName.isNotEmpty
                  ? player.somaliName
                  : (player.englishName.isNotEmpty
                      ? player.englishName
                      : player.name ?? 'Unknown'),
              _ => player.englishName.isNotEmpty
                  ? player.englishName
                  : player.name ?? 'Unknown', // English default
            };

            String translatedPosition = player.position != null
                ? PlayerPositionTranslation.translatePosition(player.position!)
                : '';

            return GestureDetector(
              onTap: () {
                context.pushNamed(RouteNames.playerProfilbyName, extra: player);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Player Number
                    SizedBox(
                      width: 40.w,
                      child: Center(
                        child: Text(
                          player.number?.toString() ?? '',
                          style: TextUtils.setTextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    // Player Image + Name
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage: CachedNetworkImageProvider(
                              'https://media.api-sports.io/football/players/${player.id}.png',
                            ),
                            backgroundColor: Colors.grey.shade200,
                            child: player.id == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Flexible(
                            child: Text(
                              name.trim(),
                              style: TextUtils.setTextStyle(fontSize: 14.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Position
                    SizedBox(
                      width: 80.w,
                      child: Text(
                        translatedPosition,
                        style: TextUtils.setTextStyle(fontSize: 12.sp),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 6.h),
        ),
      ],
    ),
  );
}
