import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'live_tv_player.dart';

class LiveSpecialCard extends StatelessWidget {
  final String? logoUrl;
  final String? channelName;
  final String? groupTitle;
  final String? videoUrl;

  const LiveSpecialCard({
    super.key,
    this.logoUrl,
    this.channelName,
    this.groupTitle,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SizedBox(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _openPlayer(context),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.45),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _imageBackground(),
                  _gradientOverlay(),
                  _content(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE BACKGROUND (FILLS CARD)
  // ---------------------------------------------------------------------------
  Widget _imageBackground() {
    return logoUrl != null
        ? Image.network(
            logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          )
        : Container(color: Colors.black);
  }

  // ---------------------------------------------------------------------------
  // GRADIENT OVERLAY (PRESERVES LOOK)
  // ---------------------------------------------------------------------------
  Widget _gradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(.15),
            Colors.black.withOpacity(.45),
            Colors.black.withOpacity(.75),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------
  Widget _content() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topMeta(),
          const Spacer(),
          _info(),
          SizedBox(height: 14.h),
          _cta(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // META (CATEGORY CHIP)
  // ---------------------------------------------------------------------------
  Widget _topMeta() {
    if (groupTitle == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        groupTitle!,
        style: TextUtils.setTextStyle(
          color: Colors.white.withOpacity(.95),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFO
  // ---------------------------------------------------------------------------
  Widget _info() {
    return Text(
      channelName ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextUtils.setTextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA
  // ---------------------------------------------------------------------------
  Widget _cta() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow_rounded,
            color: Colorscontainer.greenColor,
            size: 26,
          ),
          const SizedBox(width: 6),
          Text(
            'Watch',
            style: TextUtils.setTextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------
  VoidCallback? _openPlayer(BuildContext context) {
    if (videoUrl == null) return null;
    return () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPlayerPage(videoUrl: videoUrl!),
        ),
      );
    };
  }
}
