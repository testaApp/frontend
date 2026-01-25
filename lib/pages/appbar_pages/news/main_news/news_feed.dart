import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../application/enadamt/podcast/podcast_state.dart';
import '../../../../application/following/following_event.dart';
import '../../../../bloc/news/news_bloc.dart';
import '../../../../bloc/news/news_event.dart';
import '../../../../bloc/news/news_state.dart';
import '../../../../application/enadamt/podcast/podcast_bloc.dart';
import '../../../../application/enadamt/podcast/podcast_event.dart';

import '../../../../localization/demo_localization.dart';
import '../../../../main.dart';
import '../../../../models/ads.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
import 'news_row.dart';
import '../../../../bloc/highlightTv_bloc/highlightTv_bloc.dart';
import '../../../../bloc/highlightTv_bloc/highlightTv_Event.dart';
import '../../../../models/HighlighTv_model.dart';
import 'widgets/podcast_live_floating.dart';
import '../../../../models/program_card/PodcastModel.dart';
import 'widgets/trending_news_section.dart';
import 'widgets/loading_shimmer.dart';
import 'widgets/recent_highlights_section.dart';
import 'widgets/ad_widget.dart';
import '../../../../application/following/following_state.dart';
import '../../../../application/following/following_bloc.dart';

class Newsfeed extends StatefulWidget {
  const Newsfeed({super.key});

  @override
  State<Newsfeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<Newsfeed>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNextPage = false;
  List<dynamic> ads = [];
  List<dynamic> cachedNews = [];
  List<dynamic> trendingNews = [];
  bool _isPageActive = true;
  List<Highlight> recentHighlights = [];
  bool _showBackToTopButton = false;
  List<PodcastModel> livePodcasts = [];
  final Set<String> _hiddenPodcastIds = <String>{};
  late SharedPreferences _prefs;
  bool _isPrefsInitialized = false;
  Timer? _periodicTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    context.read<NewsBloc>().state.currentPage = 0;
    _loadInitialData();

