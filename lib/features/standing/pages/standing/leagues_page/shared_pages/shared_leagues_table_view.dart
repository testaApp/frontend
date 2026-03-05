import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/standings/standings.dart';
import 'package:blogapp/shared/widgets/standing_table_teams_list.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/standing/pages/standing/leagues_page/Standing/rank_name_others_line.dart';

class SFTGTablesView extends StatelessWidget {
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
  final bool Echampionship;
  final bool scotland;
  final bool belgium;
  final bool egypt;
  final bool southafrica;
  final bool netherland;
  final bool portugal;
  final bool qatar;
  final bool mls;

  final List<List<TableItem>> listOfTables;
  final Function onRefresh;

  const SFTGTablesView({
    super.key,
    this.english = false,
    this.ethiopia = false,
    this.turkey = false,
    this.mls = false,
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
    required this.listOfTables,
    required this.onRefresh,
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
    return RefreshIndicator(
      onRefresh: () async {
        //  onRefresh();
      },
      child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
              indent: 2, endIndent: 2, height: 1.5.h, color: Colors.grey[700]),
          shrinkWrap: true,
          itemCount: listOfTables.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, idx) {
            return Column(
              children: [
                FirstRow(nameWidth: nameWidth),
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
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 5) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 16) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (ethiopia == true) {
                      if (index == 0) {
                        return tablesItem(context, tableItem, nameWidth, caf);
                      } else if (index == 1) {
                        return tablesItem(
                            context, tableItem, nameWidth, cafconfederation);
                      } else if (index > 12) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (spain == true) {
                      if (index < 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index < 6) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 6) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 16) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (france == true) {
                      if (index < 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index == 3) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index == 15) {
                        return tablesItem(context, tableItem, nameWidth,
                            relegatequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (italy == true) {
                      if (index < 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 5) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 16) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (german == true) {
                      if (index < 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 4) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 5) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index == 15) {
                        return tablesItem(context, tableItem, nameWidth,
                            relegatequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (saudi == true) {
                      if (index < 3) {
                        return tablesItem(
                            context, tableItem, nameWidth, afcChampiosleague);
                      } else if (index == 3) {
                        return tablesItem(
                            context, tableItem, nameWidth, afccup);
                      } else if (index > 14) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (egypt == true) {
                      if (index < 2) {
                        return tablesItem(context, tableItem, nameWidth, caf);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, cafqualification);
                      } else if (index > 14) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (mls == true) {
                      if (index < 20) {
                        return tablesItem(
                            context, tableItem, nameWidth, Colors.transparent);
                      }
                    } else if (southafrica == true) {
                      if (index < 2) {
                        return tablesItem(context, tableItem, nameWidth, caf);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, cafqualification);
                      } else if (index == 14) {
                        return tablesItem(context, tableItem, nameWidth,
                            relegatequalification);
                      } else if (index == 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (netherland == true) {
                      if (index == 0) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 1) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 3) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index == 15) {
                        return tablesItem(context, tableItem, nameWidth,
                            relegatequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (Elige1 == true) {
                      if (index < 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, promotion);
                      } else if (index < 6) {
                        return tablesItem(context, tableItem, nameWidth,
                            promotionqualification);
                      } else if (index > 19) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (Elige2 == true) {
                      if (index < 3) {
                        return tablesItem(
                            context, tableItem, nameWidth, promotion);
                      } else if (index < 7) {
                        return tablesItem(context, tableItem, nameWidth,
                            promotionqualification);
                      } else if (index > 21) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (Echampionship == true) {
                      if (index < 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, promotion);
                      } else if (index < 6) {
                        return tablesItem(context, tableItem, nameWidth,
                            promotionqualification);
                      } else if (index > 20) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (scotland == true) {
                      if (index == 0) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 1) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index < 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaleaguequalification);
                      } else if (index == 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index == 11) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (belgium == true) {
                      if (index == 0) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 1) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index < 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaleaguequalification);
                      } else if (index == 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (portugal == true) {
                      if (index < 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleague);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index == 3) {
                        return tablesItem(
                            context, tableItem, nameWidth, europaleague);
                      } else if (index == 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (turkey == true) {
                      if (index < 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, championsleaguqual);
                      } else if (index == 2) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaleaguequalification);
                      } else if (index == 3) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index == 3) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaleaguequalification);
                      } else if (index == 4) {
                        return tablesItem(context, tableItem, nameWidth,
                            europaconfrenceleaguequalification);
                      } else if (index > 15) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    } else if (qatar == true) {
                      if (index == 0) {
                        return tablesItem(
                            context, tableItem, nameWidth, afcChampiosleague);
                      } else if (index == 1) {
                        return tablesItem(context, tableItem, nameWidth,
                            afcChampiosleaguequalification);
                      } else if (index == 2) {
                        return tablesItem(
                            context, tableItem, nameWidth, afccup);
                      } else if (index == 10) {
                        return tablesItem(context, tableItem, nameWidth,
                            relegatequalification);
                      } else if (index == 11) {
                        return tablesItem(
                            context, tableItem, nameWidth, relegation);
                      }
                    }
                    return tablesItem(context, tableItem, nameWidth,
                        Colors.black.withOpacity(0));
                  },
                ),
                Container(
                  height: 10.h,
                  width: 360.w,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                      border: Border.all(
                        color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                ),
                                CircleAvatar(radius: 6.r, backgroundColor: caf),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.cafChampionsLeague,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
                                      letterSpacing: 0.2),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(height: 5.h),
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
                                          color: Colors.grey,
                                          letterSpacing: 0.2),
                                    )
                                  ],
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                    radius: 6.r, backgroundColor: europaleague),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.europaLeagueShort,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                  backgroundColor: europaleaguequalification,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.europaleaguequalification,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                CircleAvatar(radius: 6.r, backgroundColor: caf),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.cafChampionsLeague,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                CircleAvatar(radius: 6.r, backgroundColor: caf),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.cafChampionsLeague,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                    radius: 6.r, backgroundColor: promotion),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.promotion,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                    radius: 6.r, backgroundColor: promotion),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.promotion,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                    radius: 6.r, backgroundColor: promotion),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.promotion,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                  backgroundColor: europaleaguequalification,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.europaleaguequalification,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                  backgroundColor: europaleaguequalification,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.europaleaguequalification,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
                                      letterSpacing: 0.2),
                                )
                              ],
                            ),
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                  backgroundColor: europaleaguequalification,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  DemoLocalizations.europaleaguequalification,
                                  style: TextUtils.setTextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
                                      color: Colors.grey,
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
          }),
    );
  }
}
