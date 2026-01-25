import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/player/player.model.dart';
import '../../main.dart';
import '../../models/fixtures/lineups.dart';
import '../../pages/constants/text_utils.dart';

class LineupsWgt extends StatelessWidget {
  const LineupsWgt({super.key, required this.lineup});

  final Lineup lineup;

  @override
  Widget build(BuildContext context) {
    final formationRows =
        lineup.formation.split('-').map((e) => int.tryParse(e) ?? 0).toList();

    int playerIndex = 0;

    return SizedBox(
      height: 520.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Pitch background
          Positioned.fill(
            child: Image.asset(
              'assets/football.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Responsive player layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: formationRows.map((playersInRow) {
                final rowPlayers = lineup.players
                    .skip(playerIndex)
                    .take(playersInRow)
                    .toList();
                playerIndex += playersInRow;

                return Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: rowPlayers.map((player) {
                      return buildPlayerTileWithSpacing(player, playersInRow);
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlayerTileWithSpacing(Player player, int playersInRow) {
    final double horizontalPadding = playersInRow >= 5 ? 5.w : 8.w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: buildPlayerTile(player, playersInRow),
    );
  }

  Widget buildPlayerTile(Player player, int playersInRow) {
    final photoUrl = player.photo ??
        'https://media.api-sports.io/football/players/${player.id}.png';

    final jerseyNumber = player.number?.toString() ?? '?';

    // ── QUICK FIX: Choose name based on current language ───────────────────────
    // Inside buildPlayerTile
    final lang = localLanguageNotifier.value;

    final localizedName = switch (lang) {
      'am' || 'tr' => player.localized?['amharic'] ?? player.name ?? 'Unknown',
      'or' => player.localized?['oromo'] ??
          player.localized?['english'] ??
          player.name ??
          'Unknown',
      'so' => player.localized?['somali'] ??
          player.localized?['english'] ??
          player.name ??
          'Unknown',
      _ => player.localized?['english'] ?? player.name ?? 'Unknown',
    };
    // Responsive sizing
    final double maxTileWidth = playersInRow >= 5 ? 45.w : 50.w;
    final double avatarRadius = playersInRow >= 5 ? 14.r : 16.r;
    final double nameFontSize = playersInRow >= 5 ? 7.sp : 8.sp;
    final double numberFontSize = playersInRow >= 5 ? 10.sp : 11.sp;
    final double nameWidth = playersInRow >= 5 ? 35.w : 40.w;

    return Container(
      constraints: BoxConstraints(maxWidth: maxTileWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10.r),
              border:
                  Border.all(color: Colors.white.withOpacity(0.18), width: 0.7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiny avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3.r,
                        offset: Offset(0, 1.5.h),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                    child: (player.photo == null &&
                            !photoUrl.contains('api-sports.io'))
                        ? Icon(Icons.person,
                            size: avatarRadius * 1.2,
                            color: Colors.grey.shade400)
                        : null,
                  ),
                ),
                SizedBox(height: 4.h),
                // Jersey number
                Text(
                  jerseyNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: numberFontSize,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 1.5,
                        color: Colors.black87,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                // Player name
                SizedBox(
                  width: nameWidth,
                  child: Text(
                    localizedName,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      color: Colors.white,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      shadows: [
                        const Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 1.5,
                          color: Colors.black87,
                        )
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