    localLanguageNotifier.addListener(() {
      if (mounted) {
        _refresh();
      }
    });

    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted && _isPageActive) {
        _refresh();
      }
    });
  }

  void _loadInitialData() {
    if (!mounted) return;

    context.read<PodcastsBloc>().add(PodcastsRequested());
    context.read<FollowingBloc>().add(FetchAndSaveFavoritePodcasts());

    context
        .read<NewsBloc>()
        .add(NewsRequested(language: localLanguageNotifier.value));
    context
        .read<NewsBloc>()
        .add(TrendingNewsRequested(language: localLanguageNotifier.value));
    _scrollController.addListener(_scrollListener);
    fetchAds().then((_) => _preloadAdImages());
    context.read<HighlightTvBloc>().add(FetchRecentHighlights());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isPageActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  Future<void> fetchAds() async {
    try {
      final List<Ads> adsData = await AdsRepository().getAds();
      if (mounted) {
        setState(() {
          ads = transformAdsData(adsData);
        });
      }
    } catch (e) {}
  }

  String? localizedString(String itemKey, Ads data) {
    var language = localLanguageNotifier.value;
    if (language == 'tr') {
      language = 'tr';
    } else if (language == 'so') {
      language = 'so';
    }
    var vl = '';
    if (itemKey == 'Ad_pic') {
      vl = data.Ad_pic[language] ?? '';
      if (vl.isEmpty) {
        vl = data.Ad_pic['default'] ?? '';
      }
    } else if (itemKey == 'Ad_redirect') {
      vl = data.Ad_redirect[language] ?? '';
      if (vl.isEmpty) {
        vl = data.Ad_redirect['default'] ?? '';
      }
    } else if (itemKey == 'Ad_video') {
      vl = data.Ad_video[language] ?? '';
      if (vl.isEmpty) {
        vl = data.Ad_video['default'] ?? '';
      }
    }
    return vl;
  }

  List<dynamic> transformAdsData(List<Ads> adsData) {
    return adsData.map((ad) {
      return {
        'image': localizedString('Ad_pic', ad)!,
        'url': localizedString('Ad_redirect', ad)!,
      };
    }).toList();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    print('Refreshing news feed');
    context.read<NewsBloc>().state.currentPage = 0;

    context
        .read<NewsBloc>()
        .add(RefreshRequested(language: localLanguageNotifier.value));
    context.read<NewsBloc>().add(
        TrendingNewsRefreshRequested(language: localLanguageNotifier.value));
    context.read<HighlightTvBloc>().add(FetchRecentHighlights());
    context.read<PodcastsBloc>().add(PodcastsRequested());
  }

  void _scrollListener() {
    if (!_scrollController.position.outOfRange) {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingNextPage) {
        setState(() {
          isLoadingNextPage = true;
        });
        context
            .read<NewsBloc>()
            .add(LoadNextPage(language: localLanguageNotifier.value));
      }
    }

    if (_scrollController.offset >= 1000 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 1000 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _preloadAdImages() {
    for (var ad in ads) {
      if (ad['image'] != null && ad['image']!.isNotEmpty) {
        precacheImage(NetworkImage(ad['image']!), context);
      }
    }
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadHiddenPodcasts();
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  void _loadHiddenPodcasts() {
    final String? hiddenPodcastsJson = _prefs.getString('hidden_podcasts');
    if (hiddenPodcastsJson != null) {
      final Map<String, dynamic> hiddenData = json.decode(hiddenPodcastsJson);
      final DateTime expiryTime = DateTime.parse(hiddenData['expiry']);

      if (DateTime.now().isBefore(expiryTime)) {
        setState(() {
          _hiddenPodcastIds.clear();
          _hiddenPodcastIds
              .addAll(List<String>.from(hiddenData['ids']).toSet());
        });
      } else {
        _prefs.remove('hidden_podcasts');
        _hiddenPodcastIds.clear();
      }
    }
  }

  Future<void> _saveHiddenPodcasts() async {
    final Map<String, dynamic> hiddenData = {
      'ids': _hiddenPodcastIds.toList(),
      'expiry': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };
    await _prefs.setString('hidden_podcasts', json.encode(hiddenData));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<NewsBloc, NewsState>(
      listener: (context, state) {
        if (state.newsStatus == NewsRequest.requestSuccess) {
          setState(() {
            isLoadingNextPage = false;
            cachedNews = List.from(state.news);
          });
        }

        if (state.trendingNewsStatus == NewsRequest.requestSuccess) {
          setState(() {
            trendingNews = List.from(state.trendingNews);
          });
        }
      },
      builder: (context, newsState) {
        if (newsState.newsStatus == NewsRequest.requestFailure &&
            cachedNews.isEmpty) {
          return _buildErrorView();
        }

        if (newsState.newsStatus == NewsRequest.requestInProgress &&
            cachedNews.isEmpty) {
          return _buildLoadingView();
        }

        final displayNews = cachedNews.isNotEmpty ? cachedNews : newsState.news;

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildNewsList(newsState),
              if (_showBackToTopButton)
                Positioned(
                  right: 15,
                  bottom: 20,
                  child: InkWell(
                    onTap: _scrollToTop,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colorscontainer.greenColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (newsState.newsStatus == NewsRequest.requestFailure)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    child: Container(
                      color: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DemoLocalizations.networkProblem,
                            textAlign: TextAlign.center,
                            style: TextUtils.setTextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              _buildFloatingLivePodcasts(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: LottieBuilder.asset(
        'assets/bouncing_ball.json',
        width: 250,
        height: 250,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/404.gif',
            width: 200,
            height: 200,
            color: Colorscontainer.greenColor,
          ),
          const SizedBox(height: 20),
          Text(
            DemoLocalizations.networkProblem,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(Colorscontainer.greenColor),
            ),
            onPressed: _refresh,
            child: Text(
              DemoLocalizations.tryAgain,
              style: TextUtils.setTextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(NewsState state) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (state.newsStatus == NewsRequest.requestFailure &&
              cachedNews.isEmpty)
            SliverFillRemaining(child: _buildErrorView())
          else ...[
            SliverToBoxAdapter(child: SizedBox(height: 5.h)),
            TrendingNewsSection(trendingNews: trendingNews),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildLatestNewsSection(),
            if (isLoadingNextPage) const LoadingShimmerWidget(),
            if (state.newsStatus == NewsRequest.requestFailure)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          DemoLocalizations.networkProblem,
                          style: TextUtils.setTextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: _refresh,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Colorscontainer.greenColor),
                          ),
                          child: Text(
                            DemoLocalizations.tryAgain,
                            style: TextUtils.setTextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLatestNewsSection() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 10) {
            return const RecentHighlightsSection();
          }

          final adjustedIndex = index > 10 ? index - 1 : index;
          final isAdPosition = adjustedIndex % 40 == 0 && index > 0;

          if (isAdPosition && ads.isNotEmpty) {
            final adIndex = (adjustedIndex ~/ 40) % ads.length;
            return AdWidget(ad: ads[adIndex]);
          }

          if (adjustedIndex < cachedNews.length) {
            return Column(
              children: [
                Newsinrow(news: cachedNews[adjustedIndex]),
                SizedBox(height: 8.h),
              ],
            );
          }

          return null;
        },
      ),
    );
  }

  Widget _buildFloatingLivePodcasts() {
    if (!_isPrefsInitialized) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<PodcastsBloc, PodcastsState>(
      builder: (context, podcastState) {
        if (podcastState.status != podcastStatus.requestSuccess) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<FollowingBloc, FollowingState>(
          builder: (context, followingState) {
            if (followingState.status == Status.initial) {
              context.read<FollowingBloc>().add(FetchAndSaveFavoritePodcasts());
              return const SizedBox.shrink();
            }

            if (followingState.status == Status.loading) {
              return const SizedBox.shrink();
            }

            final livePodcasts = podcastState.podcasts.where((podcast) {
              final isLive = podcast.isLive;
              final isNotHidden = !_hiddenPodcastIds.contains(podcast.id);
              final isFollowed =
                  followingState.followedPodcasts.contains(podcast.id);

              return isLive && isNotHidden && isFollowed;
            }).toList();

            if (livePodcasts.isEmpty) {
              return const SizedBox.shrink();
            }

            final double podcastWidth = 45.w;
            final double spacing = 12.w;
            final double totalWidth = (podcastWidth * livePodcasts.length) +
                (spacing * (livePodcasts.length - 1)) +
                16.w;

            return Positioned(
              left: 8.w,
              width:
                  totalWidth.clamp(0, MediaQuery.of(context).size.width - 70.w),
              bottom: MediaQuery.of(context).padding.bottom + 8.h,
              child: SizedBox(
                height: 50.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  itemCount: livePodcasts.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.center,
                      child: LivePodcastWidget(
                        podcast: livePodcasts[index],
                        onClose: () async {
                          setState(() {
                            _hiddenPodcastIds.add(livePodcasts[index].id);
                          });
                          await _saveHiddenPodcasts();
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
