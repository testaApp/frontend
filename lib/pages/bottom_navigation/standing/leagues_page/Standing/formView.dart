import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../localization/demo_localization.dart';
import '../../../../../models/standings/standings.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';
import '../../group_row.dart';
import 'firstRowForForm.dart';
import 'formItem_last_5.dart';

class FormsView extends StatelessWidget {
  final List<List<TableItem>> listOfTables;
  final bool spain;
  final bool english;
  final bool ethiopia;

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
  final bool championsleague;
  final bool europe;
  final bool nationsleague;
  final bool copa_america;
  final bool olympics_men;
  const FormsView({
    super.key,
    required this.listOfTables,
    this.english = false,
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
    this.championsleague = false,
    this.europe = false,
    this.nationsleague = false,
    this.copa_america = false,
    this.olympics_men = false,
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
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
            indent: 2, endIndent: 2, height: 1.5.h, color: Colors.grey[700]),
        shrinkWrap: true,
        itemCount: listOfTables.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, idx) {
          return listOfTables.length > 1
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FirstRowForForm(),
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
                              ? FormItem(
                                  tableItem: tableItem,
                                  color: Colors.green,
                                )
                              : FormItem(
                                  tableItem: tableItem,
                                  color: Colors.transparent);
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
                    const FirstRowForForm(),
                    ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                          indent: 2,
                          endIndent: 2,
                          height: 1.5.h,
                          color: Colors.grey[700]),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: listOfTables[idx].length,
                      itemBuilder: (context, index) {
                        final tableItem = listOfTables[idx][index];

                        if (english == true) {
                          if (index < 4) {
                            return FormItem(
                              tableItem: tableItem,
                              color: championsleague,
                            );
                          } else if (index == 4) {
                            return FormItem(
                              tableItem: tableItem,
                              color: europaleague,
                            );
                          } else if (index == 5) {
                            return FormItem(
                              tableItem: tableItem,
                              color: europaconfrenceleaguequalification,
                            );
                          } else if (index > 16) {
                            return FormItem(
                              tableItem: tableItem,
                              color: relegation,
                            );
                          }
                        } else if (ethiopia == true) {
                          if (index < 1) {
                            return FormItem(tableItem: tableItem, color: caf);
                          } else if (index == 1) {
                            return FormItem(
                                tableItem: tableItem, color: cafconfederation);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (spain == true) {
                          if (index < 4) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 5) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 16) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (france == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FormItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (italy == true) {
                          if (index < 4) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 5) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 16) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (german == true) {
                          if (index < 5) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index < 7) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 7) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FormItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Elige1 == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 6) {
                            return FormItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 19) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Elige2 == true) {
                          if (index < 3) {
                            return FormItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 7) {
                            return FormItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 21) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (Echampionship == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem, color: promotion);
                          } else if (index < 6) {
                            return FormItem(
                                tableItem: tableItem,
                                color: promotionqualification);
                          } else if (index > 20) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (saudi == true) {
                          if (index < 3) {
                            return FormItem(
                                tableItem: tableItem, color: afcChampiosleague);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem, color: afccup);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (egypt == true) {
                          if (index < 2) {
                            return FormItem(tableItem: tableItem, color: caf);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: cafqualification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (southafrica == true) {
                          if (index < 2) {
                            return FormItem(tableItem: tableItem, color: caf);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: cafqualification);
                          } else if (index == 14) {
                            return FormItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index == 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (netherland == true) {
                          if (index == 0) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 15) {
                            return FormItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (scotland == true) {
                          if (index == 0) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index < 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 11) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        }
                        if (championsleague == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: Colors.yellow);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: const Color.fromARGB(255, 214, 21, 7));
                          }
                        }
                        if (europe == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: Colors.yellow);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: const Color.fromARGB(255, 214, 21, 7));
                          }
                        }
                        if (nationsleague == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        }
                        if (olympics_men == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        }
                        if (copa_america == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color:
                                    const Color.fromARGB(255, 112, 218, 115));
                          } else {
                            return FormItem(
                                tableItem: tableItem,
                                color: Colors.transparent);
                          }
                        } else if (belgium == true) {
                          if (index == 0) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 1) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index < 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 11) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (portugal == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem, color: championsleague);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem, color: europaleague);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (turkey == true) {
                          if (index < 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: championsleaguqual);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index == 3) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaleaguequalification);
                          } else if (index == 4) {
                            return FormItem(
                                tableItem: tableItem,
                                color: europaconfrenceleaguequalification);
                          } else if (index > 15) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        } else if (qatar == true) {
                          if (index == 0) {
                            return FormItem(
                                tableItem: tableItem, color: afcChampiosleague);
                          } else if (index == 1) {
                            return FormItem(
                                tableItem: tableItem,
                                color: afcChampiosleaguequalification);
                          } else if (index == 2) {
                            return FormItem(
                                tableItem: tableItem, color: afccup);
                          } else if (index == 10) {
                            return FormItem(
                                tableItem: tableItem,
                                color: relegatequalification);
                          } else if (index == 11) {
                            return FormItem(
                                tableItem: tableItem, color: relegation);
                          }
                        }

                        return FormItem(
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
                            // bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.7,
                          )),
                    ),
                    SizedBox(
                      height: 7.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 260.sp,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                english == true
                                    ? Container(
                                        child: (Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor: caf),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafChampionsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      cafconfederation,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafConfederationCup,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            112,
                                                            218,
                                                            115)),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      Colors.yellow,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .europaleaguequalification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      const Color.fromARGB(
                                                          255, 214, 21, 7),
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations.relegation,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            112,
                                                            218,
                                                            115)),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      Colors.yellow,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .europaConferenceLeagueQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      const Color.fromARGB(
                                                          255, 214, 21, 7),
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations.relegation,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            112,
                                                            218,
                                                            115)),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .europeanNationsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            112,
                                                            218,
                                                            115)),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations.olympicsmen,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            112,
                                                            218,
                                                            115)),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations.copaAmerica,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  backgroundColor:
                                                      relegatequalification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .relegationQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        afcChampiosleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .afcChampionsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      championsleaguqual,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                        europaleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      relegatequalification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .relegationQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleaguqual),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor: caf),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafChampionsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      cafqualification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafConfederationCup,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor: caf),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafChampionsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      cafqualification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .cafConfederationCup,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                        relegatequalification),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .relegationQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      promotionqualification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .promotion_qualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      promotionqualification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .promotion_qualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      promotionqualification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .promotion_qualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        afcChampiosleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .afcChampionsLeague,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .AFCqualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                    backgroundColor: afccup),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations.afcCup,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                      relegatequalification,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .relegationQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  DemoLocalizations
                                                      .europaLeagueShort,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CircleAvatar(
                                                    radius: 6.r,
                                                    backgroundColor:
                                                        championsleague),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueShort,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                        championsleaguqual),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Text(
                                                  DemoLocalizations
                                                      .championsLeagueQualification,
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                                                  style:
                                                      GoogleFonts.abyssinicaSil(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Theme.of(context)
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
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: SizedBox(
                            width: 65.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 10.w,
                                      decoration: BoxDecoration(
                                        color: Colorscontainer.greenColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(2.r),
                                        ),
                                      ),
                                      child: Text(
                                        DemoLocalizations.w,
                                        textAlign: TextAlign.center,
                                        style: TextUtils.setTextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        DemoLocalizations.winner,
                                        style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 10.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(2.r),
                                        ),
                                      ),
                                      child: Text(
                                        DemoLocalizations.d,
                                        textAlign: TextAlign.center,
                                        style: TextUtils.setTextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        DemoLocalizations.drawer,
                                        style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 10.w,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(2.r),
                                        ),
                                      ),
                                      child: Text(
                                        DemoLocalizations.l,
                                        textAlign: TextAlign.center,
                                        style: TextUtils.setTextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        DemoLocalizations.looser,
                                        style: TextUtils.setTextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60.h,
                    )
                  ],
                );
        });
  }
}
