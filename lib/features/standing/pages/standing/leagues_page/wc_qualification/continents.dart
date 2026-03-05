import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/leagues_page/leagues_screen_model.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/constants.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/standing/pages/standing/leagues_page/Multiple_Table_Leagues/multiple_table_league_screen.dart';

class CustomTabIndicator extends Decoration {
  final BoxPainter _painter;
  final bool africa;
  final bool europe;
  final bool asia;
  final bool s_america;
  final bool N_america;
  final bool ocenia;

  CustomTabIndicator(
      {required Color color,
      required double width,
      this.africa = false,
      this.europe = false,
      this.asia = false,
      this.s_america = false,
      this.N_america = false,
      this.ocenia = false,
      required double borderRadius})
      : _painter = _CustomPainter(
            color: color, width: width, borderRadius: borderRadius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _painter;
  }
}

class _CustomPainter extends BoxPainter {
  final Paint _paint;
  final double width;
  final double borderRadius;

  _CustomPainter(
      {required Color color, required this.width, required this.borderRadius})
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Offset circleOffset = offset +
        Offset(configuration.size!.width / 2 - width / 2,
            configuration.size!.height - 5.0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(circleOffset.dx, circleOffset.dy, width,
                3), // Height of the indicator is 3
            Radius.circular(borderRadius)),
        _paint);
  }
}

class Continents extends StatefulWidget {
  const Continents({super.key});

  @override
  _ContinentsState createState() => _ContinentsState();
}

class _ContinentsState extends State<Continents> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> continents = [
    DemoLocalizations.european,
    DemoLocalizations.african,
    DemoLocalizations.south_america,
    DemoLocalizations.north_america,
    DemoLocalizations.asian,
    DemoLocalizations.oceania
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: continents.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth =
        (screenWidth - 24.w) / continents.length; // Equal width for all tabs

    return Column(
      children: [
        Container(
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: TabBar(
            controller: _tabController,
            isScrollable: false, // Changed to false to fit all tabs
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicator: MaterialIndicator(
              color: Colorscontainer.greenColor,
              height: 3,
              topLeftRadius: 8,
              topRightRadius: 8,
              horizontalPadding: 12,
              paintingStyle: PaintingStyle.fill,
            ),
            labelColor: Colorscontainer.greenColor,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            labelStyle: TextUtils.setTextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextUtils.setTextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            tabs: List.generate(
              continents.length,
              (index) => SizedBox(
                width: tabWidth,
                child: Tab(
                  child: Text(
                    continents[index],
                    style: const TextStyle(letterSpacing: 0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              continents.length,
              (index) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(index),
                  child: MultipleTableLeagueScreen(
                    nationsleague: true,
                    screenModel: ScreenModel(
                      knockoutPage: false,
                      teamsStat: false,
                      transfer: false,
                    ),
                    current: leagueids.length - (continents.length - index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
