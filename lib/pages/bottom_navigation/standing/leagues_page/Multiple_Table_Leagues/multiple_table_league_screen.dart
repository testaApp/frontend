import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/availableSeasons/available_seasons_event.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../models/leagues_page/leagues_screen_model.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_utils.dart';
import '../../../../leagues_page/League_news.dart';
import '../../../../leagues_page/league_top_players.dart';
import '../seasons.dart';
import 'Multiple_table_standing_view.dart';
import '../fixtures/fixtures_view.dart';

class MultipleTableLeagueScreen extends StatefulWidget {
  final ScreenModel screenModel;
  final int current;
  final bool championsleague;
  final bool europe;
  final bool europechampionship;
  final bool nationsleague;
  final bool copa_america;
  final bool olympics_men;

  const MultipleTableLeagueScreen(
      {super.key,
      required this.screenModel,
      this.championsleague = false,
      this.europe = false,
      this.europechampionship = false,
      required this.current,
      this.nationsleague = false,
      this.copa_america = false,
      this.olympics_men = false});

  @override
  State<MultipleTableLeagueScreen> createState() =>
      _MultipleTableLeagueScreenState();
}

class _MultipleTableLeagueScreenState extends State<MultipleTableLeagueScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> Pages = [];
  List<String> tabBarNames = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Add animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    context.read<AvailableSeasonsBloc>().add(
          AvailableSeasonsRequested(leagueId: leagueids[widget.current]),
        );

    // Initialize pages and tabs
    _initializePages();

    // Start animation
    _animationController.forward();
  }

  void _initializePages() {
    if (widget.screenModel.standing == true) {
      Pages.add(MultipleTableStandingView(
        europe: widget.europe,
        europechampionship: widget.europechampionship,
        championsleague: widget.championsleague,
        nationsleague: widget.nationsleague,
        olympics_men: widget.olympics_men,
        copa_america: widget.copa_america,
        current: widget.current,
      ));
      tabBarNames.add(DemoLocalizations.table);
    }

    Pages.add(FixturesView(
      leagueId: leagueids[widget.current],
    ));
    tabBarNames.add(DemoLocalizations.games);

    if (widget.screenModel.newsPage == true) {
      Pages.add(LeagueNews(
        leagueName: leagueNameForIndex(widget.current),
      ));
      tabBarNames.add(DemoLocalizations.news);
    }

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
