import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../components/timeFormatter.dart';
import '../../../../models/news.dart';
import '../../../constants/text_utils.dart';
import 'news_detail.dart';

// ignore: must_be_immutable
class Newsinrow extends StatelessWidget {
  Newsinrow({super.key, required this.news});
  final News news;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            try {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(id: news.id),
                  
                ),
              );
            } catch (e) {}
          },
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * 0.95,
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                    child: SizedBox(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.2,
                      child: CachedNetworkImage(
                        imageUrl: news.mainImages.isNotEmpty
                            ? news.mainImages[0].url
                            : '',
                        fit: BoxFit.cover,
                        cacheManager: CacheManager(
                          Config(
                            'cacheKey',
                            stalePeriod: const Duration(days: 2),
                            maxNrOfCacheObjects: 100,
                          ),
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/testa_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.summarizedTitle.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Row(
                            children: [
                              if (news.sourceimage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: CachedNetworkImage(
                                    imageUrl: news.sourceimage!,
                                    width: 14.w,
                                    height: 14.w,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 14.w,
                                      height: 14.w,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  news.sourcename.toString(),
                                  style: TextUtils.setTextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 10.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formatTimeForNews(news.publishedDate ?? ''),
                                style: TextUtils.setTextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
