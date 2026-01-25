import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/cupertino.dart';

import '../../../bloc/standings/bloc/content_bloc.dart';
import '../../../bloc/standings/bloc/content_event.dart';
import '../../../bloc/standings/bloc/content_state.dart';
import '../../../components/getAmharicDay.dart';
import '../../../localization/demo_localization.dart';
import '../../../main.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/date_logic.dart';
import '../../constants/text_utils.dart';
import 'leagueMatchesView.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final ItemScrollController itemScrollController = ItemScrollController();

  String selectedDate = '';

  int current = 0;
  List<String> dateList = DateLogic.getDateData();

  late List<Widget> dateWidgets;

  void datePicked(String date) {
    setState(() {
      selectedDate = date;
    });
    context.read<ContentBloc>().add(
          FetchFixtureByDate(
              pickedDate: date, leagueId: leagueidsForMatches[current]),
        );

    updateDateWidgets(date);
    scrollToToday();
  }

  void setCurrent(int newIdx) {
    setState(() {
      current = newIdx;
    });
  }

  Future<void> showDatePickerDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2033),
    );

    if (picked != null) {
      String selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      datePicked(selectedDate);
    }
  }

  int? selectedIndex = 7;
  @override
  void initState() {
    selectedIndex = 7;
    dateWidgets = dateList.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;

      return getDateWidget(date, index);
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      datePicked(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      // Add a small delay to ensure the list is fully rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollToToday();
      });
    });
    super.initState();
  }

  void scrollToToday() {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: 8, // 7 (today in dateWidgets) + 1 (calendar icon offset)
        duration: const Duration(milliseconds: 300),
        alignment:
            0.358, // This centers the item (0.0 = start, 0.5 = center, 1.0 = end)
      );
    }
  }

  void updateDateWidgets(String selectedDate) {
    List<String> updatedDateList =
        DateLogic.getDateData(DateData: selectedDate);

    final newdateWidgets = updatedDateList.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;

      return getUpdatedDateWidget(date, index);
    }).toList();
    setState(() {
      dateWidgets = newdateWidgets;
    });
  }

  String getSelectedDate() {
    List<String> dateList = DateLogic.getDateData();
    final date = dateList[selectedIndex ?? 7].toString();

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          appBar: PreferredSize(
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
                      ],
                    ),
                  ),
                  Container(
                    height: 20.h,
                    margin: EdgeInsets.only(top: 4.h),
                    child: ValueListenableBuilder(
                      valueListenable: localLanguageNotifier,
                      builder: (context, value, child) {
                        return ScrollablePositionedList.builder(
                          itemScrollController: itemScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: dateWidgets.length + 2,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return InkWell(
                                onTap: () async {
                                  await showDatePickerDialog(context);
                                  scrollToToday();
                                },
                                child: Container(
                                  width: 48.w, // Explicit tap target size
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    CupertinoIcons.calendar_today,
                                    size: 18.h,
                                    color: Colorscontainer.greenColor,
                                  ),
                                ),
                              );
                            } else if (index == dateWidgets.length + 1) {
                              return Container(
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    await showDatePickerDialog(context);
                                    scrollToToday();
                                  },
                                  icon: Icon(
                                    CupertinoIcons.calendar_today,
                                    size: 14.h,
                                    color: Colorscontainer.greenColor,
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                child: dateWidgets[index - 1],
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ValueListenableBuilder(
            valueListenable: localLanguageNotifier,
            builder: (context, value, child) {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 360.w,
                      child: BlocBuilder<ContentBloc, ContentState>(
                        builder: (context, state) {
                          if (state.status == ContentStatus.requestInProgress) {
                            return Center(
                              child: Lottie.asset(
                                'assets/pitch_field.json',
                                width: 185.w,
                                height: 185.h,
                                fit: BoxFit.contain,
                              ),
                            );
                          }

                          if (state.status == ContentStatus.requestFailed) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/404.gif',
                                    width: 185.w,
                                    height: 185.h,
                                    fit: BoxFit.contain,
                                    color: Colorscontainer.greenColor,
                                  ),
                                  Text(
                                    DemoLocalizations.networkProblem,
                                    style: TextUtils.setTextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colorscontainer.greenColor,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  FilledButton(
                                    onPressed: () {
                                      context.read<ContentBloc>().add(
                                            FetchFixtureByDate(
                                                pickedDate: selectedDate,
                                                leagueId: leagueidsForMatches[
                                                    current]),
                                          );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 6.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                    ),
                                    child: Text(
                                      DemoLocalizations.tryAgain,
                                      style: TextUtils.setTextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state.status == ContentStatus.requestSuccessed) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  state.premierLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/39.png',
                                          matches: state.premierLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .premierLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.championsLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/2.png',
                                          matches: state.championsLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .championsLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.ethioLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/363.png',
                                          matches: state.ethioLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .ethiopianPremierLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.laligaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/140.png',
                                          matches: state.laligaMatches,
                                          leagueName: DemoLocalizations
                                              .spainLaligaShort)
                                      : const SizedBox.shrink(),
                                  state.league1Matches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/61.png',
                                          matches: state.league1Matches,
                                          leagueName: DemoLocalizations
                                              .franceLeague1Short)
                                      : const SizedBox.shrink(),
                                  state.sereaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          matches: state.sereaMatches,
                                          leagueName: DemoLocalizations
                                              .italySerieAShort,
                                          logo:
                                              'https://media.api-sports.io/football/leagues/135.png')
                                      : const SizedBox.shrink(),
                                  state.bundesLigaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/78.png',
                                          matches: state.bundesLigaMatches,
                                          leagueName:
                                              DemoLocalizations.bundesLigaShort)
                                      : const SizedBox.shrink(),
                                  state.europaLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/3.png',
                                          matches: state.europaLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .europaLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.saudiLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/307.png',
                                          matches: state.saudiLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .saudiProLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.facupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/45.png',
                                          matches: state.facupMatches,
                                          leagueName:
                                              DemoLocalizations.faCupShort)
                                      : const SizedBox.shrink(),
                                  state.carabaoMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/48.png',
                                          matches: state.carabaoMatches,
                                          leagueName:
                                              DemoLocalizations.carabaoEFLShort)
                                      : const SizedBox.shrink(),
                                  state.englishLeagueoneMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/41.png',
                                          matches:
                                              state.englishLeagueoneMatches,
                                          leagueName: DemoLocalizations
                                              .englishLeagueOneShort)
                                      : const SizedBox.shrink(),
                                  state.englishLeagueTwoMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/42.png',
                                          matches:
                                              state.englishLeagueTwoMatches,
                                          leagueName: DemoLocalizations
                                              .englishLeagueTwoShort)
                                      : const SizedBox.shrink(),
                                  state.englishChampionshipMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/40.png',
                                          matches:
                                              state.englishChampionshipMatches,
                                          leagueName: DemoLocalizations
                                              .englishChampionsShipShort)
                                      : const SizedBox.shrink(),
                                  state.africanCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          matches: state.africanCupMatches,
                                          leagueName:
                                              DemoLocalizations.africanCupShort,
                                          logo:
                                              'https://media.api-sports.io/football/leagues/6.png')
                                      : const SizedBox.shrink(),
                                  state.europeanCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/4.png',
                                          matches: state.europeanCupMatches,
                                          leagueName: DemoLocalizations
                                              .europeanCupShort)
                                      : const SizedBox.shrink(),
                                  state.african_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/29.png',
                                          matches:
                                              state.african_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .africanWcQualification)
                                      : const SizedBox.shrink(),
                                  state.european_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/32.png',
                                          matches:
                                              state.european_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .europeanWcQualification)
                                      : const SizedBox.shrink(),
                                  state.asian_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/30.png',
                                          matches: state.asian_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .asianWcQualification)
                                      : const SizedBox.shrink(),
                                  state.north_american_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/31.png',
                                          matches: state
                                              .north_american_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .northAmericanWcQualification)
                                      : const SizedBox.shrink(),
                                  state.south_american_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/34.png',
                                          matches: state
                                              .south_american_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .southAmericanWcQualification)
                                      : const SizedBox.shrink(),
                                  state.oceania_wc_qualification.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/33.png',
                                          matches:
                                              state.oceania_wc_qualification,
                                          leagueName: DemoLocalizations
                                              .oceaniaWcQualification)
                                      : const SizedBox.shrink(),
                                  state.europaNationsLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/5.png',
                                          matches:
                                              state.europaNationsLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .europeanNationsLeagueShort)
                                      : const SizedBox.shrink(),
                                  state.premieraLigaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/95.png',
                                          matches: state.premieraLigaMatches,
                                          leagueName: DemoLocalizations
                                              .portugalPrimeiraLiga)
                                      : const SizedBox.shrink(),
                                  state.jupileProLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/144.png',
                                          matches: state.jupileProLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .belgiumJupilerProLeague)
                                      : const SizedBox.shrink(),
                                  state.eredivisieMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/88.png',
                                          matches: state.eredivisieMatches,
                                          leagueName: DemoLocalizations
                                              .netherlandEredivisie)
                                      : const SizedBox.shrink(),
                                  state.premiershipMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/179.png',
                                          matches: state.premiershipMatches,
                                          leagueName: DemoLocalizations
                                              .scotlandPremiership)
                                      : const SizedBox.shrink(),
                                  state.turkLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/203.png',
                                          matches: state.turkLeagueMatches,
                                          leagueName:
                                              DemoLocalizations.turkTurkLeague)
                                      : const SizedBox.shrink(),
                                  state.premierSoccerLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/288.png',
                                          matches:
                                              state.premierSoccerLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .southAfricaPremierSoccerLeague)
                                      : const SizedBox.shrink(),
                                  state.copaAmericaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/9.png',
                                          matches: state.copaAmericaMatches,
                                          leagueName:
                                              DemoLocalizations.copaAmerica)
                                      : const SizedBox.shrink(),
                                  state.olympicsmenmatchs.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/480.png',
                                          matches: state.olympicsmenmatchs,
                                          leagueName:
                                              DemoLocalizations.olympicsmen)
                                      : const SizedBox.shrink(),
                                  state.asianCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/7.png',
                                          matches: state.asianCupMatches,
                                          leagueName:
                                              DemoLocalizations.asianCup)
                                      : const SizedBox.shrink(),
                                  state.goldCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/22.png',
                                          matches: state.goldCupMatches,
                                          leagueName: DemoLocalizations.goldCup)
                                      : const SizedBox.shrink(),
                                  state.africanFootballLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/1043.png',
                                          matches: state
                                              .africanFootballLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .africanFootballLeague)
                                      : const SizedBox.shrink(),
                                  state.afcChampionsLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/17.png',
                                          matches:
                                              state.afcChampionsLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .afcChampionsLeague)
                                      : const SizedBox.shrink(),
                                  state.afcCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/18.png',
                                          matches: state.afcCupMatches,
                                          leagueName: DemoLocalizations.afcCup)
                                      : const SizedBox.shrink(),
                                  state.cafChampionsLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/12.png',
                                          matches:
                                              state.cafChampionsLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .cafChampionsLeague)
                                      : const SizedBox.shrink(),
                                  state.cafConfederationCupMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/20.png',
                                          matches:
                                              state.cafConfederationCupMatches,
                                          leagueName: DemoLocalizations
                                              .cafConfederationCup)
                                      : const SizedBox.shrink(),
                                  state.africanNationsChampionshipMatches
                                          .isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/19.png',
                                          matches: state
                                              .africanNationsChampionshipMatches,
                                          leagueName: DemoLocalizations
                                              .africanNationsChampionship)
                                      : const SizedBox.shrink(),
                                  state.spainSegundaDivisionMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/141.png',
                                          matches:
                                              state.spainSegundaDivisionMatches,
                                          leagueName: DemoLocalizations
                                              .spainSegundaDivision)
                                      : const SizedBox.shrink(),
                                  state.italySerieBMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/136.png',
                                          matches: state.italySerieBMatches,
                                          leagueName:
                                              DemoLocalizations.italySerieB)
                                      : const SizedBox.shrink(),
                                  state.serieCMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/138.png',
                                          matches: state.serieCMatches,
                                          leagueName: DemoLocalizations.serieC)
                                      : const SizedBox.shrink(),
                                  state.turkeyLig1Matches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/204.png',
                                          matches: state.turkeyLig1Matches,
                                          leagueName:
                                              DemoLocalizations.turkeyLig1)
                                      : const SizedBox.shrink(),
                                  state.belgiumChallengerProLeagueMatches
                                          .isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/145.png',
                                          matches: state
                                              .belgiumChallengerProLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .belgiumChallengerProLeague)
                                      : const SizedBox.shrink(),
                                  state.netherlandsEersteDivisieMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/89.png',
                                          matches: state
                                              .netherlandsEersteDivisieMatches,
                                          leagueName: DemoLocalizations
                                              .netherlandsEersteDivisie)
                                      : const SizedBox.shrink(),
                                  state.germanyBundesliga2Matches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/79.png',
                                          matches:
                                              state.germanyBundesliga2Matches,
                                          leagueName: DemoLocalizations
                                              .germanyBundesliga2)
                                      : const SizedBox.shrink(),
                                  state.germanyLiga3Matches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/80.png',
                                          matches: state.germanyLiga3Matches,
                                          leagueName:
                                              DemoLocalizations.germanyLiga3)
                                      : const SizedBox.shrink(),
                                  state.franceLigue2Matches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/62.png',
                                          matches: state.franceLigue2Matches,
                                          leagueName:
                                              DemoLocalizations.franceLigue2)
                                      : const SizedBox.shrink(),
                                  state.championnatNationalMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/63.png',
                                          matches:
                                              state.championnatNationalMatches,
                                          leagueName: DemoLocalizations
                                              .championnatNational)
                                      : const SizedBox.shrink(),
                                  state.brazilSerieAMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/71.png',
                                          matches: state.brazilSerieAMatches,
                                          leagueName:
                                              DemoLocalizations.brazilSerieA)
                                      : const SizedBox.shrink(),
                                  state.brazilSerieBMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/72.png',
                                          matches: state.brazilSerieBMatches,
                                          leagueName:
                                              DemoLocalizations.brazilSerieB)
                                      : const SizedBox.shrink(),
                                  state.brazilSerieCMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/75.png',
                                          matches: state.brazilSerieCMatches,
                                          leagueName:
                                              DemoLocalizations.brazilSerieC)
                                      : const SizedBox.shrink(),
                                  state.ligaProfesionalArgentinaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/128.png',
                                          matches: state
                                              .ligaProfesionalArgentinaMatches,
                                          leagueName: DemoLocalizations
                                              .ligaProfesionalArgentina)
                                      : const SizedBox.shrink(),
                                  state.argentinaPrimeraNacionalMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/129.png',
                                          matches: state
                                              .argentinaPrimeraNacionalMatches,
                                          leagueName: DemoLocalizations
                                              .argentinaPrimeraNacional)
                                      : const SizedBox.shrink(),
                                  state.copaArgentinaMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/130.png',
                                          matches: state.copaArgentinaMatches,
                                          leagueName:
                                              DemoLocalizations.copaArgentina)
                                      : const SizedBox.shrink(),
                                  state.usaMajorLeagueSoccerMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/253.png',
                                          matches:
                                              state.usaMajorLeagueSoccerMatches,
                                          leagueName: DemoLocalizations
                                              .usaMajorLeagueSoccer)
                                      : const SizedBox.shrink(),
                                  state.uslChampionshipMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/255.png',
                                          matches: state.uslChampionshipMatches,
                                          leagueName:
                                              DemoLocalizations.uslChampionship)
                                      : const SizedBox.shrink(),
                                  state.uslLeagueOneMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/489.png',
                                          matches: state.uslLeagueOneMatches,
                                          leagueName:
                                              DemoLocalizations.uslLeagueOne)
                                      : const SizedBox.shrink(),
                                  state.egyptPremierLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/233.png',
                                          matches:
                                              state.egyptPremierLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .egyptPremierLeague)
                                      : const SizedBox.shrink(),
                                  state.ghanaPremierLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/570.png',
                                          matches:
                                              state.ghanaPremierLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .ghanaPremierLeague)
                                      : const SizedBox.shrink(),
                                  state.scotlandChampionshipMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/180.png',
                                          matches:
                                              state.scotlandChampionshipMatches,
                                          leagueName: DemoLocalizations
                                              .scotlandChampionship)
                                      : const SizedBox.shrink(),
                                  state.qatarStarsLeagueMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/305.png',
                                          matches:
                                              state.qatarStarsLeagueMatches,
                                          leagueName: DemoLocalizations
                                              .qatarStarsLeague)
                                      : const SizedBox.shrink(),
                                  state.friendlyMatches.isNotEmpty
                                      ? LeagueMatches(
                                          logo:
                                              'https://media.api-sports.io/football/leagues/10.png',
                                          matches: state.friendlyMatches,
                                          leagueName:
                                              DemoLocalizations.Friendlies)
                                      : const SizedBox.shrink(),
                                  const SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          )),
    );
  }

  Widget getDateWidget(String date, int index) {
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    String labelText;

    if (date == DateFormat('yyyy-MM-dd').format(currentDate)) {
      labelText = '${DemoLocalizations.today} ${getAmharicMonthName(date)}';
    } else if (date ==
        DateFormat('yyyy-MM-dd')
            .format(currentDate.add(const Duration(days: 1)))) {
      labelText = '${DemoLocalizations.tomorrow} ${getAmharicMonthName(date)}';
    } else if (date ==
        DateFormat('yyyy-MM-dd')
            .format(currentDate.subtract(const Duration(days: 1)))) {
      labelText = '${DemoLocalizations.yesterday} ${getAmharicMonthName(date)}';
    } else {
      labelText = getAmharicStringDay(date);
    }

    return ValueListenableBuilder(
      valueListenable: localLanguageNotifier,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
            context.read<ContentBloc>().add(FetchFixtureByDate(
                pickedDate: date, leagueId: leagueidsForMatches[current]));
            updateDateWidgets(date);
            scrollToToday();
          },
          child: Container(
            height: 20.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: selectedIndex == index
                    ? Colorscontainer.greenColor
                    : Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.2),
                width: 0.5,
              ),
              color: selectedIndex == index
                  ? Colorscontainer.greenColor.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Center(
              child: Text(
                labelText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextUtils.setTextStyle(
                  fontSize: 11.sp,
                  color: selectedIndex == index
                      ? Colorscontainer.greenColor
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getUpdatedDateWidget(String date, int index) {
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    BoxDecoration boxDecoration;
    String labelText;

    if (date == DateFormat('yyyy-MM-dd').format(currentDate)) {
      boxDecoration = const BoxDecoration();
      labelText = '${DemoLocalizations.today}  ${getAmharicMonthName(date)}';
    } else if (date ==
        DateFormat('yyyy-MM-dd')
            .format(currentDate.add(const Duration(days: 1)))) {
      boxDecoration = const BoxDecoration();
      labelText = '${DemoLocalizations.tomorrow}  ${getAmharicMonthName(date)}';
    } else if (date ==
        DateFormat('yyyy-MM-dd')
            .format(currentDate.subtract(const Duration(days: 1)))) {
      boxDecoration = const BoxDecoration();
      labelText =
          '${DemoLocalizations.yesterday}  ${getAmharicMonthName(date)}';
    } else {
      boxDecoration = const BoxDecoration();
      labelText = getAmharicStringDay(date);
    }

    return ValueListenableBuilder(
      valueListenable: localLanguageNotifier,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
            context.read<ContentBloc>().add(FetchFixtureByDate(
                pickedDate: date, leagueId: leagueidsForMatches[current]));
            DateLogic.getUpdatedList(DateData: date);

            updateDateWidgets(date);
            scrollToToday();
          },
          child: Container(
            decoration: boxDecoration,
            child: Container(
              height: 25.h,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(5.w), right: Radius.circular(5.w)),
                border: Border.all(
                  color: selectedIndex == index
                      ? Colorscontainer.greenColor
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6), // Changed to grey
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0.w),
                child: Center(
                  child: Text(
                    labelText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextUtils.setTextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == index
                          ? Colorscontainer.greenColor
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RoundedTabIndicator extends Decoration {
  final BoxPainter _painter;

  RoundedTabIndicator(
      {required Color color, required double radius, required double weight})
      : _painter = _RoundedPainter(color, radius, weight);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RoundedPainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double weight;

  _RoundedPainter(Color color, this.radius, this.weight)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset customOffset =
        offset + Offset(0, cfg.size!.height - (weight * 2));

    final Rect rect = customOffset & Size(cfg.size!.width, weight);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rRect, _paint);
  }
}
