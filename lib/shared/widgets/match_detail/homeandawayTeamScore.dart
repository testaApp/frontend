import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/functions/localised_player_name.dart';

class HomeTeamEvent extends StatelessWidget {
  const HomeTeamEvent({
    super.key,
    required this.assistPlayer,
    required this.extra,
    required this.detail,
    required this.mainPlayer,
    required this.minutes,
    required this.type,
    this.comments,
  });

  final PlayerName mainPlayer;
  final PlayerName? assistPlayer;
  final String minutes;
  final String type;
  final String detail;
  final int? extra;
  final String? comments;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: PlayersNameWgt(
                  detail: detail,
                  mainPlayer: mainPlayer,
                  type: type,
                  assistPlayer: assistPlayer,
                  comments: comments,
                ),
              ),
              SizedBox(width: 4.w),
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.black,
                  child: GestureDetector(
                    onTap: () {
                      if (assistPlayer != null &&
                          detail.contains('Substitution')) {
                        context.pushNamed(RouteNames.playerProfilbyName,
                            extra: assistPlayer);
                      } else if (!detail.contains('Substitution')) {
                        context.pushNamed(RouteNames.playerProfilbyName,
                            extra: mainPlayer);
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colorscontainer.greenColor,
                      backgroundImage: CachedNetworkImageProvider(detail
                                  .contains('Substitution') &&
                              assistPlayer != null
                          ? 'https://media.api-sports.io/football/players/${assistPlayer!.id}.png'
                          : 'https://media.api-sports.io/football/players/${mainPlayer.id}.png'),
                      radius: 11.r,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              SizedBox(
                width: 16.w,
                child: EventPhotoMatch(eventDetail: detail),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            extra == null ? "$minutes'" : "$minutes'+$extra",
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
            ),
          ),
        ),
        const Expanded(
          flex: 4,
          child: SizedBox(),
        ),
      ],
    );
  }
}

class AwayTeamEvent extends StatelessWidget {
  const AwayTeamEvent({
    super.key,
    required this.assistPlayer,
    required this.detail,
    required this.extra,
    required this.mainPlayer,
    required this.minutes,
    required this.type,
    this.comments,
  });

