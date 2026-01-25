import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/timeFormatter.dart';
import '../../../../models/news.dart';
import '../../../../util/baseUrl.dart';
import '../../../constants/text_utils.dart';
import '../main_news/news_detail.dart';

// ignore: must_be_immutable
class foryoutranswidget extends StatelessWidget {
  foryoutranswidget({super.key, required this.news});
  final News news;
  String url = BaseUrl().url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailPage(news: news)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'news_image_${news.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: news.mainImages.isNotEmpty
                        ? news.mainImages[0].url
                        : '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Image.asset(
                          'assets/testa_logo.png',
                          width: 80.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.summarizedTitle.toString(),
                      style: TextUtils.setTextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 16.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          formatTimeForNews(news.time),
                          style: TextUtils.setTextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            news.sourcename.toString(),
                            style: TextUtils.setTextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
