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
import '../../../../../models/standings/standings.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/text_utils.dart';
import '../Standing/formView.dart';
import '../Standing/fullView.dart';
import '../dropdown/dropdownMenu.dart';
import 'multiple_table_table_view.dart';

class MultipleTableStandingView extends StatefulWidget {
  final int current;
  final bool championsleague;
  final bool europe;
  final bool nationsleague;
  final bool copa_america;
  final bool europechampionship;
  final bool olympics_men;
  const MultipleTableStandingView(
      {super.key,
      this.championsleague = false,
      this.europe = false,
      this.nationsleague = false,
      this.europechampionship = false,
      this.copa_america = false,
      this.olympics_men = false,
      required this.current});

  @override
  State<MultipleTableStandingView> createState() =>
      _MultipleTableStandingViewState();
}

class _MultipleTableStandingViewState extends State<MultipleTableStandingView> {
  int selectedIndex = 0;
  late List<String> dpMenuItems;
  bool isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    dpMenuItems = <String>[
      DemoLocalizations.short,
      DemoLocalizations.full,
      DemoLocalizations.status
    ];

    final contentState = context.read<ContentBloc>().state;
    final hasLeagueState =
        contentState.currentLeagueId == leagueids[widget.current];
    isLoading = !(hasLeagueState &&
        (contentState.status == ContentStatus.requestSuccessed ||
            contentState.status == ContentStatus.requestFailed));

    final seasonsState = context.read<AvailableSeasonsBloc>().state;
    if (seasonsState.status == AvailableSeasonsStatus.requestSuccessed &&
        seasonsState.leagueId == leagueids[widget.current] &&
        seasonsState.currentSeason != null) {
      final shouldFetch = contentState.currentLeagueId !=
              leagueids[widget.current] ||
          contentState.season != seasonsState.currentSeason;
      if (shouldFetch) {
        context.read<ContentBloc>().add(
              StandingRequested(
                leagueId: leagueids[widget.current],
                season: seasonsState.currentSeason,
              ),
            );
      }
    }
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AvailableSeasonsBloc, AvailableSeasonsState>(
          listenWhen: (previous, current) =>
              current.status == AvailableSeasonsStatus.requestSuccessed &&
              current.leagueId == leagueids[widget.current] &&
              previous.requestId != current.requestId,
          listener: (context, state) {
            if (!_isMounted) return;
            setState(() => isLoading = true);

            context.read<ContentBloc>().add(
                  StandingRequested(
                    leagueId: leagueids[widget.current],
                    season: state.currentSeason,
                  ),
                );
          },
        ),
        BlocListener<ContentBloc, ContentState>(
          listener: (context, state) {
            if (!_isMounted) return;
            if (state.status == ContentStatus.requestSuccessed ||
                state.status == ContentStatus.requestFailed) {
              setState(() => isLoading = false);
            }
          },
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10.w),
                Container(
                  height: 25.h,
                  width: 230.w,
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
                      // ... existing code ...
                      tabs: [
                        SizedBox(
                          width: 75.sp,
                          height: 18.sp,
                          child: Tab(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8.w), // Add left padding
                                child: Text(
                                  DemoLocalizations.overall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 75.sp,
                          height: 18.sp,
                          child: Tab(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8.w), // Add left padding
                                child: Text(
                                  DemoLocalizations.home,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 75.sp,
                          height: 18.sp,
                          child: Tab(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8.w), // Add left padding
                                child: Text(
                                  DemoLocalizations.away,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                      // ... existing code ...
                    ),
                  ),
                ),
                const Expanded(child: SizedBox(height: 2)),
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
            SizedBox(height: 16.h),
            BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state.status == ContentStatus.requestInProgress ||
                    isLoading) {
                  return _buildLoadingView();
              } else if (state.status == ContentStatus.requestFailed) {
                return _buildErrorView(message: state.errorMessage);
              } else if (state.status == ContentStatus.requestSuccessed) {
                final overallTables = _tablesForKey(state, 'overall');
                final homeTables = _tablesForKey(state, 'home');
                final awayTables = _tablesForKey(state, 'away');
                return Expanded(
                    child: TabBarView(children: [
                  _buildStandingView(overallTables),
                  _buildStandingView(homeTables),
                  _buildStandingView(awayTables),
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

  Widget _buildErrorView({String? message}) {
    final displayMessage = (message != null && message.isNotEmpty)
        ? message
        : DemoLocalizations.networkProblem;
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
            displayMessage,
            style: TextUtils.setTextStyle(
              color: Colorscontainer.greenColor,
              fontSize: 15.sp,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(DemoLocalizations.tryAgain),
          ),
        ],
      ),
    );
  }

  List<List<TableItem>> _tablesForKey(
      ContentState state, String key) {
    final tables = state.nestedList[key];
    if (tables != null && tables.isNotEmpty) {
      return tables;
    }
    return state.nestedList['overall'] ?? const [];
  }

  Widget _buildStandingView(List<List<TableItem>> listOfTables) {
    switch (selectedIndex) {
      case 0:
        return ChampionsLeagueTablesView(
            europe: widget.europe,
            championsleague: widget.championsleague,
            nationsleague: widget.nationsleague,
            olympics_men: widget.olympics_men,
            europechampionship: widget.europechampionship,
            copa_america: widget.copa_america,
            listOfTables: listOfTables,
            onRefresh: _refresh);
      case 1:
        return FullView(
            europe: widget.europe,
            championsleague: widget.championsleague,
            nationsleague: widget.nationsleague,
            olympics_men: widget.olympics_men,
            copa_america: widget.copa_america,
            listOfTables: listOfTables);
      case 2:
        return FormsView(
          europe: widget.europe,
          championsleague: widget.championsleague,
          nationsleague: widget.nationsleague,
          olympics_men: widget.olympics_men,
          copa_america: widget.copa_america,
          listOfTables: listOfTables,
        );
      default:
        return ChampionsLeagueTablesView(
            europe: widget.europe,
            championsleague: widget.championsleague,
            nationsleague: widget.nationsleague,
            olympics_men: widget.olympics_men,
            europechampionship: widget.europechampionship,
            copa_america: widget.copa_america,
            listOfTables: listOfTables,
            onRefresh: _refresh);
    }
  }
}
