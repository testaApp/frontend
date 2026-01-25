import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../localization/demo_localization.dart';
import '../../../../../models/standings/standings.dart';
import '../../../../../widgets/standing_table_teams_list.dart';
import '../../../../constants/text_utils.dart';
import '../Standing/rank_name_others_line.dart';
import '../../group_row.dart';

class ChampionsLeagueTablesView extends StatelessWidget {
  final List<List<TableItem>> listOfTables;
  final Function onRefresh;
  final bool championsleague;
  final bool europe;
  final bool europechampionship;
  final bool nationsleague;
  final bool copa_america;
  final bool olympics_men;
  const ChampionsLeagueTablesView(
      {super.key,
      required this.listOfTables,
      this.championsleague = false,
      this.europe = false,
      this.europechampionship = false,
      this.nationsleague = false,
      this.copa_america = false,
      this.olympics_men = false,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final nameWidth = MediaQuery.of(context).size.width / 2.4;

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FirstRow(nameWidth: nameWidth),
            ListView.separated(
                primary: false,
                separatorBuilder: (context, index) => Divider(
                    indent: 2,
                    endIndent: 2,
                    height: 1.5.h,
                    color: Colors.grey[700]),
                shrinkWrap: true,
                itemCount: listOfTables.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, idx) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GroupRow(
                        idx: idx,
                        name: 'Group ${String.fromCharCode(65 + idx)}',
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listOfTables[idx].length,
                        itemBuilder: (context, index) {
                          final tableItem = listOfTables[idx][index];
                          if (championsleague) {
                            if (index < 8) {
                              return tablesItem(context, tableItem, nameWidth,
                                  const Color.fromARGB(255, 112, 218, 115));
                            } else if (index < 24) {
                              return tablesItem(
                                  context, tableItem, nameWidth, Colors.yellow);
                            } else if (index >= 24) {
                              return tablesItem(context, tableItem, nameWidth,
                                  const Color.fromARGB(255, 214, 21, 7));
                            }
                          }
                          return tablesItem(context, tableItem, nameWidth,
                              Colors.transparent);
                        },
                      ),
                    ],
                  );
                }),
            Container(
              height: 10.h,
              width: 360.w,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.7,
                  )),
            ),
            SizedBox(
              height: 7.h,
            ),
            championsleague == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.europeChampionsLeagueKnockout,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                              radius: 6.r,
                              backgroundColor: Colors.yellow,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.championsLeagueQualification,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                              radius: 6.r,
                              backgroundColor:
                                  const Color.fromARGB(255, 214, 21, 7),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.relegation,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            europe == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.europaLeagueShort,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                              radius: 6.r,
                              backgroundColor: Colors.yellow,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations
                                  .europaConferenceLeagueQualification,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                              radius: 6.r,
                              backgroundColor:
                                  const Color.fromARGB(255, 214, 21, 7),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.relegation,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            nationsleague == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.europeanNationsLeague,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            nationsleague == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.nextRoundQualification,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            olympics_men == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.olympicsmen,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            copa_america == true
                ? Container(
                    child: (Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            CircleAvatar(
                                radius: 6.r,
                                backgroundColor:
                                    const Color.fromARGB(255, 112, 218, 115)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              DemoLocalizations.copaAmerica,
                              style: TextUtils.setTextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0.2),
                            )
                          ],
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            SizedBox(
              height: 60.h,
            )
          ],
        ),
      ),
    );
  }
}
