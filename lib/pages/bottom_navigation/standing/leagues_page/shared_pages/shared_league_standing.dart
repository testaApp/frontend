import 'dart:io';

import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../../../bloc/availableSeasons/available_seasons_event.dart';
import '../../../../../bloc/availableSeasons/available_seasons_state.dart';
import '../../../../../bloc/standings/bloc/content_bloc.dart';
import '../../../../../bloc/standings/bloc/content_event.dart';
import '../../../../../bloc/standings/bloc/content_state.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_utils.dart';
import '../Standing/formView.dart';
import '../Standing/fullView.dart';
import '../dropdown/dropdownMenu.dart';
import 'shared_leagues_table_view.dart';

class SharedStandingView extends StatefulWidget {
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
  final bool mls;
  final bool Echampionship;
  final bool egypt;
  final bool southafrica;
  final bool netherland;
  final bool portugal;
  final bool belgium;
  final bool scotland;
  final bool qatar;

  const SharedStandingView({
    super.key,
    required this.current,
    this.english = false,
    this.ethiopia = false,
    this.spain = false,
    this.turkey = false,
    this.france = false,
    this.italy = false,
    this.german = false,
    this.saudi = false,
    this.Elige1 = false,
    this.Elige2 = false,
    this.mls = false,
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
  State<SharedStandingView> createState() => _SharedStandingViewState();
}

class _SharedStandingViewState extends State<SharedStandingView> {
  int selectedIndex = 0;
  late List<String> dpMenuItems;
  List<String> standingData = ['overall', 'home', 'away'];
  bool isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    dpMenuItems = <String>[
      DemoLocalizations.overall,
      DemoLocalizations.home,
      DemoLocalizations.away
    ];

    context
        .read<AvailableSeasonsBloc>()
        .add(AvailableSeasonsRequested(leagueId: leagueids[widget.current]));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailableSeasonsBloc>().stream.listen((state) {
        if (_isMounted &&
            state.status == AvailableSeasonsStatus.requestSuccessed) {
          setState(() => isLoading = true);
          context.read<ContentBloc>().add(
                StandingRequested(
                  leagueId: leagueids[widget.current],
                  season: state.currentSeason,
                ),
              );
        }
      });

      context.read<ContentBloc>().stream.listen((state) {
        if (_isMounted && state.status == ContentStatus.requestSuccessed) {
          setState(() => isLoading = false);
        }
      });
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isMounted) {
      setState(() => isLoading = true);
      context
          .read<AvailableSeasonsBloc>()
          .add(AvailableSeasonsRequested(leagueId: leagueids[widget.current]));
    }
  }

  void onChanged(String? newValue) {
    if (newValue != null && _isMounted) {
      setState(() {
        selectedIndex = dpMenuItems.indexOf(newValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              SizedBox(width: 10.w),
              // Make the tab bar container flexible instead of fixed width
              Expanded(
                flex: 3, // Gives more space to tabs
                child: Container(
                  height: 25.h,
                  constraints:
                      BoxConstraints(maxWidth: 260.w), // Optional upper limit
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ExtendedTabBar(
                      isScrollable: false, // Keep it non-scrollable
                      indicator: BoxDecoration(
                        color: const Color.fromARGB(255, 177, 173, 173),
                        borderRadius: Platform.isAndroid
                            ? BorderRadius.circular(25.r)
                            : BorderRadius.circular(0.r),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurface,
                      labelPadding: EdgeInsets.symmetric(vertical: 2.5.h),
                      labelStyle: TextUtils.setTextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w400),
                      tabs: [
                        Tab(
                          child: Text(
                            DemoLocalizations.short,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            DemoLocalizations.full,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            DemoLocalizations.status,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Dropdown takes only needed space
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: CustomDropdownButton(
                  onChanged: onChanged,
                  dpMenuItems: dpMenuItems,
                  selectedIndex: selectedIndex,
                ),
              ),
            ],
          ),
          BlocBuilder<ContentBloc, ContentState>(
            builder: (context, state) {
              if (state.status == ContentStatus.requestInProgress ||
                  isLoading) {
                return _buildLoadingView();
              } else if (state.status == ContentStatus.requestFailed) {
                return _buildErrorView();
              } else if (state.status == ContentStatus.requestSuccessed) {
                final listOfTables =
                    state.nestedList[standingData[selectedIndex]] ??
                        state.nestedList['overall']!;

                return Expanded(
                    child: ExtendedTabBarView(children: [
                  SFTGTablesView(
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
                    scotland: widget.scotland,
                    southafrica: widget.southafrica,
                    netherland: widget.netherland,
                    portugal: widget.portugal,
                    qatar: widget.qatar,
                    turkey: widget.turkey,
                    belgium: widget.belgium,
                    listOfTables: listOfTables,
                    onRefresh: _refresh,
                  ),
                  FullView(
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
                      netherland: widget.netherland,
                      scotland: widget.scotland,
                      portugal: widget.portugal,
                      qatar: widget.qatar,
                      turkey: widget.turkey,
                      listOfTables: listOfTables),
                  FormsView(
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
                    netherland: widget.netherland,
                    scotland: widget.scotland,
                    portugal: widget.portugal,
                    qatar: widget.qatar,
                    turkey: widget.turkey,
                    listOfTables: listOfTables,
                  ),
                ]));
              } else if (state.status == ContentStatus.unknown) {
                return _buildLoadingView();
              } else {
                return _buildLoadingView();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 90.h),
          Image.asset(
            'assets/refresh_indicator.gif',
            height: 100.h,
            fit: BoxFit.contain,
          ),
        ],
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
            height: 200.h,
            fit: BoxFit.fitHeight,
            color: Colorscontainer.greenColor,
            width: 300.w,
          ),
          Text(
            DemoLocalizations.networkProblem,
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
              fontSize: 15.sp,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String? season =
                  context.read<AvailableSeasonsBloc>().state.currentSeason;
              context.read<ContentBloc>().add(StandingRequested(
                  leagueId: leagueids[widget.current], season: season));
            },
            child: Text(DemoLocalizations.tryAgain),
          ),
        ],
      ),
    );
  }
}
