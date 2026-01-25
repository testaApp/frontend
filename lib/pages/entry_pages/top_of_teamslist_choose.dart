import 'dart:ui';

import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../../util/baseUrl.dart';
import '../../components/routenames.dart';
import '../../localization/demo_localization.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';
import 'team_list_page.dart';

class FollowTeamsPageEntry extends StatefulWidget {
  final String selectedLanguage;
  const FollowTeamsPageEntry({super.key, required this.selectedLanguage});

  @override
  _FollowTeamsPageState createState() => _FollowTeamsPageState();
}

class _FollowTeamsPageState extends State<FollowTeamsPageEntry>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  Map<int, List<int>> selectedIndicesMap = {};
  Map<int, bool> isTabLoaded = {};
  bool _isNavigating = false; // Add flag to prevent double navigation

  final Map<int, List<Color>> countryColors = {
    0: [
      const Color(0xFF239E54),
      const Color(0xFFECC81D),
      const Color(0xFFEF3340)
    ], // Ethiopia - Green, Yellow, Red
    1: [
      const Color(0xFFCF081F),
      const Color(0xFFFFFFFF),
      const Color(0xFF012169)
    ], // England - Red, White, Blue
    2: [
      const Color(0xFFC60B1E),
      const Color(0xFFFFC400),
      const Color(0xFFC60B1E)
    ], // Spain - Red, Yellow, Red
    3: [
      const Color(0xFF009246),
      const Color(0xFFFFFFFF),
      const Color(0xFFCE2B37)
    ], // Italy - Green, White, Red
    4: [
      const Color(0xFF000000),
      const Color(0xFFDD0000),
      const Color(0xFFFFCC00)
    ], // Germany - Black, Red, Gold
    5: [
      const Color(0xFF002395),
      const Color(0xFFFFFFFF),
      const Color(0xFFED2939)
    ], // France - Blue, White, Red
    6: [
      const Color(0xFF006C35),
      const Color(0xFFFFFFFF),
      const Color(0xFF006C35)
    ], // Saudi - Green, White
    7: [
      const Color(0xFFE30A17),
      const Color(0xFFFFFFFF),
      const Color(0xFFE30A17)
    ], // Turkey - Red, White
    8: [
      const Color(0xFF007A4D),
      const Color(0xFFFFB612),
      const Color(0xFF000000)
    ], // South Africa - Green, Yellow, Black
    9: [
      const Color(0xFFCE1126),
      const Color(0xFFFFFFFF),
      const Color(0xFF000000)
    ], // Egypt - Red, White, Black
    10: [
      const Color(0xFFB31942),
      const Color(0xFFFFFFFF),
      const Color(0xFF0A3161)
    ], // USA - Red, White, Blue
    11: [
      const Color(0xFFAE1C28),
      const Color(0xFFFFFFFF),
      const Color(0xFF21468B)
    ], // Netherlands - Red, White, Blue
    12: [
      const Color(0xFF000000),
      const Color(0xFFFFDE00),
      const Color(0xFFFF0000)
    ], // Belgium - Black, Yellow, Red
    13: [
      const Color(0xFF006600),
      const Color(0xFFFF0000),
      const Color(0xFFFF0000)
    ], // Portugal - Green, Red
    14: [
      const Color(0xFF005EB8),
      const Color(0xFFFFFFFF),
      const Color(0xFF005EB8)
    ], // Scotland - Blue, White
    15: [
      const Color(0xFF8D1B3D),
      const Color(0xFFFFFFFF),
      const Color(0xFF8D1B3D)
    ], // Qatar - Maroon, White
  };

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 16, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Initialize maps
    for (int i = 0; i < _tabController.length; i++) {
      selectedIndicesMap[i] = [];
      isTabLoaded[i] = false;
    }

    // Load first tab content
    isTabLoaded[0] = true;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      if (!isTabLoaded[_selectedIndex]!) {
        setState(() {
          isTabLoaded[_selectedIndex] = true;
        });
      }
    }
  }

  Future<void> disposaoble() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void updateSelectedIndices(int tabIndex, List<int> selectedIndices) {
    setState(() {
      selectedIndicesMap[tabIndex] = selectedIndices;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Widget _customTab(String text, bool isSelected) {
    return Tab(
      child: Text(
        text,
        style: TextUtils.setTextStyle(
          color: isSelected
              ? Theme.of(context).textTheme.bodyLarge?.color
              : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          fontSize: 13.5.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _paddedTabContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: child,
    );
  }

  Widget _buildTabContent(int tabIndex, String categoryUrl) {
    if (isTabLoaded[tabIndex]!) {
      return _paddedTabContent(TeamListPageEntry(
        categoryUrl: categoryUrl,
        selectedIndices: selectedIndicesMap[tabIndex] ?? [],
        onUpdateSelectedIndices: (selectedIndices) {
          updateSelectedIndices(tabIndex, selectedIndices);
        },
      ));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  List<Color> _getGradientColors(int index) {
    List<Color> colors = countryColors[index] ?? [Colors.transparent];
    return colors.map((c) => c.withOpacity(0.25)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: true,
              leading: GestureDetector(
                onTap: () {
                  if (!_isNavigating) {
                    context.pop();
                  }
                },
                child:
                    Icon(Icons.arrow_back, color: Colorscontainer.greenColor),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              floating: true,
              expandedHeight: 160.h,
              collapsedHeight: kToolbarHeight,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                countryColors[_selectedIndex]![0]
                                    .withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 40.h,
                                top: 50.h,
                                left: 20.w,
                                right: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Text(
                                        DemoLocalizations.favouriteTeam,
                                        style: TextUtils.setTextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.color,
                                          fontSize: 18.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        DemoLocalizations.pressTheStar,
                                        style: TextUtils.setTextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.color,
                                          fontSize: 12.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ValueListenableBuilder<Set<int>>(
                                  valueListenable: selectedItemsNotifier,
                                  builder: (context, selectedItems, child) {
                                    String text = selectedItems.isNotEmpty
                                        ? '${selectedItems.length} ${DemoLocalizations.teamSelected}'
                                        : DemoLocalizations.teamSelected;
                                    return Text(
                                      text,
                                      style: TextUtils.setTextStyle(
                                        fontSize: 14.sp,
                                        color: Colorscontainer.greenColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40.h),
                child: SizedBox(
                  height: 40.h,
                  child: ExtendedTabBar(
                    labelStyle: TextUtils.setTextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    physics: const BouncingScrollPhysics(),
                    unselectedLabelStyle: TextUtils.setTextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                      fontSize: 14.sp,
                    ),
                    indicatorColor: Colorscontainer.greenColor,
                    indicatorWeight: 3,
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    indicator: MaterialIndicator(
                      topRightRadius: 5.w,
                      topLeftRadius: 5.w,
                      color: Colorscontainer.greenColor,
                      strokeWidth: 2.w,
                      horizontalPadding: 5.w,
                    ),
                    isScrollable: true,
                    controller: _tabController,
                    tabs: [
                      _customTab(
                          DemoLocalizations.ethiopia, _selectedIndex == 0),
                      _customTab(
                          DemoLocalizations.england, _selectedIndex == 1),
                      _customTab(DemoLocalizations.spain, _selectedIndex == 2),
                      _customTab(DemoLocalizations.italy, _selectedIndex == 3),
                      _customTab(
                          DemoLocalizations.germany, _selectedIndex == 4),
                      _customTab(DemoLocalizations.france, _selectedIndex == 5),
                      _customTab(DemoLocalizations.saudi, _selectedIndex == 6),
                      _customTab(DemoLocalizations.turkey, _selectedIndex == 7),
                      _customTab(
                          DemoLocalizations.southAfrica, _selectedIndex == 8),
                      _customTab(DemoLocalizations.egypt, _selectedIndex == 9),
                      _customTab(DemoLocalizations.USA, _selectedIndex == 10),
                      _customTab(
                          DemoLocalizations.netherland, _selectedIndex == 11),
                      _customTab(
                          DemoLocalizations.belgium, _selectedIndex == 12),
                      _customTab(
                          DemoLocalizations.portugal, _selectedIndex == 13),
                      _customTab(
                          DemoLocalizations.scotland, _selectedIndex == 14),
                      _customTab(DemoLocalizations.qatar, _selectedIndex == 15),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            // In your build method's Stack, replace the current background with:
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated orb 1
                  Positioned(
                    top: -100,
                    right: -50,
                    child: _buildAnimatedOrb(
                      countryColors[_selectedIndex]![0],
                      300,
                    ),
                  ),
                  // Animated orb 2
                  Positioned(
                    bottom: -80,
                    left: -40,
                    child: _buildAnimatedOrb(
                      countryColors[_selectedIndex]![1],
                      250,
                    ),
                  ),
                  // Animated orb 3
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4,
                    right: -60,
                    child: _buildAnimatedOrb(
                      countryColors[_selectedIndex]![2],
                      200,
                    ),
                  ),
                  // Glassmorphic overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),

            ExtendedTabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(0, '${BaseUrl().url}/api/favlistchoose/363'),
                _buildTabContent(1, '${BaseUrl().url}/api/favlistchoose/39'),
                _buildTabContent(2, '${BaseUrl().url}/api/favlistchoose/140'),
                _buildTabContent(3, '${BaseUrl().url}/api/favlistchoose/135'),
                _buildTabContent(4, '${BaseUrl().url}/api/favlistchoose/78'),
                _buildTabContent(5, '${BaseUrl().url}/api/favlistchoose/61'),
                _buildTabContent(6, '${BaseUrl().url}/api/favlistchoose/307'),
                _buildTabContent(7, '${BaseUrl().url}/api/favlistchoose/203'),
                _buildTabContent(8, '${BaseUrl().url}/api/favlistchoose/288'),
                _buildTabContent(9, '${BaseUrl().url}/api/favlistchoose/233'),
                _buildTabContent(10, '${BaseUrl().url}/api/favlistchoose/253'),
                _buildTabContent(11, '${BaseUrl().url}/api/favlistchoose/88'),
                _buildTabContent(12, '${BaseUrl().url}/api/favlistchoose/144'),
                _buildTabContent(13, '${BaseUrl().url}/api/favlistchoose/94'),
                _buildTabContent(14, '${BaseUrl().url}/api/favlistchoose/179'),
                _buildTabContent(15, '${BaseUrl().url}/api/favlistchoose/305'),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_isNavigating) return;
                          _isNavigating = true;

                          HapticFeedback.lightImpact();
                          context
                              .pushNamed(
                            RouteNames.favouritePlayer_entry,
                            extra: widget.selectedLanguage,
                          )
                              .then((_) {
                            // Reset flag when navigation completes
                            if (mounted) {
                              _isNavigating = false;
                            }
                          });
                        },
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color:
                                  Colorscontainer.greenColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(
                                color:
                                    Colorscontainer.greenColor.withOpacity(0.4),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colorscontainer.greenColor
                                      .withOpacity(0.2),
                                  blurRadius: 12.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DemoLocalizations.next,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add this helper method:
  Widget _buildAnimatedOrb(Color color, double size) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.4 * value),
                  color.withOpacity(0.1 * value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PatternPainter extends CustomPainter {
  final List<Color> colors;

  PatternPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // Empty paint method - no patterns will be drawn
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) => false;
}
