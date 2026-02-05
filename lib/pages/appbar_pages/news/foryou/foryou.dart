import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../bloc/news/news_bloc.dart';
import '../../../../bloc/news/news_event.dart';
import '../../../../bloc/news/news_state.dart';
import '../../../../components/timeFormatter.dart';
import '../../../../main.dart';
import '../../../../models/news.dart';
import '../main_news/news_detail.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  Timer? _periodicTimer;
  bool _isPageActive = true;
  bool isLoadingNextPage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<NewsBloc>();
      if (bloc.state.forYouTeamNews.isEmpty &&
          bloc.state.forYouPlayerNews.isEmpty) {
        bloc.add(ForYouNewsRequested(language: localLanguageNotifier.value));
      }
    });

    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted && _isPageActive) {
        _handleRefresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isPageActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    context.read<NewsBloc>().add(
          ForYouRefreshRequested(language: localLanguageNotifier.value),
        );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !isLoadingNextPage) {
      setState(() => isLoadingNextPage = true);
      context.read<NewsBloc>().add(
            ForYouLoadNextPage(language: localLanguageNotifier.value),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: BlocConsumer<NewsBloc, NewsState>(
            listener: (context, state) {
              if (state.forYouNewsStatus == NewsRequest.requestSuccess) {
                setState(() => isLoadingNextPage = false);
              }
            },
            builder: (context, state) {
              final allNews = [
                ...state.forYouTeamNews.values.expand((list) => list),
                ...state.forYouPlayerNews.values.expand((list) => list),
              ]..sort((a, b) {
                final dateA = a.publishedDate != null ? DateTime.tryParse(a.publishedDate!) : null;
                final dateB = b.publishedDate != null ? DateTime.tryParse(b.publishedDate!) : null;
                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return 1;
                if (dateB == null) return -1;
                return dateB.compareTo(dateA);
              });

              if ((state.forYouNewsStatus == NewsRequest.requestInProgress ||
                      state.forYouNewsStatus == NewsRequest.unknown) &&
                  allNews.isEmpty) {
                return Center(
                  child: Image.asset('assets/foryou_indicator.gif'),
                );
              }

              if (allNews.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 120.h),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.article_outlined,
                              size: 100, color: Colors.grey[400]),
                          SizedBox(height: 32.h),
                          Text(
                            "No personalized news yet",
                            style: TextStyle(
                                fontSize: 20.sp, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Stories will appear as they break",
                            style: TextStyle(
                                fontSize: 15.sp, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                itemCount: allNews.length + (isLoadingNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == allNews.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return PremiumMagazineNewsCard(news: allNews[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== PREMIUM MAGAZINE-STYLE NEWS CARD ====================

class PremiumMagazineNewsCard extends StatelessWidget {
  final News news;

  const PremiumMagazineNewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NewsDetailPage(id: news.id),
  ),
);

        },
        child: Stack(
          children: [
            // Hero Image
            CachedNetworkImage(
              imageUrl:
                  news.mainImages.isNotEmpty ? news.mainImages.first.url : '',
              height: 280.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceContainer,
                highlightColor: theme.colorScheme.surface,
                child: Container(color: theme.colorScheme.surfaceContainer),
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(Icons.article,
                      size: 80, color: theme.colorScheme.outline),
                ),
              ),
            ),

            // Dark gradient overlay
            Container(
              height: 280.h,
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
            ),

            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.summarizedTitle ?? 'Untitled',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        if (news.sourceimage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: CachedNetworkImage(
                              imageUrl: news.sourceimage!,
                              width: 28.w,
                              height: 28.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(width: news.sourceimage != null ? 12.w : 0),
                        Expanded(
                          child: Text(
                            news.sourcename ?? 'Unknown Source',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatTimeForNews(news.publishedDate ?? ''),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
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
    );
  }
}
