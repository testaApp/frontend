import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ← CRITICAL IMPORT

import 'package:blogapp/shared/constants/text_utils.dart';
import 'Highlight_player.dart';

class HighlightOtherCard extends StatefulWidget {
  final dynamic highlight; // Your Highlight model instance

  const HighlightOtherCard({
    super.key,
    required this.highlight,
  });

  @override
  State<HighlightOtherCard> createState() => _HighlightOtherCardState();
}

class _HighlightOtherCardState extends State<HighlightOtherCard> {
  bool _isHovered = false;

  // Extract YouTube video ID safely
  String? get _videoId {
    final url = widget.highlight.video?.toString();
    if (url == null || url.isEmpty) return null;
    return YoutubePlayer.convertUrlToId(url) ?? (url.length == 11 ? url : null);
  }

  // Try maxres, fallback to hqdefault
  String? get _thumbnailUrl {
    final id = _videoId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
  }

  String get _description {
    return widget.highlight.description ?? 'No description';
  }

  static final CacheManager _cacheManager = CacheManager(
    Config(
      'highlightOtherThumbnails',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
    ),
  );

  void _openPlayer() {
    final videoId = _videoId;
    if (videoId == null) {
      _showError('Invalid video');
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FastYouTubePlayer(videoUrl: videoId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _openPlayer();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 0.95 : 1.0),
        child: Container(
          width: 160.w,
          height: 220.h,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.35 : 0.2),
                blurRadius: _isHovered ? 24 : 16,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnail(),
                _buildGradientOverlay(),
                _buildPlayButton(),
                _buildTitle(),
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
      errorWidget: (_, __, ___) => CachedNetworkImage(
        imageUrl: 'https://img.youtube.com/vi/${_videoId}/hqdefault.jpg',
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildShimmerPlaceholder(),
        errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
      ),
      memCacheWidth: 480,
      memCacheHeight: 360,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.5)),
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
          Icon(Icons.sports_soccer, size: 48.w, color: Colors.grey[600]),
          SizedBox(height: 8.h),
          Text(
            'No Preview',
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
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
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
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
    );
  }

  Widget _buildTitle() {
    if (_description.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 12.h,
      left: 12.w,
      right: 12.w,
      child: Text(
        _description,
        style: TextUtils.setTextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
          shadows: const [
            Shadow(
              blurRadius: 8,
              color: Colors.black87,
              offset: Offset(0, 2),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
