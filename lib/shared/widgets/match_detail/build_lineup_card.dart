import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/domain/player/player.model.dart';
import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

Widget buildPlayerRow(List<Player> filteredPlayers, int totalItems, int index,
    List<PlayerName> playerNames, BuildContext context) {
  double playerWidth =
      index < 2 ? 340 / filteredPlayers.length : 280 / filteredPlayers.length;
  double rowHeight = 420 / totalItems;

  return SizedBox(
    height: rowHeight.h,
    width: index < 2 ? 280.w : 340.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: filteredPlayers
          .map((player) =>
              buildPlayerTile(player, playerWidth, playerNames, context))
          .toList(),
    ),
  );
}

Widget buildPlayerTile(Player player, double playerWidth,
    List<PlayerName> playerNames, BuildContext context) {
  // Get user's preferred language
  String localLanguage = localLanguageNotifier.value;

  // Find the PlayerName that matches the Player id
  PlayerName plName = playerNames.firstWhere((pl) => pl.id == player.id,
      orElse: () => PlayerName(
            id: player.id ?? -1,
            amharicName: player.name ?? '',
            englishName: player.name ?? '',
            oromoName: player.name ?? '',
            somaliName: player.name ?? '',
            photo: player.photo ?? '',
          ));

  // Choose name based on user's language
  String displayName;
  if (localLanguage == 'am' || localLanguage == 'tr') {
    displayName =
        plName.amharicName.isNotEmpty ? plName.amharicName : plName.englishName;
  } else if (localLanguage == 'or') {
    displayName =
        plName.oromoName.isNotEmpty ? plName.oromoName : plName.englishName;
  } else if (localLanguage == 'so') {
    displayName =
        plName.somaliName.isNotEmpty ? plName.somaliName : plName.englishName;
  } else {
    displayName = plName.englishName;
  }

  return GestureDetector(
    onTap: () {
      context.pushNamed(RouteNames.playerProfile, extra: plName);
    },
    child: SizedBox(
      width: playerWidth.w,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(plName.photo ?? ''),
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayName, // << Now uses the preferred language
              textAlign: TextAlign.center,
              style:
                  TextUtils.setTextStyle(color: Colors.white, fontSize: 12.sp),
              overflow: TextOverflow.clip,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  );
}
