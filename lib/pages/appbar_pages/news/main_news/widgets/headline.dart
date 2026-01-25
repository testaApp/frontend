import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../../../../../components/timeFormatter.dart';
import '../../../../../models/news.dart';
import '../../../../../util/baseUrl.dart';
import '../../../../constants/text_utils.dart';
import '../news_detail.dart';

// ignore: must_be_immutable
class HeadlineWidget extends StatelessWidget {
  final News news;
  final int? index;
  final bool foryou;

  const HeadlineWidget({
    super.key,
    required this.news,
    this.index,
    this.foryou = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(news: news),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildNewsImage(),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8.w,
                  right: 8.w,
                  bottom: 8.h,
                  child: _buildNewsContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsImage() {
    return CachedNetworkImage(
      imageUrl: news.mainImages.isNotEmpty ? news.mainImages[0].url : '',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: (context, url, error) =>
          Image.asset('assets/testa_logo.png', fit: BoxFit.cover),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          news.summarizedTitle.toString(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextUtils.setTextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.access_time, size: 12.sp, color: Colors.white70),
            SizedBox(width: 4.w),
            Text(
              formatTimeForNews(news.time),
              style: TextUtils.setTextStyle(
                  fontSize: 10.sp, color: Colors.white70),
            ),
            SizedBox(width: 8.w),
            // Replaced icon with source image
            if (news.sourceimage != null && news.sourceimage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: CachedNetworkImage(
                  imageUrl: news.sourceimage!,
                  width: 12.sp,
                  height: 12.sp,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white24,
                    highlightColor: Colors.white38,
                    child: Container(
                      width: 12.sp,
                      height: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.source,
                    size: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              )
            else
              Icon(Icons.source, size: 12.sp, color: Colors.white70),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                news.sourcename.toString(),
                style: TextUtils.setTextStyle(
                    fontSize: 10.sp, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<int> pushDetails(String id) async {
  final String url = BaseUrl().url;
  try {
    final response = await http.get(Uri.parse('$url/details/$id'));
    return response.statusCode;
  } catch (e) {
    rethrow;
  }
}
