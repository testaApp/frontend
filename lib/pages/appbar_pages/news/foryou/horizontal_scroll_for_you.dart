import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/timeFormatter.dart';
import '../../../../models/news.dart';
import '../../../constants/text_utils.dart';
import '../main_news/news_detail.dart';

class HorizontalNewsCard extends StatelessWidget {
  final News news;

  const HorizontalNewsCard({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      height: 300.h,
      width: 300.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(news: news),
                ),
              ),
              child: Column(
                children: [
                  if (news.mainImages.isNotEmpty)
                    SizedBox(
                      height: 180.h,
                      child: _buildImageSection(theme),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(theme),
                          const Spacer(),
                          _buildSourceInfo(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'news_image_${news.id}',
          child: CachedNetworkImage(
            imageUrl: news.mainImages.first.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildShimmerLoader(theme),
            errorWidget: (context, url, error) => _buildErrorWidget(theme),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      news.summarizedTitle ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextUtils.setTextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSourceInfo(ThemeData theme) {
    return Row(
      children: [
        if (news.sourceimage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              imageUrl: news.sourceimage!,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Text(
            news.sourcename ?? '',
            style: TextUtils.setTextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14.sp,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          formatTimeForNews(news.time),
          style: TextUtils.setTextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextUtils.setTextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
