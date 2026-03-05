// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:blogapp/models/program_card/PodcastModel.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

import 'package:blogapp/features/enadamt/pages/enadamt/program_detail_page.dart';

class LivePodcastWidget extends StatefulWidget {
  final PodcastModel podcast;
  final Function() onClose;

  const LivePodcastWidget({
    super.key,
    required this.podcast,
    required this.onClose,
  });

  @override
  State<LivePodcastWidget> createState() => _LivePodcastWidgetState();
}

class _LivePodcastWidgetState extends State<LivePodcastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<double> _animation = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            // Hide the podcast first
            widget.onClose();

            // Then navigate to the podcast page
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Program(
                  id: widget.podcast.id,
                  avatar: widget.podcast.avatar,
                  name: widget.podcast.name,
                  program: widget.podcast.program,
                  rssLink: widget.podcast.rssLink,
                  description: widget.podcast.description,
                  time: const [],
                  liveLink: widget.podcast.liveLink,
                  station: widget.podcast.station,
                  isProgram: widget.podcast.isLive,
                  programId: widget.podcast.programId, // PASS THE PROGRAM ID
                ),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => Hero(
                  tag: 'podcast_${widget.podcast.id}',
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(_animation.value),
                        width: 1.5.w,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.5.w),
                      child: CachedNetworkImage(
                        imageUrl: widget.podcast.avatar,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmerLoader(),
                        errorWidget: (context, url, error) =>
                            _buildErrorWidget(),
                      ),
                    ),
                  ),
                ),
              ),
              // Live label
              Positioned(
                bottom: -8.h,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.red.withOpacity(0.3 * _animation.value),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        'LIVE',
                        style: TextUtils.setTextStyle(
                          fontSize: 8.sp,
                          color: Colors.white.withOpacity(_animation.value),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: -6.h,
                right: -6.w,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        size: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        color: Colors.black,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white.withOpacity(0.5),
          size: 24.sp,
        ),
      ),
    );
  }
}
