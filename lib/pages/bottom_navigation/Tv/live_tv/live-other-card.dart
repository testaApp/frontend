import 'package:flutter/material.dart';

import '../../../constants/text_utils.dart';
import 'live_tv_player.dart';

class LiveTvOtherCard extends StatelessWidget {
  final ImageProvider image;
  final String? videoUrl;
  final String? title;
  final VoidCallback? onTap;
  final bool isLive;

  const LiveTvOtherCard({
    super.key,
    required this.image,
    this.videoUrl,
    this.title,
    this.onTap,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 170,
      child: SizedBox(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _handleTap(context),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.35),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  _gradientOverlay(),
                  if (isLive) _liveBadge(),
                  if (title != null) _title(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAP HANDLER
  // ---------------------------------------------------------------------------
  VoidCallback? _handleTap(BuildContext context) {
    if (videoUrl == null && onTap == null) return null;

    return () {
      if (videoUrl != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(videoUrl: videoUrl!),
          ),
        );
      }
      onTap?.call();
    };
  }

  // ---------------------------------------------------------------------------
  // GRADIENT OVERLAY
  // ---------------------------------------------------------------------------
  Widget _gradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(.05),
            Colors.black.withOpacity(.35),
            Colors.black.withOpacity(.75),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE BADGE
  // ---------------------------------------------------------------------------
  Widget _liveBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _liveDot(),
            const SizedBox(width: 5),
            Text(
              'LIVE',
              style: TextUtils.setTextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: .4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(.8),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TITLE
  // ---------------------------------------------------------------------------
  Widget _title() {
    return Positioned(
      left: 10,
      right: 10,
      bottom: 10,
      child: Text(
        title!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextUtils.setTextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
