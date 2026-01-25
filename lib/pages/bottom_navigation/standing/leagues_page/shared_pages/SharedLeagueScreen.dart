import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../../localization/demo_localization.dart';
import '../../../../../models/leagues_page/leagues_screen_model.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_utils.dart';
import '../../../../leagues_page/league_top_players.dart';
import '../fixtures/fixtures_view.dart';
import '../seasons.dart';
import 'shared_league_standing.dart';

class SharedLeagueScreen extends StatefulWidget {
  final ScreenModel screenModel;
  final int current;
  final bool english;
  final bool ethiopia;
  final bool spain;
  final bool turkey;
  final bool france;
  final bool italy;
  final bool german;
  final bool saudi;
  final bool Elige1;
  final bool Elige2;
  final bool Echampionship;
  final bool egypt;
  final bool southafrica;
  final bool netherland;
  final bool portugal;
  final bool belgium;
  final bool scotland;
  final bool qatar;
  final bool mls;

  const SharedLeagueScreen({
    super.key,
    required this.screenModel,
    required this.current,
    this.english = false,
    this.ethiopia = false,
    this.mls = false,
    this.turkey = false,
    this.spain = false,
    this.france = false,
    this.italy = false,
    this.german = false,
    this.saudi = false,
    this.Elige1 = false,
    this.Elige2 = false,
    this.Echampionship = false,
    this.egypt = false,
    this.southafrica = false,
    this.netherland = false,
    this.portugal = false,
    this.belgium = false,
    this.scotland = false,
    this.qatar = false,
  });

  @override
  State<SharedLeagueScreen> createState() => _SpainLeagueScreenState();
}

class _SpainLeagueScreenState extends State<SharedLeagueScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> Pages = [];
  List<String> tabBarNames = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Add fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Initialize pages and tabs
    _initializePagesAndTabs();

    // Start animation
    _animationController.forward();
  }

  void _initializePagesAndTabs() {
    // Move existing page initialization logic here
    if (widget.screenModel.standing == true) {
      Pages.add(SharedStandingView(
        english: widget.english,
        ethiopia: widget.ethiopia,
        spain: widget.spain,
        france: widget.france,
        italy: widget.italy,
        german: widget.german,
        saudi: widget.saudi,
        Elige1: widget.Elige1,
        Elige2: widget.Elige2,
        Echampionship: widget.Echampionship,
        egypt: widget.egypt,
        southafrica: widget.southafrica,
        mls: widget.mls,
        netherland: widget.netherland,
        portugal: widget.portugal,
        belgium: widget.belgium,
        scotland: widget.scotland,
        qatar: widget.qatar,
        turkey: widget.turkey,
        current: widget.current,
      ));
      tabBarNames.add(DemoLocalizations.table);
    }

    Pages.add(FixturesView(
      leagueId: leagueids[widget.current],
    ));
    tabBarNames.add(DemoLocalizations.games);

    if (widget.screenModel.playerStat == true) {
      Pages.add(TopScorersPage(
          logo: 'assets/${leaguePics[widget.current]}.png',
          leagueId: leagueids[widget.current]));
      tabBarNames.add(DemoLocalizations.player_statistics);
    }

    if (widget.screenModel.season == true) {
      Pages.add(
        KeyedSubtree(
          key: ValueKey('seasons_${widget.current}'),
          child: SeasonsPage(
            leagueId: leagueids[widget.current],
          ),
        ),
      );
      tabBarNames.add(DemoLocalizations.seasons);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Pages.length,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                tabAlignment: TabAlignment.start,
                enableFeedback: true,
                splashFactory: InkSparkle.splashFactory,
                labelPadding: EdgeInsets.symmetric(horizontal: 15.w),
                tabs: tabBarNames.map((text) => _buildTab(text)).toList(),
                isScrollable: true,
                physics: const BouncingScrollPhysics(),
                labelColor: Colorscontainer.greenColor,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicator: MaterialIndicator(
                  color: Colorscontainer.greenColor,
                  height: 3,
                  topLeftRadius: 8,
                  topRightRadius: 8,
                  horizontalPadding: 12,
                  paintingStyle: PaintingStyle.fill,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: Pages.map((page) => _buildPageWithAnimation(page))
                        .toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          text,
          style: TextUtils.setTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildPageWithAnimation(Widget page) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: page,
    );
  }
}
