import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/colors.dart';
import '../../constants/text_utils.dart';
import 'highlight/highlight.dart';
import 'live_tv/live_tv.dart';
import '../../../../localization/demo_localization.dart';
import '../../../../bloc/live_tv/live_tv_bloc.dart';
import '../../../../bloc/live_tv/live_tv_event.dart';

class Tv extends StatefulWidget {
  const Tv({super.key});

  @override
  _TvState createState() => _TvState();
}

class _TvState extends State<Tv> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTabBarVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_handleScroll);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isTabBarVisible) setState(() => _isTabBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isTabBarVisible) setState(() => _isTabBarVisible = true);
    }
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      // Switching to Live TV tab
      context.read<LiveTvBloc>().add(LiveTvRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final tabLabelColor = isDarkMode ? Colors.white : Colors.black;
    final tabUnselectedColor =
        isDarkMode ? const Color.fromARGB(255, 180, 174, 174) : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colorscontainer.greenColor.withOpacity(0.98),
                    Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: DemoLocalizations.highlight),
                      Tab(text: DemoLocalizations.TV),
                    ],
                    labelColor: tabLabelColor,
                    unselectedLabelColor: tabUnselectedColor,
                    indicatorColor: Colorscontainer.greenColor,
                    indicatorWeight: 3,
                    labelStyle: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 0.h), // Add bottom padding
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    HighlightTvView(),
                    LiveTv(),
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
