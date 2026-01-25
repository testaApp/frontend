import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../../../bloc/standings/bloc/content_bloc.dart';
import '../../../../../bloc/standings/bloc/content_state.dart';
import '../../../../../components/routenames.dart';
import '../../../../../components/timeFormatter.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../models/fixtures/stat.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';

class TodaysMatchesSection extends StatelessWidget {
  const TodaysMatchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentBloc, ContentState>(
      builder: (context, state) {
        final hasMatches = state.todaysMatches.any((match) =>
            match.leagueId == 39 ||
            match.leagueId == 2 ||
            match.leagueId == 363);

        if (!hasMatches) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeader(),
              _buildMatchesList(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.sportscourt,
            size: 16.sp,
            color: Colors.grey[700],
          ),
          SizedBox(width: 4.w),
          Text(
            DemoLocalizations.next_matchs,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              color: Colors.grey[700],
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(ContentState state) {
    return Column(
      children: [
        TodayMatchesWidget(
          matches: state.todaysMatches
              .where((match) => match.leagueId == 39)
              .toList(),
          logoPath: 'https://media.api-sports.io/football/leagues/39.png',
        ),
        TodayMatchesWidget(
          matches: state.todaysMatches
              .where((match) => match.leagueId == 2)
              .toList(),
          logoPath: 'https://media.api-sports.io/football/leagues/2.png',
        ),
        TodayMatchesWidget(
          matches: state.todaysMatches
              .where((match) => match.leagueId == 363)
              .toList(),
          logoPath: 'https://media.api-sports.io/football/leagues/363.png',
        ),
      ],
    );
  }
}

class TodayMatchesWidget extends StatelessWidget {
  final List<Stat> matches;
  final String logoPath;

  const TodayMatchesWidget({
    super.key,
    required this.matches,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final filteredMatches =
        matches.where((match) => match.status == 'NS').toList();

    if (filteredMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredMatches.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) =>
            _buildMatchCard(context, filteredMatches[index]),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Stat match) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).goNamed(
          RouteNames.matchDetail,
          queryParameters: {'fixtureId': match.fixtureId.toString()},
        );
      },
      child: FutureBuilder<List<Color>>(
        future: Future.wait([
          _getDominantColor(match.homeTeam.logo ?? ''),
          _getDominantColor(match.awayTeam.logo ?? ''),
        ]),
        builder: (context, snapshot) {
          final homeColor = snapshot.data?[0] ?? Colorscontainer.greenColor;
          final awayColor =
              snapshot.data?[1] ?? Theme.of(context).colorScheme.secondary;

          return Container(
            width: 200.w,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: CachedNetworkImageProvider(logoPath),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.3),
                  BlendMode.dstATop,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        homeColor.withOpacity(0.7),
                        homeColor.withOpacity(0.3),
                        awayColor.withOpacity(0.3),
                        awayColor.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.4, 0.6, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTeamInfo(match.homeTeam.name ?? '',
                              match.homeTeam.logo ?? '', homeColor),
                          Text(
                            'Vs',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          _buildTeamInfo(match.awayTeam.name ?? '',
                              match.awayTeam.logo ?? '', awayColor),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        formatMatchTime(match.dateString ?? ''),
                        style: TextUtils.setTextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, String logoUrl, Color textColor) {
    return Expanded(
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: logoUrl,
            width: 40.w,
            height: 40.h,
            placeholder: (context, url) => SizedBox(
              width: 40.w,
              height: 40.h,
            ),
            errorWidget: (context, url, error) =>
                Icon(Icons.error, size: 40.w, color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              teamName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextUtils.setTextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color> _getDominantColor(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(imageUrl),
      size: const Size(100, 100),
    );
    return paletteGenerator.dominantColor?.color ?? Colors.blue;
  }
}
