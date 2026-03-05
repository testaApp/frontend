import 'dart:async';

import '../../../localization/demo_localization.dart';

import '../../../shared/constants/text_utils.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:lottie/lottie.dart';

import '../../../components/routenames.dart';

import '../../../shared/constants/colors.dart';
import '../../../main.dart';

class IntroductionPage extends StatefulWidget {
  final String selectedLanguage;

  const IntroductionPage({super.key, required this.selectedLanguage});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  static const Duration _autoAdvanceDelay = Duration(seconds: 5);

  static const Duration _autoAdvanceDuration = Duration(milliseconds: 1500);

  static const Duration _manualAdvanceDuration = Duration(milliseconds: 600);

  final PageController _pageController = PageController();

  int _currentPage = 0;

  late List<_IntroPageData> pages;

  final Map<String, LottieComposition> _cachedAnimations =
      <String, LottieComposition>{};

  Timer? _autoAdvanceTimer;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _initializePages();

    _precacheAnimations();

    _startAutoAdvanceTimer();
    unawaited(
        globalAnalyticsService.logOnboardingStepViewed('intro_walkthrough'));
  }

  void _initializePages() {
    pages = [
      _IntroPageData(
        title: DemoLocalizations.welcome,
        body: DemoLocalizations.welcomebody,
        lottiePath: 'assets/testa logo.json',
        width: 300.w,
        height: 300.w,
      ),
      _IntroPageData(
        title: DemoLocalizations.News_intro_Title,
        body: DemoLocalizations.News_intro_body,
        lottiePath: 'assets/news_screenshot.json',
        width: 300.w,
        height: 200.w,
      ),
      _IntroPageData(
        title: DemoLocalizations.podcastsTitle,
        body: DemoLocalizations.podcastsBody,
        lottiePath: 'assets/podcast.json',
        width: 250.w,
        height: 250.w,
        repeat: true,
      ),
      _IntroPageData(
        title: DemoLocalizations.leaguestitle,
        body: DemoLocalizations.leaguesbody,
        lottiePath: 'assets/leagues.json',
        width: 250.w,
        height: 250.w,
        repeat: true,
      ),
      _IntroPageData(
        title: DemoLocalizations.clubstitle,
        body: DemoLocalizations.clubsbody,
        lottiePath: 'assets/clubs.json',
        repeat: true,
      ),
      _IntroPageData(
        title: DemoLocalizations.videoHighlightsTitle,
        body: DemoLocalizations.videoHighlightsBody,
        lottiePath: 'assets/highlight.json',
        width: 450.w,
        height: 250.w,
        repeat: true,
      ),
      _IntroPageData(
        title: DemoLocalizations.notificationTitle,
        body: DemoLocalizations.notificationBody,
        lottiePath: 'assets/notify_match.json',
        repeat: true,
      ),
      _IntroPageData(
        title: DemoLocalizations.allownotificationtitle,
        body: DemoLocalizations.allownotificationbody,
        image: Image.asset('assets/allow_notification (2).png'),
      ),
    ];
  }

  Future<void> _precacheAnimations() async {
    final animationPaths = <String>{
      for (final page in pages)
        if (page.lottiePath != null) page.lottiePath!,
    };

    await Future.wait(
      animationPaths.map((path) async {
        try {
          final composition = await AssetLottie(path).load();

          _cachedAnimations[path] = composition;
        } catch (e) {
          debugPrint('Failed to cache lottie "$path": $e');
        }
      }),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();

    _autoAdvanceTimer = Timer.periodic(_autoAdvanceDelay, (timer) {
      if (!mounted || !_pageController.hasClients || _isNavigating) {
        timer.cancel();

        return;
      }

      if (_currentPage < pages.length - 1) {
        _pageController.nextPage(
          duration: _autoAdvanceDuration,
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();

        _onIntroEnd();
      }
    });
  }

  void _resetAutoAdvanceTimer() {
    _startAutoAdvanceTimer();
  }

  void _onIntroEnd() {
    if (_isNavigating || !mounted) return;

    setState(() {
      _isNavigating = true;
    });
    unawaited(
      globalAnalyticsService.logOnboardingStepAction(
        stepName: 'intro_walkthrough',
        action: 'continue_clicked',
        extraParameters: {
          'slide_index': _currentPage,
          'total_slides': pages.length,
        },
      ),
    );

    unawaited(() async {
      try {
        await context.pushNamed(
          RouteNames.favouriteTeam_entry,
          extra: widget.selectedLanguage,
        );
      } catch (e) {
        debugPrint('Failed to navigate from intro page: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isNavigating = false;
          });
        }
      }
    }());
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();

    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTapDown: (_) => _autoAdvanceTimer?.cancel(),
        onTapUp: (_) => _resetAutoAdvanceTimer(),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  unawaited(
                    globalAnalyticsService.logOnboardingStepAction(
                      stepName: 'intro_walkthrough',
                      action: 'slide_changed',
                      extraParameters: {'slide_index': index},
                    ),
                  );

                  _resetAutoAdvanceTimer();
                },
                itemCount: pages.length,
                itemBuilder: (context, index) => _buildPage(pages[index]),
                physics: const BouncingScrollPhysics(),
                pageSnapping: true,
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_IntroPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Animation / Image

          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(bottom: 20.h),
              child: _buildResponsiveImage(page),
            ),
          ),

          // Title & Body

          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextUtils.setTextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colorscontainer.greenColor,
                    ),
                    child: Text(
                      page.title ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    page.body ?? '',
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveImage(_IntroPageData page) {
    if (page.lottiePath != null) {
      return SizedBox(
        width: page.width,
        height: page.height,
        child: _cachedAnimations.containsKey(page.lottiePath)
            ? Lottie(
                composition: _cachedAnimations[page.lottiePath],
                repeat: page.repeat,
                fit: BoxFit.contain,
              )
            : Lottie.asset(
                page.lottiePath!,
                repeat: page.repeat,
                fit: BoxFit.contain,
              ),
      );
    } else {
      return page.image ?? const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    final nextLabel =
        DemoLocalizations.next.isEmpty ? 'Get Started' : DemoLocalizations.next;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered progress dots with flexible space

            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _currentPage == index ? 20.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colorscontainer.greenColor
                          : Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),

            // Compact Premium Next Button

            GestureDetector(
              onTap: _isNavigating
                  ? null
                  : () {
                      // Prevent double taps

                      if (_isNavigating) return;

                      HapticFeedback.lightImpact();

                      _resetAutoAdvanceTimer();

                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: _manualAdvanceDuration,
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _onIntroEnd();
                      }
                    },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colorscontainer.greenColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(
                    color: Colorscontainer.greenColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colorscontainer.greenColor.withValues(alpha: 0.2),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nextLabel,
                      style: TextUtils.setTextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colorscontainer.greenColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colorscontainer.greenColor,
                      size: 16.sp,
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

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colorscontainer.greenColor),
        onPressed: () {
          if (!_isNavigating) {
            unawaited(
              globalAnalyticsService.logOnboardingStepAction(
                stepName: 'intro_walkthrough',
                action: 'back_clicked',
                extraParameters: {'slide_index': _currentPage},
              ),
            );
            context.pop();
          }
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Image.asset(
            'assets/testa_appbar.png',
            width: 60.w,
            height: 40.h,
          ),
        ),
      ],
    );
  }
}

class _IntroPageData {
  final String? title;

  final String? body;

  final String? lottiePath;

  final Widget? image;

  final bool repeat;

  final double? width;

  final double? height;

  _IntroPageData({
    this.title,
    this.body,
    this.lottiePath,
    this.image,
    this.repeat = false,
    this.width,
    this.height,
  });
}
