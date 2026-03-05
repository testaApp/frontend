import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/domain/player/playerStatisticsModel.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'previous_and_next_matches_of_team.dart';

class MatchesView extends StatefulWidget {
  final String? teamId;
  final List<PlayerStatistics> playerStatistics;

  const MatchesView({
    super.key,
    this.teamId,
    required this.playerStatistics,
  });

  @override
  _MatchesViewState createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),

          // === PILL-STYLE TAB BAR ===
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(3),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colorscontainer.greenColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
                labelStyle: TextUtils.setTextStyle(
                    fontSize: 12.sp, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: DemoLocalizations.recentMatches),
                  Tab(text: DemoLocalizations.next_matchs),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Expanded(
            child: ExtendedTabBarView(
              controller: _tabController,
              cacheExtent: 1, // 🔥 This keeps both tabs alive
              children: [
                PreviousAndNextMatchesOfWidget(
                  TeamId: widget.teamId,
                  matchType: PreviousAndNextMatchesOf.previous,
                ),
                PreviousAndNextMatchesOfWidget(
                  TeamId: widget.teamId,
                  matchType: PreviousAndNextMatchesOf.fixtures,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