  final PlayerName mainPlayer;
  final PlayerName? assistPlayer;
  final String minutes;
  final String type;
  final String detail;
  final int? extra;
  final String? comments;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          flex: 4,
          child: SizedBox(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            extra == null ? "$minutes'" : "$minutes'+$extra",
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 16.w,
                child: EventPhotoMatch(eventDetail: detail),
              ),
              SizedBox(width: 4.w),
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.black,
                  child: GestureDetector(
                    onTap: () {
                      if (assistPlayer != null &&
                          detail.contains('Substitution')) {
                        context.pushNamed(RouteNames.playerProfilbyName,
                            extra: assistPlayer);
                      } else if (!detail.contains('Substitution')) {
                        context.pushNamed(RouteNames.playerProfilbyName,
                            extra: mainPlayer);
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colorscontainer.greenColor,
                      backgroundImage: CachedNetworkImageProvider(detail
                                  .contains('Substitution') &&
                              assistPlayer != null
                          ? 'https://media.api-sports.io/football/players/${assistPlayer!.id}.png'
                          : 'https://media.api-sports.io/football/players/${mainPlayer.id}.png'),
                      radius: 11.r,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: PlayersNameWgt(
                  detail: detail,
                  mainPlayer: mainPlayer,
                  type: type,
                  assistPlayer: assistPlayer,
                  homeTeam: false,
                  comments: comments,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventPhotoMatch extends StatelessWidget {
  const EventPhotoMatch({super.key, required this.eventDetail});
  final String eventDetail;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper for Ball Icon
    Widget ballIcon() {
      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: Center(
          child: Text(
            '⚽',
            style: TextStyle(
              fontSize: 14.w, // Slightly smaller than the box to avoid clipping
              height: 1, // Ensures no extra line-height spacing
            ),
          ),
        ),
      );
    }

    // Helper for VAR Icon

    Widget varIcon(String detail) {
      bool isCancelled =
          detail.contains('cancelled') || detail.contains('disallowed');
      bool isConfirmed = detail.contains('confirmed');

      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: Stack(
          children: [
            // 1. The Base VAR Icon
            Align(
              alignment: Alignment.center,
              child: Text(
                '🖥️',
                style: TextStyle(
                  fontSize: 14.w,
                  height: 1,
                ),
              ),
            ),
            // 2. The Status Overlay (Bottom Right)
            if (isCancelled || isConfirmed)
              Positioned(
                bottom: -1,
                right: -1,
                child: Text(
                  isCancelled ? '❌' : '✅',
                  style: TextStyle(
                    fontSize: 8.w, // Very small to fit on the TV screen corner
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final String detail = eventDetail.trim().toLowerCase();

    // 1. Goal Events
    if (detail == 'normal goal' || detail == 'own goal') {
      return ballIcon();
    }

    // 2. Penalty Scored
// 1. Scored Penalty
    if (detail == 'penalty' ||
        (detail.contains('penalty') &&
            !detail.contains('missed') &&
            !detail.contains('cancelled'))) {
      return Text(
        '🥅',
        style: TextStyle(
          fontSize: 16.w,
          height: 1,
        ),
      );
    }

// 2. Missed Penalty (Stacked Emoji)
    if (detail.contains('missed')) {
      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: Stack(
          children: [
            // The Base Penalty Icon
            Align(
              alignment: Alignment.center,
              child: Text(
                '🥅',
                style: TextStyle(fontSize: 14.w),
              ),
            ),
            // The "X" overlay on the bottom left
            Positioned(
              bottom: -4, // Slight adjustment for emoji padding
              right: -1,
              child: Text(
                '❌',
                style: TextStyle(
                  fontSize: 10.w, // Smaller X
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 4. Cards
    if (detail == 'yellow card') {
      return Image.asset('assets/yellow_card.png', width: 16.w, height: 16.w);
    }
    if (detail == 'red card') {
      return Image.asset('assets/red_card.png', width: 16.w, height: 16.w);
    }

    // 5. Substitution
    if (detail.contains('substitution')) {
      return Image.asset('assets/substitute.png', width: 16.w, height: 16.w);
    }

    // 6. VAR Events (Added 'disallowed' to the check)
    if (detail.contains('var') ||
        detail.contains('confirmed') ||
        detail.contains('cancelled') ||
        detail.contains('disallowed')) {
      return varIcon(detail);
    }

    return Text('-',
        style: TextUtils.setTextStyle(color: Colorscontainer.greenColor));
  }
}

class PlayersNameWgt extends StatelessWidget {
  const PlayersNameWgt({
    super.key,
    required this.detail,
    required this.mainPlayer,
    required this.type,
    required this.assistPlayer,
    this.homeTeam = true,
    this.comments,
  });

  final String detail;
  final PlayerName mainPlayer;
  final PlayerName? assistPlayer;
  final String type;
  final bool homeTeam;
  final String? comments;

  @override
  Widget build(BuildContext context) {
    String mainPlayerName = getLocalPlayerName(mainPlayer);
    String? assistPlayerName =
        assistPlayer != null ? getLocalPlayerName(assistPlayer!) : null;

    String? getLocalizedComment(String? comment) {
      if (comment == null) return null;

      final c = comment.toLowerCase().trim();

      // Map common card comments to DemoLocalizations
      switch (c) {
        case 'foul':
          return DemoLocalizations.foul;
        case 'argument':
          return DemoLocalizations.argument;
        case 'handball':
          return DemoLocalizations.handball;
        case 'violent conduct':
          return DemoLocalizations.violent_conduct;
        case 'diving':
          return DemoLocalizations.diving;
        case 'time wasting':
        case 'timewasting':
          return DemoLocalizations.time_wasting;
        case 'unsporting behavior':
        case 'unsporting behaviour':
          return DemoLocalizations.unsporting_behavior;
        case 'second yellow':
        case 'second yellow card':
          return DemoLocalizations.second_yellow;
        case 'professional foul':
          return DemoLocalizations.professional_foul;
        case 'professional foul last man':
          return DemoLocalizations.professional_foul_last_man;
        case 'off side':
          return DemoLocalizations.offside;
        case 'dangerous play':
          return DemoLocalizations.dangerous_play;
        case 'off the ball foul':
          return DemoLocalizations.off_the_ball_foul;
        case 'vAR review':
          return DemoLocalizations.var_review;
        case 'obstruction':
          return DemoLocalizations.obstruction;
        case 'spitting':
          return DemoLocalizations.spitting;
        case 'biting':
          return DemoLocalizations.biting;
        case 'elbowing':
          return DemoLocalizations.elbowing;
        case 'abusive language':
          return DemoLocalizations.abusive_language;
        case 'retaliation':
          return DemoLocalizations.retaliation;
        case 'penalty awarded':
          return DemoLocalizations.penalty_awarded;
        case 'goal disallowed':
          return DemoLocalizations.goal_disallowed;
        case 'excessive celebration':
          return DemoLocalizations.excessive_celebration;
        case 'unsportsmanlike conduct':
          return DemoLocalizations.unsportsmanlike_conduct;
        case 'holding':
          return DemoLocalizations.holding;
        case 'tripping':
          return DemoLocalizations.foul;
        default:
          // Return original comment if no localization is found
          return comment;
      }
    }

    String? getSubLabel() {
      final d = detail.toLowerCase().trim();

      // VAR Labels
      // VAR / Disallowed Labels
      if (d.contains('disallowed')) {
        if (d.contains('offside')) {
          return '${DemoLocalizations.goal_disallowed} - ${DemoLocalizations.offside}';
        }
        return DemoLocalizations.goal_disallowed;
      }
      if (d == 'goal cancelled') return DemoLocalizations.goalCancelled;
      if (d == 'penalty cancelled') return DemoLocalizations.penalty_cancelled;
      if (d == 'penalty confirmed') return DemoLocalizations.penality;
      if (d == 'card upgrade') return DemoLocalizations.card_upgrade;

      // Penalty Labels - Different for scored vs missed
      if (d.contains('missed') && d.contains('penalty')) {
        return DemoLocalizations.penalty_missed;
      }

      // Card Labels - Show localized comments if available
      if (d == 'yellow card' || d == 'red card') {
        return getLocalizedComment(comments);
      }

      return null;
    }

    // SUBSTITUTION UI
    if (detail.contains('Substitution')) {
      return Column(
        crossAxisAlignment:
            homeTeam ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // SUB IN (assist player) - shown FIRST
          if (assistPlayerName != null) ...[
            Row(
              mainAxisAlignment:
                  homeTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!homeTeam) ...[
                  Icon(Icons.arrow_downward,
                      size: 12.w, color: Colorscontainer.greenColor),
                  SizedBox(width: 4.w),
                ],
                Flexible(
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                        RouteNames.playerProfilbyName,
                        extra: assistPlayer),
                    child: Text(
                      assistPlayerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: homeTeam ? TextAlign.right : TextAlign.left,
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (homeTeam) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_downward,
                      size: 12.w, color: Colorscontainer.greenColor),
                ],
              ],
            ),
            SizedBox(height: 2.h),
          ],
          // SUB OUT (main player) - shown SECOND
          Row(
            mainAxisAlignment:
                homeTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!homeTeam) ...[
                Icon(Icons.arrow_upward, size: 12.w, color: Colors.red),
                SizedBox(width: 4.w),
              ],
              Flexible(
                child: GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.playerProfilbyName,
                      extra: mainPlayer),
                  child: Text(
                    mainPlayerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: homeTeam ? TextAlign.right : TextAlign.left,
                    style: TextUtils.setTextStyle(fontSize: 10.sp),
                  ),
                ),
              ),
              if (homeTeam) ...[
                SizedBox(width: 4.w),
                Icon(Icons.arrow_upward, size: 12.w, color: Colors.red),
              ],
            ],
          ),
        ],
      );
    }

    // GOAL UI (successful goals only)
    else if (type.toLowerCase() == 'goal' &&
        !detail.toLowerCase().contains('missed') &&
        !detail.toLowerCase().contains('cancelled')) {
      return Column(
        crossAxisAlignment:
            homeTeam ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.playerProfilbyName,
                extra: mainPlayer),
            child: Text(
              mainPlayerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: homeTeam ? TextAlign.right : TextAlign.left,
              style: TextUtils.setTextStyle(),
            ),
          ),
          // Show assist if available
          if (assistPlayerName != null)
            Row(
              mainAxisAlignment:
                  homeTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!homeTeam) ...[
                  Image.asset('assets/chama.png',
                      width: 15.w, color: Colorscontainer.greenColor),
                  SizedBox(width: 5.w),
                ],
                Flexible(
                  child: Text(
                    assistPlayerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: homeTeam ? TextAlign.right : TextAlign.left,
                    style: TextUtils.setTextStyle(fontSize: 10.sp),
                  ),
                ),
                if (homeTeam) ...[
                  SizedBox(width: 5.w),
                  Image.asset('assets/chama.png',
                      width: 15.w, color: Colorscontainer.greenColor),
                ],
              ],
            ),
          // Show penalty label ONLY if it's a penalty goal
          if (detail.toLowerCase().trim() == 'penalty')
            Text(
              DemoLocalizations.penalty_scored,
              textAlign: homeTeam ? TextAlign.right : TextAlign.left,
              style: TextUtils.setTextStyle(
                fontSize: 10.sp,
                color: Colorscontainer.greenColor,
              ),
            ),
        ],
      );
    }

    // VAR / MISSED PENALTY / CARDS / DEFAULT UI
    final subLabel = getSubLabel();
    return Column(
      crossAxisAlignment:
          homeTeam ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.playerProfilbyName,
              extra: mainPlayer),
          child: Text(
            mainPlayerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: homeTeam ? TextAlign.right : TextAlign.left,
            style: TextUtils.setTextStyle(),
          ),
        ),
        if (subLabel != null)
          Text(
            subLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: homeTeam ? TextAlign.right : TextAlign.left,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              color: detail.toLowerCase().contains('cancelled') ||
                      detail.toLowerCase().contains('missed')
                  ? Colors.red
                  : Colors.grey,
            ),
          ),
      ],
    );
  }
}
