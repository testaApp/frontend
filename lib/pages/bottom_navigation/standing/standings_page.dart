import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../bloc/availableSeasons/available_seasons_bloc.dart';
import '../../../bloc/availableSeasons/available_seasons_event.dart';
import '../../../bloc/availableSeasons/available_seasons_state.dart';
import '../../../bloc/standings/bloc/content_bloc.dart';
import '../../../bloc/standings/bloc/content_event.dart';
import '../../../models/leagues_page/leagues_screen_model.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import 'LeaguesList.dart';
import 'leagues_page/Multiple_Table_Leagues/multiple_table_league_screen.dart';
import 'leagues_page/dropdown/dropdownMenu.dart';
import 'leagues_page/shared_pages/SharedLeagueScreen.dart';
import 'leagues_page/wc_qualification/continents.dart';

int current = 0;

class StandingPage extends StatelessWidget {
  const StandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainHome();
  }
}

class MainHome extends StatefulWidget {
  const MainHome({super.key});
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemScrollController customBarsController = ItemScrollController();
  TabController? tabController;
  TabController? tabControllerWithoutKnockOut;
  int currentPage = 0;
  List<String> dpMenuItems = <String>[];
  int selectedIndex = 0;
  List<int> leaguesWithKnockOut = [1, 6, 8, 9];

  @override
  void initState() {
    super.initState();
    scrollToZero();
    requestSeasonByLeagueId(39);
  }

  void requestSeasonByLeagueId(int leagueId) {
    context
        .read<AvailableSeasonsBloc>()
        .add(AvailableSeasonsRequested(leagueId: leagueId));
  }

  Future<void> scrollToZero() async {
    await Future.delayed(Duration.zero, () {
      itemScrollController.scrollTo(
          index: current, duration: const Duration(milliseconds: 350));
    });
  }

  void scrollToGivenIndex(int index) {
    if (index < 26) {
      itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 350),
          alignment: 0);
    }

    if (index < 38) {
      requestSeasonByLeagueId(leagueids[index]);
    }
  }

  void onChanged(String? newValue) {
    if (newValue != null) {
      String season = newValue.substring(0, 4);

      context
          .read<AvailableSeasonsBloc>()
          .add(ChangeCurrentSeason(season: season));
      setState(() {
        final availableSeasonsState =
            context.read<AvailableSeasonsBloc>().state;
        selectedIndex =
            availableSeasonsState.seasons.indexOf(newValue.toString());
      });

      // Dispatch StandingRequested event with the correct season
      context.read<ContentBloc>().add(
            StandingRequested(
              leagueId: leagueids[current],
              season: season,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetsList = [
      // English premier league
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          english: true,
        ),
      ),
      // champions league
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          championsleague: true,
          screenModel:
              ScreenModel(season: true, transfer: false, knockoutPage: true),
          current: current,
        ),
      ),
      // ethiopia
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(transfer: false, knockoutPage: false),
          current: current,
          ethiopia: true,
        ),
      ),
      // spain
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          spain: true,
        ),
      ),
      // france
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          france: true,
        ),
      ),
      // italy
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          italy: true,
        ),
      ),
      // german

      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(transfer: false, knockoutPage: false),
          current: current,
          german: true,
        ),
      ),
      // europ league
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          europe: true,
          screenModel:
              ScreenModel(season: true, transfer: false, knockoutPage: true),
          current: current,
        ),
      ),
      // saudi
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          saudi: true,
        ),
      ),
      // FA
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(
              standing: false,
              knockoutPage: true,
              season: false,
              transfer: false),
          current: current,
        ),
      ),
      // carabao cup
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel:
              ScreenModel(standing: false, transfer: false, season: false),
          current: current,
        ),
      ),
      // english ligue1
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          Elige1: true,
        ),
      ),
      // english ligue2
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          Elige2: true,
        ),
      ),
      // english Championship
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          Echampionship: true,
        ),
      ),
      // turky
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          turkey: true,
        ),
      ),
      // egypt
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          egypt: true,
        ),
      ),
      // south africa
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          southafrica: true,
        ),
      ),
      // mls
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          mls: true,
        ),
      ),
      // Netherland
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          netherland: true,
        ),
      ),
      // belgium
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          belgium: true,
        ),
      ),
      // qatar
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          qatar: true,
        ),
      ),
      // portugal
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          portugal: true,
        ),
      ),
      // scotland
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(knockoutPage: false, transfer: false),
          current: current,
          scotland: true,
        ),
      ),
//africa
      KeyedSubtree(
        key: UniqueKey(),
        child: SharedLeagueScreen(
          screenModel: ScreenModel(
            transfer: false,
            knockoutPage: true,
          ),
          current: current,
        ),
      ),
      // Europe cup
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          europechampionship: true,
          screenModel:
              ScreenModel(season: true, transfer: false, knockoutPage: true),
          current: current,
        ),
      ),
      // nations league
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          screenModel: ScreenModel(season: false, knockoutPage: true),
          current: current,
          nationsleague: true,
        ),
      ),
      // copa america
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          screenModel: ScreenModel(season: true, knockoutPage: true),
          current: current,
          copa_america: true,
        ),
      ),
      // olympic
      KeyedSubtree(
        key: UniqueKey(),
        child: MultipleTableLeagueScreen(
          screenModel:
              ScreenModel(season: false, standing: false, knockoutPage: true),
          current: current,
          olympics_men: true,
        ),
      ),
      // world
      const Continents(),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          child: Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(90.h),
                child: Container(
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
                      Container(
                        height: 45.h,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/testa_appbar.png',
                              height: 22.h,
                              fit: BoxFit.contain,
                            ),
                            const Spacer(),
                            BlocBuilder<AvailableSeasonsBloc,
                                AvailableSeasonsState>(
                              builder: (context, state) {
                                if (state.status ==
                                    AvailableSeasonsStatus.requestSuccessed) {
                                  return CustomDropdownButton(
                                    dpMenuItems: state.seasons,
                                    selectedIndex: selectedIndex,
                                    onChanged: onChanged,
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.h),
                      SizedBox(
                        width: double.infinity,
                        height: 97.5.h,
                        child: ScrollablePositionedList.builder(
                          itemScrollController: itemScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: leagues.length,
                          initialScrollIndex: 5,
                          padding: EdgeInsets.zero,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      current = index;
                                      currentPage = index;
                                      selectedIndex = 0;
                                    });
                                    scrollToGivenIndex(index);
                                    tabController?.animateTo(0,
                                        duration:
                                            const Duration(milliseconds: 950));
                                    requestSeasonByLeagueId(leagueids[index]);
                                  },
                                  child: SizedBox(
                                    width: 70.h,
                                    child: LeaguesList(
                                        index: index, current: current),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: widgetsList[currentPage]),
            ],
          ),
        ),
      ),
    );
  }
}
