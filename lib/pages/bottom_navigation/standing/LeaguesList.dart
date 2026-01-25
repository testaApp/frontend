import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../localization/demo_localization.dart';
import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/text_utils.dart';

class LeaguesList extends StatefulWidget {
  const LeaguesList({super.key, required this.index, required this.current});
  final int index;
  final int current;

  @override
  State<LeaguesList> createState() => _LeaguesListState();
}

class _LeaguesListState extends State<LeaguesList> {
  late List<String> localizedLeagueNames;
  @override
  initState() {
    super.initState();
    localizedLeagueNames = [
      DemoLocalizations.premierLeague,
      DemoLocalizations.championsLeague,
      DemoLocalizations.ethiopianPremierLeague,
      DemoLocalizations.laLiga,
      DemoLocalizations.ligue1,
      DemoLocalizations.serieA,
      DemoLocalizations.bundesliga,
      DemoLocalizations.europaLeague,
      DemoLocalizations.saudiProLeague,
      DemoLocalizations.faCup,
      DemoLocalizations.carabaoEFL,
      DemoLocalizations.englishLeagueOne,
      DemoLocalizations.englishLeagueTwo,
      DemoLocalizations.englishChampionsShip,
      DemoLocalizations.turkeyLig1,
      DemoLocalizations.egyptPremierLeague,
      DemoLocalizations.southAfricaPremierSoccerLeague,
      DemoLocalizations.MLS,
      DemoLocalizations.netherlandEredivisie,
      DemoLocalizations.belgiumJupilerProLeague,
      DemoLocalizations.qatarStarsLeague,
      DemoLocalizations.portugalPrimeiraLiga,
      DemoLocalizations.scotlandPremiership,
      DemoLocalizations.africanCup,
      DemoLocalizations.europeanCup,
      DemoLocalizations.europeanNationsLeague,
      DemoLocalizations.copaAmerica,
      DemoLocalizations.olympicsmen,
      DemoLocalizations.wcQualification,
    ];
  }

  String getLeagueImageUrl(int index) {
    // Use the league IDs from the constants file
    final leagueId = leagueids[index];
    return 'https://media.api-sports.io/football/leagues/$leagueId.png';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: widget.index == widget.current
                  ? Colorscontainer.greenColor
                  : Colors.grey,
              radius: 29.h,
              child: CircleAvatar(
                radius: 27.h,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25.h,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: getLeagueImageUrl(widget.index),
                      fit: BoxFit.contain,
                      height: 50.h,
                      width: 50.h,
                      placeholder: (context, url) => CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colorscontainer.greenColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/club-icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
                // width: 40.h,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    localizedLeagueNames[widget.index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      fontSize: 10.sp,
                      overflow: TextOverflow.ellipsis,
                      color: widget.index == widget.current
                          ? Colorscontainer.greenColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ))
          ],
        ));
  }
}
