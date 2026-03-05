// lib/pages/bottom_navigation/Tv/highlight/highlight_tv_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_Event.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_State.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_bloc.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/HighlighTv_model.dart';
import 'package:blogapp/models/highlight_catagory_model.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'highlight-other-card.dart';
import 'highlight-special-card.dart';

class HighlightTvView extends StatefulWidget {
  const HighlightTvView({super.key});

  @override
  State<HighlightTvView> createState() => _HighlightTvViewState();
}

class _HighlightTvViewState extends State<HighlightTvView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.93);
  final ScrollController _scrollController = ScrollController();
  final Map<String, ScrollController> _categoryScrollControllers = {};
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListeners();
    _initializeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _setupScrollListeners() {
    _scrollController.addListener(_onScroll);
  }

  void _initializeData() {
    context.read<HighlightTvBloc>().add(FetchRecentHighlights());
    context.read<HighlightTvBloc>().add(const FetchCategories(1));
    _startAutoSlide();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _categoryScrollControllers.values.forEach((c) => c.dispose());
    _autoSlideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final state = context.read<HighlightTvBloc>().state;
      if (state is HighlightTvLoaded &&
          state.recentHighlights.isNotEmpty &&
          mounted) {
        _currentPage = (_currentPage + 1) % state.recentHighlights.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (_isScrolled != isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }

    // Load more categories
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final bloc = context.read<HighlightTvBloc>();
      final state = bloc.state;

      if (state is HighlightTvLoaded && state.hasMoreCategories) {
        final nextPage = (state.categories.length / 10).ceil() + 1;
        bloc.add(FetchCategories(nextPage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<HighlightTvBloc, HighlightTvState>(
        builder: (context, state) {
          if (state is HighlightTvInitial) {
            return _buildLoadingState(textColor);
          }
          if (state is HighlightTvError) {
            return _buildErrorState(state, textColor);
          }
          if (state is HighlightTvLoaded) {
            return _buildLoadedState(state, textColor);
          }
          return _buildLoadingState(textColor);
        },
      ),
    );
  }

  Widget _buildLoadingState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colorscontainer.greenColor),
          SizedBox(height: 20.h),
          Text(
            'Loading highlights...',
            style: TextUtils.setTextStyle(
                fontSize: 16.sp, color: textColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(HighlightTvError state, Color textColor) {
    return _buildErrorView(state.message);
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/404.gif', // Make sure this file exists in your assets
            width: 200.w,
            height: 200.h,
            color: Colorscontainer.greenColor,
            colorBlendMode: BlendMode.srcIn, // Optional: makes tint stronger
          ),
          Text(
            DemoLocalizations.networkProblem,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(Colorscontainer.greenColor),
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            onPressed: _initializeData, // Your retry function
            child: Text(
              DemoLocalizations.tryAgain,
              style: TextUtils.setTextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(HighlightTvLoaded state, Color textColor) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              final completer = Completer<void>();
              final subscription =
                  context.read<HighlightTvBloc>().stream.listen((state) {
                if (state is HighlightTvLoaded && !completer.isCompleted) {
                  completer.complete();
                }
              });

              context.read<HighlightTvBloc>().add(const RefreshHighlightTv());

              await completer.future.timeout(
                const Duration(seconds: 10),
                onTimeout: () {},
              );

              subscription.cancel();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                _buildFeaturedSection(state.recentHighlights),
                _buildPageIndicator(state.recentHighlights),
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                // Categories with localized names and logos
                ...state.categories
                    .map((category) => _buildCategorySection(category, state)),

                if (state.hasMoreCategories)
                  SliverToBoxAdapter(child: _buildLoadingIndicator()),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),
        ),
        _buildScrollToTopButton(),
      ],
    );
  }

  // Helper to get localized league name
  String _getLocalizedLeagueName(Category category, HighlightTvLoaded state) {
    final language =
        localLanguageNotifier.value; // Your global language notifier

    // Try to get from league object if available in any highlight
    final league = state.categoryVideos[category.name]?.firstOrNull?.league;

    if (league != null) {
      return league.getName(language) ?? category.name;
    }

    // Fallback to category.name (English)
    return category.name;
  }

  Widget _buildFeaturedSection(List<Highlight> highlights) {
    if (highlights.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30.w, right: 16.w),
            child: Text(
              DemoLocalizations.recentMatches ?? 'Recent Matches',
              style: TextUtils.setTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 250.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: highlights.length,
              itemBuilder: (context, index) {
                final h = highlights[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: HighlightSpecialCard(
                    videoUrl: h.video ?? '',
                    description: h.description,
                  ),
                );
              },
              onPageChanged: (i) => setState(() => _currentPage = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(List<Highlight> highlights) {
    if (highlights.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(highlights.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: _currentPage == i ? 26.w : 8.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == i
                    ? Colorscontainer.greenColor
                    : Colors.grey[400],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategorySection(Category category, HighlightTvLoaded state) {
    final localizedName = _getLocalizedLeagueName(category, state);

    return SliverToBoxAdapter(
      child: BlocBuilder<HighlightTvBloc, HighlightTvState>(
        builder: (context, blocState) {
          if (blocState is! HighlightTvLoaded) return const SizedBox.shrink();

          final videos = blocState.categoryVideos[category.name] ?? [];
          final hasMore =
              blocState.hasMoreCategoryVideos[category.name] ?? false;

          final controller = _categoryScrollControllers.putIfAbsent(
            category.name,
            () => ScrollController()
              ..addListener(() => _onCategoryScroll(category.name)),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                child: Row(
                  children: [
                    if (category.photo.isNotEmpty)
                      SizedBox(
                        // borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          category.photo,
                          width: 20.w,
                          height: 20.w,
                          // fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.sports_soccer,
                            size: 40.w,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        localizedName,
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF444444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190.h,
                child: ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: _getItemCount(videos, hasMore),
                  itemBuilder: (context, index) {
                    if (index == videos.length && hasMore) {
                      return _buildLoadingItem();
                    }
                    if (videos.isEmpty) {
                      return SizedBox(
                        width: 260.w,
                        child: Center(
                          child: Text(
                            'No videos available',
                            style: TextUtils.setTextStyle(
                                color: Colors.grey[500], fontSize: 14.sp),
                          ),
                        ),
                      );
                    }
                    final highlight = videos[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 280.w,
                        child: HighlightOtherCard(highlight: highlight),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          );
        },
      ),
    );
  }

  int _getItemCount(List<Highlight> videos, bool hasMore) {
    if (videos.isEmpty) return 1;
    return videos.length + (hasMore ? 1 : 0);
  }

  Widget _buildLoadingItem() {
    return SizedBox(
      width: 80.w,
      child: Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colorscontainer.greenColor)),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
          child: CircularProgressIndicator(color: Colorscontainer.greenColor)),
    );
  }

  Widget _buildScrollToTopButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: 16.w,
      bottom: _isScrolled ? 20.h : -80.h,
      child: FloatingActionButton.small(
        heroTag: 'top',
        backgroundColor: Colorscontainer.greenColor,
        onPressed: () {
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic);
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  void _onCategoryScroll(String categoryName) {
    final controller = _categoryScrollControllers[categoryName];
    if (controller == null) return;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      final bloc = context.read<HighlightTvBloc>();
      final state = bloc.state;

      if (state is HighlightTvLoaded) {
        final currentPage = state.categoryPages[categoryName] ?? 1;
        final hasMore = state.hasMoreCategoryVideos[categoryName] ?? false;

        if (hasMore) {
          bloc.add(FetchCategoryVideos(categoryName, currentPage + 1));
        }
      }
    }
  }
}
