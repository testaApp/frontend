import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:blogapp/shared/constants/text_utils.dart';
import 'Highlight_player.dart';

class HighlightSpecialCard extends StatelessWidget {
  final String? videoUrl;
  final String? description;

  const HighlightSpecialCard({
    super.key,
    this.videoUrl,
    this.description,
  });

  String? get _videoId =>
      YoutubePlayer.convertUrlToId(videoUrl ?? '') ?? videoUrl;

  String? get _thumbnailUrl {
    final id = _videoId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  static final CacheManager _cacheManager = CacheManager(
    Config(
      'highlightThumbnails',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _handleTap(context),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          height: 220.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnail(),
                _buildGradientOverlay(),
                _buildContent(context), // Play button + description
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (_thumbnailUrl == null) {
      return _buildErrorPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: _thumbnailUrl!,
      fit: BoxFit.cover,
      cacheManager: _cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => _buildShimmerPlaceholder(),
      errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
      memCacheWidth: 800,
      memCacheHeight: 600,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 60.w, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'No Preview',
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.3, 0.6, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Stack(
        children: [
          // Play Button (Centered in the Stack)
          Center(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.6), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 25.w,
              ),
            ),
          ),

          // Description (Aligned to the bottom)
          if (description != null && description!.trim().isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                description!.trim(),
                style: TextUtils.setTextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final videoId = _videoId;

    if (videoId != null && videoId.length == 11) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FastYouTubePlayer(videoUrl: videoId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid or missing video'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
