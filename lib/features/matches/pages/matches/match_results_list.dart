import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:blogapp/localization/demo_localization.dart';

import 'matchDetail.dart';
import 'package:blogapp/models/fixtures/stat.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/match_status_indicator.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'match_status.dart';

class MatchLists extends StatelessWidget {
  final List<Stat> statList;
  final String leagueName;
  const MatchLists(
      {super.key, required this.statList, required this.leagueName});

  static const List<Color> teamColors = [
    //red
    Color.fromRGBO(217, 9, 36, 0.5),
    //grey
    Color.fromRGBO(105, 105, 105, 0.5),
    //blue
    Color.fromRGBO(80, 117, 240, 0.5),
  ];

  @override
  Widget build(BuildContext context) {
    print('📊 Building MatchLists with ${statList.length} matches');

    if (statList.isEmpty) {
      print('⚠️ StatList is empty!');
      return Center(
        child: Text(
          'No matches available',
          style: TextUtils.setTextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return ListView.builder(
        itemCount: statList.length,
        primary: false,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (ctxt, idx) {
          print('🎯 Building match card ${idx + 1} of ${statList.length}');
          return Column(
            children: [
              MatchResultCard(
                stat: statList[idx],
                leagueName: leagueName,
              ),
              if (idx < statList.length - 1) // Add this condition
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                  child: const Divider(
                    height: 2,
                    color: Colors.grey,
                  ),
                )
            ],
          );
        });
  }
}

class MatchResultCard extends StatefulWidget {
  final Stat stat;
  final String leagueName;
  const MatchResultCard({
    super.key,
    required this.stat,
    required this.leagueName,
  });

  @override
  State<MatchResultCard> createState() => _MatchResultCardState();
}

class _MatchResultCardState extends State<MatchResultCard> {
  String _getCorrectMatchStatus() {
    if (widget.stat.dateString == null) return '';

    final matchDate = DateTime.parse(widget.stat.dateString!);
    final now = DateTime.now().toUtc();
    final isMatchInPast = now.difference(matchDate).inHours >= 3;

    // Handle 'NS' status for past matches
    if (widget.stat.status == 'NS' && isMatchInPast) {
      return ''; // or 'PST' depending on your preference
    }

    // List of statuses that should not be changed to FT
    final unchangeableStatuses = [
      'PST', // Postponed
      'CANC', // Cancelled
      'ABD', // Abandoned
      'AWD', // Technical Loss
      'TBD', // To Be Determined
      'WO', // Walkover
      'SUSP', // Suspended
      'INT', // Interrupted
      'AET', // Finished Extra Time
      'PEN', // Finished by Penalty
    ];

    // If it's a special status, return it as is
    if (unchangeableStatuses.contains(widget.stat.status)) {
      return widget.stat.status ?? '';
    }

    // Only change to FT if it's a normal match that should be finished
    if (isMatchInPast &&
        ['1H', '2H', 'HT', 'LIVE', '', null].contains(widget.stat.status)) {
      return 'FT'; // Force "Full Time" status
    }

    // Return original status for ongoing or upcoming matches
    return widget.stat.status ?? '';
  }

  bool _shouldShowLiveTimer() {
    if (widget.stat.dateString == null) return false;

    // Don't show timer for special statuses
    if ([
      'PST',
      'CANC',
      'ABD',
      'AWD',
      'TBD',
      'WO',
      'SUSP',
      'INT',
      'AET',
      'PEN',
      'FT'
    ].contains(widget.stat.status)) {
      return false;
    }

    final matchDate = DateTime.parse(widget.stat.dateString!);
    final now = DateTime.now().toUtc();

    return now.difference(matchDate).inHours < 3;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? hometeamName = widget.stat.homeTeam.name;
    String? awayTeamName = widget.stat.awayTeam.name;

    return InkWell(
        onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MatchDetailsPage(
                            stat: widget.stat,
                            leagueName: widget.leagueName,
                          )))
            },
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 4.w),
            child: Row(children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Subtle glow effect layer
                              CachedNetworkImage(
                                width: 28.sp,
                                height: 28.sp,
                                fit: BoxFit.contain,
                                imageUrl:
                                    "https://media.api-sports.io/football/teams/${widget.stat.homeTeam.id}.png",
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.05),
                              ),
                              // Original logo layer
                              CachedNetworkImage(
                                width: 28.sp,
                                height: 28.sp,
                                fit: BoxFit.contain,
                                imageUrl:
                                    "https://media.api-sports.io/football/teams/${widget.stat.homeTeam.id}.png",
                                errorWidget: (context, url, error) =>
                                    CachedNetworkImage(
                                  imageUrl:
                                      widget.stat.homeTeam.logo.toString(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            hometeamName.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Text(
                          '${widget.stat.homeTeam.goal ?? ""}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ropaSans(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Subtle glow effect layer
                              CachedNetworkImage(
                                width: 28.sp,
                                height: 28.sp,
                                fit: BoxFit.contain,
                                imageUrl:
                                    "https://media.api-sports.io/football/teams/${widget.stat.awayTeam.id}.png",
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.05),
                              ),
                              // Original logo layer
                              CachedNetworkImage(
                                width: 28.sp,
                                height: 28.sp,
                                fit: BoxFit.contain,
                                imageUrl:
                                    "https://media.api-sports.io/football/teams/${widget.stat.awayTeam.id}.png",
                                errorWidget: (context, url, error) =>
                                    CachedNetworkImage(
                                  imageUrl:
                                      widget.stat.awayTeam.logo.toString(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            awayTeamName.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Text(
                          '${widget.stat.awayTeam.goal ?? ""}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ropaSans(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8.w),
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: Colorscontainer.greenColor, width: 0.5))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 115.w,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              matchStatusReturner(
                                  _getCorrectMatchStatus(),
                                  _getCorrectMatchStatus() == 'FT'
                                      ? ''
                                      : widget.stat.time.toString(),
                                  _getCorrectMatchStatus() == 'FT'
                                      ? null
                                      : widget.stat.elapsed),
                              softWrap: true,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtils.setTextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        Text(
                          DemoLocalizations.detail,
                          style: TextUtils.setTextStyle(
                              color: Colorscontainer.greenColor,
                              fontSize: 15.sp),
                        ),
                        ['1H', '2H'].contains(widget.stat.status) &&
                                _shouldShowLiveTimer()
                            ? Column(children: [
                                MatchStatusAndTime(
                                    matchStatus: widget.stat.status ?? '',
                                    startTimeString: widget.stat.status == '2H'
                                        ? widget.stat.secondHalfTime
                                        : widget.stat.kickOfTime ??
                                            widget.stat.dateString)
                              ])
                            : const SizedBox.shrink(),
                      ],
                    )
                  ],
                ),
              )
            ])));
  }
}
