import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../localization/demo_localization.dart';
import '../../components/routenames.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';

class IntroductionPage extends StatefulWidget {
  final String selectedLanguage;
  const IntroductionPage({super.key, required this.selectedLanguage});

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<_IntroPageData> pages;
  final Map<String, LottieComposition> _cachedAnimations = {};
  Timer? _autoAdvanceTimer;
  static const _autoAdvanceDelay = Duration(seconds: 5);
  bool _isNavigating = false; // Add flag to prevent double navigation

  @override
  void initState() {
    super.initState();
    _initializePages();
    _precacheAnimations();
    _startAutoAdvanceTimer();
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
    final animationPaths = pages
        .where((p) => p.lottiePath != null)
        .map((p) => p.lottiePath!)
        .toList();
    for (final path in animationPaths) {
      final composition = await AssetLottie(path).load();
      _cachedAnimations[path] = composition;
    }
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_autoAdvanceDelay, (timer) {
      if (_currentPage < pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 1500),
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
    // Prevent double navigation
    if (_isNavigating) return;
    _isNavigating = true;

    // Use pushReplacement instead of pushNamed to replace the current route
    context.pushReplacementNamed(
      RouteNames.favouriteTeam_entry,
      extra: widget.selectedLanguage,
    );
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
                onPageChanged: (index) => setState(() => _currentPage = index),
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
                      fontSize: 28.sp,
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
                          : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),

            // Compact Premium Next Button
            GestureDetector(
              onTap: () {
                // Prevent double taps
                if (_isNavigating) return;

                HapticFeedback.lightImpact();
                if (_currentPage < pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                } else {
                  _onIntroEnd();
                }
              },
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colorscontainer.greenColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: Colorscontainer.greenColor.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colorscontainer.greenColor.withOpacity(0.2),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == pages.length - 1
                            ? (DemoLocalizations.next ?? "Get Started")
                            : DemoLocalizations.next,
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
