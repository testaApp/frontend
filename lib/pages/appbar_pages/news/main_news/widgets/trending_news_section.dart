import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../localization/demo_localization.dart';

import '../../../../constants/text_utils.dart';
import 'headline.dart';

class TrendingNewsSection extends StatelessWidget {
  final List<dynamic> trendingNews;

  const TrendingNewsSection({super.key, required this.trendingNews});

  @override
  Widget build(BuildContext context) {
    if (trendingNews.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16.sp, color: Colors.grey[700]),
                SizedBox(width: 4.w),
                Text(
                  DemoLocalizations.trendingNews,
                  style: TextUtils.setTextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[700],
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trendingNews.length,
              itemBuilder: (context, index) => SizedBox(
                width: 250.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: HeadlineWidget(
                    news: trendingNews[index],
                    index: index,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
