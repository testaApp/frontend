import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/standings/standings.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/standing/pages/standing/group_row.dart';
import 'fullViewItem.dart';
import 'fullForm_titles.dart';

class FullView extends StatelessWidget {
  final List<List<TableItem>> listOfTables;
  final bool spain;
  final bool english;
  final bool ethiopia;
  final bool championsleague;
  final bool europe;
  final bool nationsleague;
  final bool copa_america;
  final bool olympics_men;
  final bool turkey;
  final bool france;
  final bool italy;
  final bool german;
  final bool saudi;
  final bool Elige1;
  final bool Elige2;
  final bool Echampionship;
  final bool scotland;
  final bool belgium;
  final bool egypt;
  final bool southafrica;
  final bool netherland;
  final bool portugal;
  final bool qatar;

  const FullView({
    super.key,
    this.english = false,
    required this.listOfTables,
    this.championsleague = false,
    this.europe = false,
    this.nationsleague = false,
    this.copa_america = false,
    this.olympics_men = false,
    this.ethiopia = false,
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
    this.scotland = false,
    this.belgium = false,
    this.netherland = false,
    this.portugal = false,
    this.qatar = false,
  });

  @override
  Widget build(BuildContext context) {
    Color promotion = const Color.fromARGB(255, 36, 202, 42);
    Color promotionqualification = const Color.fromARGB(255, 202, 185, 36);
    Color championsleague = const Color.fromARGB(255, 34, 202, 39);
    Color europaleague = const Color.fromARGB(255, 17, 0, 255);
    Color europaleaguequalification = const Color.fromARGB(255, 44, 42, 134);
    Color europaconfrenceleaguequalification =
        const Color.fromARGB(255, 18, 200, 255);
    Color relegation = const Color.fromARGB(255, 255, 6, 6);
    Color championsleaguqual = const Color.fromARGB(255, 255, 251, 6);
    Color relegatequalification = const Color.fromARGB(255, 255, 155, 6);
    Color afcChampiosleague = const Color.fromARGB(255, 126, 253, 68);
    Color afcChampiosleaguequalification =
        const Color.fromARGB(255, 253, 68, 238);
    Color cafconfederation = const Color.fromARGB(255, 35, 229, 255);
    Color afccup = const Color.fromARGB(255, 4, 0, 255);
    Color caf = const Color.fromARGB(255, 255, 252, 66);
    Color cafqualification = const Color.fromARGB(255, 6, 197, 255);
    final nameWidth = MediaQuery.of(context).size.width / 2.4;
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
            indent: 2,
            endIndent: 2,
            height: 1.5.h,
            color: Theme.of(context).colorScheme.onSurface),
        shrinkWrap: true,
        itemCount: listOfTables.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, idx) {
          return listOfTables.length > 1
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FirstRowForFullView(),
                    SizedBox(
                      height: 15.h,
                    ),
                    GroupRow(
                      idx: idx,
                      name: listOfTables[idx].isNotEmpty
                          ? listOfTables[idx].first.group
                          : null,
                    ),
                    Container(
                        child: RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: listOfTables[idx].length,
                        itemBuilder: (context, index) {
                          final tableItem = listOfTables[idx][index];
                          return index < 2
                              ? FullViewItem(
                                  tableItem: tableItem,
                                  color: Colors.green,
                                )
                              : FullViewItem(
                                  tableItem: tableItem,
                                  color: Colors.black.withOpacity(0));
                        },
                      ),
                    )),
                    idx == listOfTables.length - 1
                        ? SizedBox(
                            height: 60.h,
                          )
                        : const SizedBox.shrink()
                  ],
                )
              : Column(
                  children: [
                    const FirstRowForFullView(),
                    ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        indent: 2,
                        endIndent: 2,
                        height: 1.5.h,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: listOfTables[idx].length,
                      itemBuilder: (context, index) {
                        final tableItem = listOfTables[idx][index];

                        if (english == true) {
                          if (index < 4) {
                            return FullViewItem(
                              tableItem: tableItem,
                              color: championsleague,
                            );
                          } else if (index == 4) {
                            return FullViewItem(
                              tableItem: tableItem,
                              color: europaleague,
                            );
                          } else if (index == 5) {
                            return FullViewItem(
                              tableItem: tableItem,
                              color: europaconfrenceleaguequalification,
                            );
                          } else if (index > 16) {
                            return FullViewItem(
                              tableItem: tableItem,
                              color: relegation,
                            );
                          }
                        }
                        if (championsleague == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: Colors.yellow);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: const Color.fromARGB(255, 214, 21, 7));
                          }
                        }
                        if (europe == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: Colors.yellow);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: const Color.fromARGB(255, 214, 21, 7));
                          }
                        }
                        if (nationsleague == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        }
                        if (olympics_men == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        }
                        if (copa_america == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        } else if (ethiopia == true) {
                          if (index < 1) {
                            return FullViewItem(
                                tableItem: tableItem, color: caf);
                          } else if (index == 1) {
                            return FullViewItem(
                                tableItem: tableItem, color: cafconfederation);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (spain == true) {
                          if (index < 4) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index < 6) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 6) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 16) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (france == true) {
                          if (index < 3) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index < 6) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 6) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (italy == true) {
                          if (index < 5) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index < 7) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 7) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 16) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (german == true) {
                          if (index < 5) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index < 7) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 7) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Elige1 == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 6) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 19) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Elige2 == true) {
                          if (index < 3) {
                            return FullViewItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 7) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 21) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Echampionship == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 6) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 20) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (saudi == true) {
                          if (index < 3) {
                            return FullViewItem(
                                tableItem: tableItem, color: afcChampiosleague);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem, color: afccup);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (egypt == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: caf);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: cafqualification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (southafrica == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: caf);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: cafqualification);
                          } else if (index == 14) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index == 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (netherland == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 15) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (scotland == true) {
                          if (index == 0) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index < 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 11) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (belgium == true) {
                          if (index == 0) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index < 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 11) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (portugal == true) {
                          if (index < 1) {
                            return FullViewItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (turkey == true) {
                          if (index < 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 3) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 15) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (qatar == true) {
                          if (index == 0) {
                            return FullViewItem(
                                tableItem: tableItem, color: afcChampiosleague);
                          } else if (index == 1) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: afcChampiosleaguequalification);
                          } else if (index == 2) {
                            return FullViewItem(
                                tableItem: tableItem, color: afccup);
                          } else if (index == 10) {
                            return FullViewItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index == 11) {
                            return FullViewItem(
                                tableItem: tableItem, color: relegation);
                          }
                        }

                        return FullViewItem(
                          tableItem: tableItem,
                          color: Colors.black.withOpacity(0),
                        );
                      },
                    ),
                    Container(
                      height: 10.h,
                      width: 360.w,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20)),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 0.7,

                            // )
                          )),
                    ),
                    SizedBox(
                      height: 7.h,
                    ),
                    english == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    spain == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    ethiopia == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r, backgroundColor: caf),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafChampionsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: cafconfederation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafConfederationCup,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
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
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 218, 115)),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          .europaleaguequalification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 218, 115)),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 218, 115)),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europeanNationsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 218, 115)),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.olympicsmen,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 218, 115)),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.copaAmerica,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    italy == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    german == true
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
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                      radius: 6.r,
                                      backgroundColor: relegatequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegationQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    saudi == true
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
                                        backgroundColor: afcChampiosleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.afcChampionsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: afccup,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.afcCup,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    france == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: championsleaguqual,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .championsLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: europaleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          europaconfrenceleaguequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegatequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegationQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    turkey == true
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
                                        backgroundColor: championsleaguqual),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .championsLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          europaleaguequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaleaguequalification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    egypt == true
                        ? Container(
                            child: (Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r, backgroundColor: caf),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafChampionsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: cafqualification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafConfederationCup,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    southafrica == true
                        ? Container(
                            child: (Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r, backgroundColor: caf),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafChampionsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: cafqualification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.cafConfederationCup,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: relegatequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegationQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    Elige1 == true
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
                                        backgroundColor: promotion),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: promotionqualification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion_qualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                )
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    Elige2 == true
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
                                        backgroundColor: promotion),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: promotionqualification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion_qualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    Echampionship == true
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
                                        backgroundColor: promotion),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: promotionqualification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.promotion_qualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    portugal == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    qatar == true
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
                                        backgroundColor: afcChampiosleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.afcChampionsLeague,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          afcChampiosleaguequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.AFCqualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        radius: 6.r, backgroundColor: afccup),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.afcCup,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegatequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegationQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    netherland == true
                        ? Container(
                            child: (Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: europaleague,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.europaLeagueShort,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5.h),
                              ],
                            )),
                          )
                        : const SizedBox.shrink(),
                    scotland == true
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
                                        backgroundColor: championsleague),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.championsLeagueShort,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        backgroundColor: championsleaguqual),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .championsLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                          europaleaguequalification,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaleaguequalification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                            europaconfrenceleaguequalification),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations
                                          .europaConferenceLeagueQualification,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                      backgroundColor: relegation,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      DemoLocalizations.relegation,
                                      style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                );
        });
  }
}
