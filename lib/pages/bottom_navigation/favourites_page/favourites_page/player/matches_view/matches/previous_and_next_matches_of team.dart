import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/match_page_state.dart';
import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_bloc.dart';
import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_page_event.dart';
import '../../../../../../../components/getAmharicDay.dart';
import '../../../../../../../components/timeFormatter.dart';
import '../../../../../../../localization/demo_localization.dart';
import '../../../../../../../main.dart';
import '../../../../../../constants/colors.dart';
import '../../../../../../constants/text_utils.dart';
import '../../../../../matches/match_status.dart';

enum PreviousAndNextMatchesOf { previous, fixtures }

class PreviousAndNextMatchesOfWidget extends StatefulWidget {
  final String? TeamId;
  final PreviousAndNextMatchesOf matchType;
  final String? leagueId;

  const PreviousAndNextMatchesOfWidget({
    super.key,
    required this.TeamId,
    required this.matchType,
    this.leagueId,
  });

  @override
  _MatchesWidgetState createState() => _MatchesWidgetState();
}

class _MatchesWidgetState extends State<PreviousAndNextMatchesOfWidget> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<dynamic>> futureMatches;

  @override
  void initState() {
    super.initState();

    // Dispatch the appropriate event based on matchType
    if (widget.matchType == PreviousAndNextMatchesOf.fixtures) {
      context
          .read<MatchesPageBloc>()
          .add(TeamNextMatchesRequested(widget.TeamId));
    } else {
      context
          .read<MatchesPageBloc>()
          .add(TeamPreviousMatchesRequested(widget.TeamId));
    }

    context.read<MatchesPageBloc>().state.pageCounter = 1;
  }

  @override
  void didUpdateWidget(PreviousAndNextMatchesOfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload data when league filter changes
    if (oldWidget.leagueId != widget.leagueId) {
      if (widget.matchType == PreviousAndNextMatchesOf.fixtures) {
        context
            .read<MatchesPageBloc>()
            .add(TeamNextMatchesRequested(widget.TeamId));
      } else {
        context
            .read<MatchesPageBloc>()
            .add(TeamPreviousMatchesRequested(widget.TeamId));
      }
    }
  }

  String _sanitizeMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.replaceAll(
        RegExp(r'media-\d+\.api-sports\.io'), 'media.api-sports.io');
  }

  String _getTeamName(dynamic matches_list, bool isHome) {
    String teamName = '';
    if (localLanguageNotifier.value == 'am') {
      teamName = isHome ? matches_list.homeTeam_am : matches_list.awayTeam_am;
    } else if (localLanguageNotifier.value == 'or') {
      teamName = isHome ? matches_list.homeTeam_or : matches_list.awayTeam_or;
    } else if (localLanguageNotifier.value == 'so') {
      teamName = isHome ? matches_list.homeTeam_so : matches_list.awayTeam_so;
    } else if (localLanguageNotifier.value == 'tr') {
      teamName = isHome ? matches_list.homeTeam_ti : matches_list.awayTeam_ti;
    } else {
      teamName = isHome ? matches_list.homeTeam : matches_list.awayTeam;
    }
    return teamName;
  }

  // Get localized league name based on league ID
  String _getLocalizedLeagueName(dynamic matches_list) {
    int? leagueId = matches_list.leagueId;

    switch (leagueId) {
      case 39:
        return DemoLocalizations.premierLeagueShort;
      case 2:
        return DemoLocalizations.championsLeagueShort;
      case 363:
        return DemoLocalizations.ethiopianPremierLeagueShort;
      case 140:
        return DemoLocalizations.spainLaligaShort;
      case 61:
        return DemoLocalizations.franceLeague1Short;
      case 135:
        return DemoLocalizations.italySerieAShort;
      case 78:
        return DemoLocalizations.bundesLigaShort;
      case 3:
        return DemoLocalizations.europaLeagueShort;
      case 307:
        return DemoLocalizations.saudiProLeagueShort;
      case 45:
        return DemoLocalizations.faCupShort;
      case 48:
        return DemoLocalizations.carabaoEFLShort;
      case 41:
        return DemoLocalizations.englishLeagueOneShort;
      case 42:
        return DemoLocalizations.englishLeagueTwoShort;
      case 40:
        return DemoLocalizations.englishChampionsShipShort;
      case 6:
        return DemoLocalizations.africanCupShort;
      case 4:
        return DemoLocalizations.europeanCupShort;
      case 29:
        return DemoLocalizations.africanWcQualification;
      case 32:
        return DemoLocalizations.europeanWcQualification;
      case 30:
        return DemoLocalizations.asianWcQualification;
      case 31:
        return DemoLocalizations.northAmericanWcQualification;
      case 34:
        return DemoLocalizations.southAmericanWcQualification;
      case 33:
        return DemoLocalizations.oceaniaWcQualification;
      case 5:
        return DemoLocalizations.europeanNationsLeagueShort;
      case 95:
        return DemoLocalizations.portugalPrimeiraLiga;
      case 144:
        return DemoLocalizations.belgiumJupilerProLeague;
      case 88:
        return DemoLocalizations.netherlandEredivisie;
      case 179:
        return DemoLocalizations.scotlandPremiership;
      case 203:
        return DemoLocalizations.turkTurkLeague;
      case 288:
        return DemoLocalizations.southAfricaPremierSoccerLeague;
      case 9:
        return DemoLocalizations.copaAmerica;
      case 480:
        return DemoLocalizations.olympicsmen;
      case 7:
        return DemoLocalizations.asianCup;
      case 22:
        return DemoLocalizations.goldCup;
      case 1043:
        return DemoLocalizations.africanFootballLeague;
      case 17:
        return DemoLocalizations.afcChampionsLeague;
      case 18:
        return DemoLocalizations.afcCup;
      case 12:
        return DemoLocalizations.cafChampionsLeague;
      case 20:
        return DemoLocalizations.cafConfederationCup;
      case 19:
        return DemoLocalizations.africanNationsChampionship;
      case 141:
        return DemoLocalizations.spainSegundaDivision;
      case 136:
        return DemoLocalizations.italySerieB;
      case 138:
        return DemoLocalizations.serieC;
      case 204:
        return DemoLocalizations.turkeyLig1;
      case 145:
        return DemoLocalizations.belgiumChallengerProLeague;
      case 89:
        return DemoLocalizations.netherlandsEersteDivisie;
      case 79:
        return DemoLocalizations.germanyBundesliga2;
      case 80:
        return DemoLocalizations.germanyLiga3;
      case 62:
        return DemoLocalizations.franceLigue2;
      case 63:
        return DemoLocalizations.championnatNational;
      case 71:
        return DemoLocalizations.brazilSerieA;
      case 72:
        return DemoLocalizations.brazilSerieB;
      case 75:
        return DemoLocalizations.brazilSerieC;
      case 128:
        return DemoLocalizations.ligaProfesionalArgentina;
      case 129:
        return DemoLocalizations.argentinaPrimeraNacional;
      case 130:
        return DemoLocalizations.copaArgentina;
      case 253:
        return DemoLocalizations.usaMajorLeagueSoccer;
      case 255:
        return DemoLocalizations.uslChampionship;
      case 489:
        return DemoLocalizations.uslLeagueOne;
      case 233:
        return DemoLocalizations.egyptPremierLeague;
      case 570:
        return DemoLocalizations.ghanaPremierLeague;
      case 180:
        return DemoLocalizations.scotlandChampionship;
      case 305:
        return DemoLocalizations.qatarStarsLeague;
      case 10:
        return DemoLocalizations.Friendlies;
      default:
        return matches_list.league ?? ""; // Fallback to API name
    }
  }

  String _getLeagueLogoUrl(dynamic matches_list) {
    String? logoUrl = matches_list.logo;

    if (logoUrl == null || logoUrl.isEmpty || logoUrl == 'null') {
      return '';
    }

    return _sanitizeMediaUrl(logoUrl);
  }

  // Helper method to get unique league identifier for filtering
  String _getLeagueIdentifier(dynamic matches_list) {
    String? logo = matches_list.logo;
    String name = matches_list.league ?? '';
    return logo ?? name;
  }

  List<dynamic> _filterMatchesByLeague(List<dynamic> matches) {
    // If "All Tournaments" is selected (leagueId is null or equals DemoLocalizations.tournaments)
    if (widget.leagueId == null ||
        widget.leagueId == DemoLocalizations.tournaments) {
      return matches;
    }

    // Filter by selected league
    return matches.where((match) {
      return _getLeagueIdentifier(match) == widget.leagueId;
    }).toList();
  }

  // Helper to check if match is live
  bool _isLiveMatch(String? status) {
    if (status == null) return false;
    final liveStatuses = [
      'LIVE',
      '1H',
      '2H',
      'HT',
      'ET',
      'P',
      'BT',
      'KO1',
      'KO2'
    ];
    return liveStatuses.contains(status.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesPageBloc, MatchPageState>(
      builder: (context, state) {
        // Determine which data to use based on matchType
        final List<dynamic> matches;
        final matchpageStatus status;

        if (widget.matchType == PreviousAndNextMatchesOf.fixtures) {
          matches = state.nextMatches;
          status = state.nextMatchesStatus;
        } else {
          matches = state.previousMatches;
          status = state.previousMatchesStatus;
        }

        // Show loading shimmer
        if ((status == matchpageStatus.initial ||
                status == matchpageStatus.requested) ||
            matches.isEmpty) {
          return Center(child: buildShimmerEffect());
        } else if (status == matchpageStatus.requestSuccess) {
          // Filter matches based on selected league
          final filteredMatches = _filterMatchesByLeague(matches);

          // Show empty state if no matches for selected league
          if (filteredMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.matchType == PreviousAndNextMatchesOf.fixtures
                        ? DemoLocalizations.informationNotFound
                        : DemoLocalizations.informationNotFound,
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredMatches.length,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            itemBuilder: (context, index) {
              if (index == filteredMatches.length) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                    strokeWidth: 0,
                  ),
                );
              }

              final matches_list = filteredMatches[index];
              String home = _getTeamName(matches_list, true);
              String away = _getTeamName(matches_list, false);
              String dateTimeString = matches_list.date.toString();
              String monthDay = getAmharicMonthName(dateTimeString);
              String leagueName = _getLocalizedLeagueName(matches_list);
              String leagueLogo = _getLeagueLogoUrl(matches_list);
              String? matchStatus = matches_list.status;
              bool isLive = _isLiveMatch(matchStatus);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isLive
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    width: isLive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    // HEADER: LEAGUE INFO & DATE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // League info
                        Expanded(
                          child: Row(
                            children: [
                              if (leagueLogo.isNotEmpty) ...[
                                CachedNetworkImage(
                                  imageUrl: leagueLogo,
                                  height: 16.sp,
                                  width: 16.sp,
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.emoji_events,
                                    size: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                              Flexible(
                                child: Text(
                                  leagueName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextUtils.setTextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Date for both previous and fixtures
                        isLive
                            ? MatchStatusAndTime(
                                matchStatus: matchStatus ?? 'LIVE',
                                extraTime: matches_list.extraTime,
                                startTimeString: dateTimeString,
                              )
                            : Text(
                                monthDay,
                                style: TextUtils.setTextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                      ],
                    ),
                    Divider(height: 20.h, thickness: 0.5),

                    // TEAM LOGOS AND SCORES
                    Row(
                      children: [
                        _buildTeamSide(
                          home,
                          _sanitizeMediaUrl(
                              matches_list.hometeamlogo.toString()),
                          true,
                        ),
                        widget.matchType == PreviousAndNextMatchesOf.fixtures
                            ? _buildFixtureTimeCenter(dateTimeString)
                            : _buildScoreCenter(
                                matches_list.scoreHome?.toString() ?? '-',
                                matches_list.scoreAway?.toString() ?? '-',
                                isLive,
                              ),
                        _buildTeamSide(
                          away,
                          _sanitizeMediaUrl(
                              matches_list.awayteamlogo.toString()),
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'FT':
      case 'AET':
      case 'PEN':
        return Colorscontainer.greenColor;
      case 'LIVE':
      case '1H':
      case '2H':
      case 'HT':
        return Colors.red;
      case 'NS':
      case 'TBD':
        return Colors.blue;
      case 'PST':
      case 'CANC':
      case 'ABD':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTeamSide(String teamName, String logoUrl, bool isHome) {
    return Expanded(
      child: Row(
        mainAxisAlignment:
            isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isHome) ...[
            Expanded(
              child: Text(
                teamName,
                textAlign: TextAlign.end,
                style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          CachedNetworkImage(
            imageUrl: logoUrl,
            width: 24.sp,
            height: 24.sp,
            fit: BoxFit.contain,
            placeholder: (context, url) => SizedBox(
              width: 24.sp,
              height: 24.sp,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) =>
                Icon(Icons.shield, size: 24.sp, color: Colors.grey),
          ),
          if (isHome) ...[
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                teamName,
                textAlign: TextAlign.start,
                style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCenter(String homeScore, String awayScore, bool isLive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isLive
            ? Colors.red.withOpacity(0.1)
            : Colorscontainer.greenColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: isLive ? Border.all(color: Colors.red.withOpacity(0.2)) : null,
      ),
      child: Text(
        "$homeScore - $awayScore",
        style: GoogleFonts.ropaSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: isLive ? Colors.red : Colorscontainer.greenColor,
        ),
      ),
    );
  }

  Widget _buildFixtureTimeCenter(String dateTimeString) {
    // Use the timeFormatter to get localized time display
    String timeDisplay = extractTimeFromIso(dateTimeString);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        children: [
          Text(
            timeDisplay,
            textAlign: TextAlign.center,
            style: TextUtils.setTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: const Color.fromARGB(255, 194, 193, 193),
      child: ListView.builder(
        itemCount: 12,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colorscontainer.greyShade,
            ),
            height: 80.h,
            width: double.infinity,
          );
        },
      ),
    );
  }
}
