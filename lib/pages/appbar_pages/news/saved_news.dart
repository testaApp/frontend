import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../../../components/timeFormatter.dart';
import '../../../localization/demo_localization.dart';
import '../../../models/news.dart';
import '../../constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/text_utils.dart';
import 'main_news/news_detail.dart';

class SavedNewsPage extends StatefulWidget {
  const SavedNewsPage({super.key});

  @override
  _SavedNewsPageState createState() => _SavedNewsPageState();
}

class _SavedNewsPageState extends State<SavedNewsPage> {
  late Future<Box<dynamic>> _boxFuture;

  @override
  void initState() {
    super.initState();
    _boxFuture = Hive.openBox('saved_news');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: backgroundColor,
              centerTitle: true,
              elevation: 0,
              title: Text(
                DemoLocalizations.saved_news,
                style: TextUtils.setTextStyle(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: FutureBuilder<Box<dynamic>>(
                future: _boxFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        child: Center(
                            child: Text('Error: ${snapshot.error}',
                                style: TextStyle(color: textColor))),
                      );
                    }

                    final box = snapshot.data!;
                    return ValueListenableBuilder(
                      valueListenable: box.listenable(),
                      builder: (context, box, _) {
                        if (box.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'No saved articles yet',
                                style: TextUtils.setTextStyle(
                                  fontSize: 18.sp,
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final newsJson = box.getAt(index);
                              final news = News.fromJson(json.decode(newsJson));
                              return SavedNewsItem(
                                news: news,
                                onDelete: () async {
                                  await box.deleteAt(index);
                                },
                                isDarkMode: isDarkMode,
                              );
                            },
                            childCount: box.length,
                          ),
                        );
                      },
                    );
                  } else {
                    return SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(color: textColor)),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedNewsItem extends StatelessWidget {
  final News news;
  final VoidCallback onDelete;
  final bool isDarkMode;

  const SavedNewsItem({
    super.key,
    required this.news,
    required this.onDelete,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Dismissible(
      key: Key(news.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(id: news.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: news.mainImages.first.url,
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor:
                        isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    highlightColor:
                        isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                    child: Container(
                      height: 100.h,
                      width: 100.w,
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: textColor),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.summarizedTitle ?? '',
                      style: TextUtils.setTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      news.sourcename ?? '',
                      style: TextUtils.setTextStyle(
                        color: Colorscontainer.greenColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '| ${formatTimeForNews(news.time)}',
                      style: TextUtils.setTextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 12.sp,
                      ),
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
