import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../components/getAmharicDay.dart';
import '../../../../../localization/demo_localization.dart';

import '../../../matches/matchDetail.dart';
import '../../../../../models/fixtureByLeague.dart';
import '../../../../../models/fixtures/stat.dart';
import '../../../../constants/match_status_indicator.dart';
import '../../../matches/match_status.dart';

class FixturesListForLeagues extends StatefulWidget {
  final List<FixtureListsByLeague> matchesList;
  final int previousIndex;

  const FixturesListForLeagues({
    super.key,
    required this.matchesList,
    required this.previousIndex,
  });

  @override
  State<FixturesListForLeagues> createState() => _FixturesListForLeaguesState();
}

class _FixturesListForLeaguesState extends State<FixturesListForLeagues> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  bool rebuilt = false;
  @override
  void initState() {
    //  if (_scrollController.hasClients)
    //   {}

    jumpToIndex();
    super.initState();
  }

  void jumpToIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(index: widget.previousIndex);
    });
  }

  Future<void> _prepareList() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _scrollController.jumpTo(index: widget.previousIndex);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _prepareList(),
      builder: (context, snapshot) {
        return ScrollablePositionedList.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.matchesList.length,
          itemScrollController: _scrollController,
          padding: EdgeInsets.only(bottom: 50.sp),
          itemBuilder: (context, index) {
            final fixtureList = widget.matchesList[index];

            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.transparent),
              padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 10.sp),
              margin: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.3.sp),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.sp),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        returnDateName(fixtureList.dateOnly),
                        style: _getDateTextStyle(context),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    itemCount: fixtureList.leagueMatches.length,
                    // padding: EdgeInsets.zero,
                    itemBuilder: (context, idx) {
                      final match = fixtureList.leagueMatches[idx];
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MatchDetailsPage(
                                        stat: match,
                                      )))
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 120.sp,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      match.homeTeam.name.toString(),
                                      style: _getTextStyle(context),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.last,
                                      // Add a comma here
                                    )),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.sp, 0, 10.sp, 0),
                                      child: SizedBox(
                                          width: 30.sp,
                                          height: 30.sp,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                match.homeTeam.logo.toString(),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              widget.previousIndex > index
                                  ? _scoreBuilder(context, match.homeTeam.goal,
                                      match.awayTeam.goal)
                                  : _dateBuilder(context, match.time.toString(),
                                      match.status, match.elapsed, match),
                              SizedBox(
                                width: 120.sp,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.sp, 0, 10.sp, 0),
                                      child: SizedBox(
                                          width: 30.sp,
                                          height: 30.sp,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                match.awayTeam.logo.toString(),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    Expanded(
                                        child: Text(
                                      match.awayTeam.name.toString(),
                                      style: _getTextStyle(context),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.values.last,
                                    )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

TextStyle _getTextStyle(BuildContext context) {
  return TextStyle(
      fontSize: 13.sp,
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.normal);
}

Widget _scoreBuilder(
    BuildContext context, int? homeTeamScore, int? awayTeamScore) {
  return Container(
    width: 50.sp,
    padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
    child: Row(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            homeTeamScore != null ? homeTeamScore.toString() : '  ',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        SizedBox(
          width: 5.sp,
        ),
        Text(
          '-',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        SizedBox(
          width: 5.sp,
        ),
        Text(
          homeTeamScore != null ? awayTeamScore.toString() : '  ',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    ),
  );
}

Widget _dateBuilder(BuildContext context, String dateString, String? status,
    int? elapsed, Stat stat) {
  return Container(
      width: 70.sp,
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: Center(
        child: Align(
          alignment: Alignment.center,
          child: elapsed != null && ['1H', '2H'].contains(status)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _scoreBuilder(
                        context, stat.homeTeam.goal, stat.awayTeam.goal),
                    SizedBox(
                      height: 5.sp,
                    ),
                    MatchStatusAndTime(
                        matchStatus: status ?? '',
                        startTimeString: status == '2H'
                            ? stat.secondHalfTime ?? stat.secondHalfTime!
                            : stat.kickOfTime ?? stat.dateString),
                  ],
                )
              : Text(
                  matchStatusReturner(status ?? '', dateString, elapsed),
                  style: _getTextStyle2(context),
                  textAlign: TextAlign.center,
                ),
        ),
      ));
}

TextStyle _getTextStyle2(BuildContext context) {
  return TextStyle(
      fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface);
}

String returnDateName(String date) {
  DateTime now = DateTime.now();
  DateTime currentDate = DateTime(now.year, now.month, now.day);

  // String dateString = currentDate.toString();

  String labelText;

  if (date == DateFormat('yyyy-MM-dd').format(currentDate)) {
    labelText = '${DemoLocalizations.today} ${getAmharicMonthName(date)}';
  } else if (date ==
      DateFormat('yyyy-MM-dd')
          .format(currentDate.add(const Duration(days: 1)))) {
    getAmharicStringDay(date);
    labelText = '${DemoLocalizations.tomorrow} ${getAmharicMonthName(date)}';
  } else if (date ==
      DateFormat('yyyy-MM-dd')
          .format(currentDate.subtract(const Duration(days: 1)))) {
    getAmharicStringDay(date);
    labelText = '${DemoLocalizations.yesterday} ${getAmharicMonthName(date)}';
  } else {
    // DateTime parsedDate =
    //     DateFormat('dd').parse(date.toString().substring(8));
    // String formattedDate = DateFormat('E.dd.MMM').format(parsedDate);

    // labelText = getAmharicDayFromGC(date)['dayName'];
    labelText = getAmharicStringDay(date);
    // labelText = formattedDate;
  }

  return labelText;
}

TextStyle _getDateTextStyle(BuildContext context) {
  return TextStyle(
    fontSize: 15.sp,
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}
