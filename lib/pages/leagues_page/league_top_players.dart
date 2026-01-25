import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/leagues_page/top_assist/top_assist_bloc.dart';
import '../../bloc/leagues_page/top_red/top_red_bloc.dart';
import '../../bloc/leagues_page/top_scorer/top_scorers_bloc.dart';
import '../../bloc/leagues_page/top_yellow_card/top_yellow_bloc.dart';
import '../../localization/demo_localization.dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_assists.dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_scorers.dart';

import '../bottom_navigation/standing/leagues_page/top_scorers/top_yellow_card.dart';
import '../bottom_navigation/standing/leagues_page/top_scorers/top_red_card .dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';

class TopScorersPage extends StatelessWidget {
  final String logo;
  final int leagueId;
  const TopScorersPage({super.key, required this.logo, required this.leagueId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TopScorersBloc()),
        BlocProvider(create: (context) => TopAssistorsBloc()),
        BlocProvider(create: (context) => TopRedCardsBloc()),
        BlocProvider(create: (context) => TopYellowCardsBloc()),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  _buildStatsCard(
                    context,
                    TopScorersView(leagueId: leagueId, logo: logo),
                    'goals',
                  ),
                  SizedBox(height: 16.h),
                  _buildStatsCard(
                    context,
                    TopAssistorsView(leagueId: leagueId, logo: logo),
                    'assists',
                  ),
                  SizedBox(height: 16.h),
                  _buildStatsCard(
                    context,
                    TopYellowCardView(leagueId: leagueId, logo: logo),
                    'yellow',
                  ),
                  SizedBox(height: 16.h),
                  _buildStatsCard(
                    context,
                    TopRedCardView(leagueId: leagueId, logo: logo),
                    'red',
                  ),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Widget child, String type) {
    String imagePath = '';
    switch (type) {
      case 'goals':
        imagePath = 'assets/ball.png';
        break;
      case 'assists':
        imagePath = 'assets/chama.png';
        break;
      case 'yellow':
        imagePath = 'assets/yellow_card.png';
        break;
      case 'red':
        imagePath = 'assets/red_card.png';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colorscontainer.greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 24.w,
                  height: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getLocalizedTitle(type),
                  style: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  String _getLocalizedTitle(String type) {
    switch (type) {
      case 'goals':
        return DemoLocalizations.topScorer;
      case 'assists':
        return DemoLocalizations.topAssist;
      case 'yellow':
        return DemoLocalizations.yellowCards;
      case 'red':
        return DemoLocalizations.redCard;
      default:
        return '';
    }
  }
}
