import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:blogapp/components/getAmharicDay.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/fixtures/stat.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/matches/pages/matches/matchDetail.dart';

class H2HMatchList extends StatelessWidget {
  final List<Stat> statList;

  const H2HMatchList({super.key, required this.statList});

  @override
  Widget build(BuildContext context) {
    if (statList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            DemoLocalizations.no_h2h_found, // Localized Empty State
            style: TextUtils.setTextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 13.h, bottom: 0.h),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colorscontainer.greenColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                DemoLocalizations.head2head, // Localized Title
                style: TextUtils.setTextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          itemCount: statList.length,
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return H2HMatchCard(stat: statList[index]);
          },
        ),
      ],
    );
  }
}

class H2HMatchCard extends StatelessWidget {
  final Stat stat;
  const H2HMatchCard({super.key, required this.stat});

  String _getLocalizedLeagueName(Stat stat) {
    // Match by league ID for accuracy
    switch (stat.leagueId) {
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
        return stat.leagueName ?? ""; // Fallback to API name
    }
  }

  // Updated method to show Ethiopian calendar dates
  String _getLocalizedDate(String? dateStr, String langCode) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr);

      if (langCode == localLanguageNotifier.value) {
        // Use Ethiopian calendar format
        String ethiopianDate = getAmharicStringDay(dateStr);
        return ethiopianDate;
      } else {
        // Standard English format: e.g., "Fri, 09/01/2026"
        return DateFormat('EEE, dd/MM/yyyy').format(dt);
      }
    } catch (e) {
      return stat.dateOnly ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchDetailsPage(
            stat: stat,
            leagueName: stat.leagueName ?? "",
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // HEADER: LEAGUE & LOCALIZED DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (_getLeagueLogoUrl() != null)
                        CachedNetworkImage(
                          imageUrl: _getLeagueLogoUrl()!,
                          height: 16.sp,
                          width: 16.sp,
                          errorWidget: (context, url, error) => Icon(
                              Icons.emoji_events,
                              size: 14.sp,
                              color: Colors.grey),
                        ),
                      if (_getLeagueLogoUrl() != null) SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          // Changed from round to season
                          "${_getLocalizedLeagueName(stat)} | ${stat.season != null ? '${stat.season}' : ''}",
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
                // DATE WITH ETHIOPIAN CALENDAR SUPPORT
                ValueListenableBuilder(
                  valueListenable: localLanguageNotifier,
                  builder: (context, locale, child) {
                    return Text(
                      _getLocalizedDate(
                          stat.dateString, localLanguageNotifier.value),
                      style: TextUtils.setTextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
            Divider(height: 20.h, thickness: 0.5),

            // TEAM LOGOS AND SCORES
            Row(
              children: [
                _buildTeamSide(stat.homeTeam, true),
                _buildScoreCenter(stat),
                _buildTeamSide(stat.awayTeam, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get valid league logo URL
  String? _getLeagueLogoUrl() {
    String? logoUrl = stat.leaguelogo;

    // If logo is empty, null, or invalid, try to construct from league ID
    if (logoUrl == null || logoUrl.isEmpty || logoUrl == 'null') {
      if (stat.leagueId != null) {
        return 'https://media.api-sports.io/football/leagues/${stat.leagueId}.png';
      }
      return null;
    }

    return logoUrl;
  }

  // Helper method to get valid team logo URL
  String _getTeamLogoUrl(dynamic team) {
    String logoUrl = team.logo?.toString() ?? '';

    // If logo is empty or invalid, use API-Football media URL with team ID
    if (logoUrl.isEmpty || logoUrl == 'null') {
      return 'https://media.api-sports.io/football/teams/${team.id}.png';
    }

    return logoUrl;
  }

  Widget _buildTeamSide(dynamic team, bool isHome) {
    return Expanded(
      child: Row(
        mainAxisAlignment:
            isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isHome) ...[
            Expanded(
                child: _teamNameText(team.name, team.winner == true, true)),
            SizedBox(width: 8.w),
          ],
          CachedNetworkImage(
            imageUrl: _getTeamLogoUrl(team),
            width: 24.sp,
            height: 24.sp,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) =>
                Icon(Icons.shield, size: 20.sp, color: Colors.grey),
          ),
          if (isHome) ...[
            SizedBox(width: 8.w),
            Expanded(
                child: _teamNameText(team.name, team.winner == true, false)),
          ],
        ],
      ),
    );
  }

  Widget _teamNameText(String? name, bool isWinner, bool textAlignEnd) {
    return Text(
      name ?? "",
      textAlign: textAlignEnd ? TextAlign.end : TextAlign.start,
      style: TextUtils.setTextStyle(
        fontSize: 13.sp,
        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildScoreCenter(Stat stat) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colorscontainer.greenColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        "${stat.homeTeam.goal ?? 0} - ${stat.awayTeam.goal ?? 0}",
        style: GoogleFonts.ropaSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colorscontainer.greenColor,
        ),
      ),
    );
  }
}
