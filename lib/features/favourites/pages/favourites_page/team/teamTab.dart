import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:blogapp/state/bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_event.dart';
import 'package:blogapp/state/bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_state.dart';
import 'package:blogapp/state/application/following/following_bloc.dart';
import 'package:blogapp/state/application/following/following_state.dart';

import 'package:blogapp/state/application/following/following_event.dart';
import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/teamName.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'teams_choosing_fav.dart';

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  final Map<String, Color> _dominantColors = {};

  @override
  void initState() {
    super.initState();
    // Pass empty list since teamsIds is required
    // This tells the BLoC: "load favorite teams" (logic should be in the BLoC to handle empty list)
    context.read<MyfavouriteteamsBloc>().add(LoadFavouriteTeams(teamsIds: []));
    context.read<FollowingBloc>().add(LoadFollowedTeams());
  }

  Future<void> _showTeamBottomSheet() async {
    // Get the current favorite team IDs from the BLoC state
    final currentFavoriteIds = context
        .read<MyfavouriteteamsBloc>()
        .state
        .teams
        .map((team) => team.id) // assuming TeamName has an 'id' field (int)
        .toSet();

    await TeamBottomSheet.show(context, selectedTeamIDs: currentFavoriteIds);

    // After closing the bottom sheet, refresh the list
    context.read<MyfavouriteteamsBloc>().add(LoadFavouriteTeams(teamsIds: []));
    context.read<FollowingBloc>().add(LoadFollowedTeams());
  }

  Future<Color> _getOrLoadDominantColor(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) return Colors.blue;
    if (!logoUrl.startsWith('http')) return Colors.blue;

    if (!_dominantColors.containsKey(logoUrl)) {
      final color = await getDominantColor(logoUrl);
      setState(() {
        _dominantColors[logoUrl] = color;
      });
    }
    return _dominantColors[logoUrl] ?? Colors.blue;
  }

  String _getTeamDisplayName(TeamName team) {
    if (localLanguageNotifier.value == 'am' ||
        localLanguageNotifier.value == 'tr') {
      return team.amharicName;
    }
    if (localLanguageNotifier.value == 'or') {
      return team.oromoName;
    }
    if (localLanguageNotifier.value == 'so') {
      return team.somaliName;
    }
    return team.englishName;
  }

  String _resolveTeamLogo(TeamName team) {
    final logo = team.logo ?? '';
    if (logo.isNotEmpty && logo.startsWith('http')) return logo;
    return 'https://media.api-sports.io/football/teams/${team.id}.png';
  }

  String _getVenueLine(TeamName team) {
    final venue = (team.venuename ?? '').trim();
    final city = (team.venuecity ?? '').trim();
    final founded = (team.founded ?? '').trim();
    final capacity = (team.venuecapacity ?? '').trim();
    final surface = (team.venuesurface ?? '').trim();

    final parts = <String>[];
    if (venue.isNotEmpty) parts.add(venue);
    if (city.isNotEmpty && parts.length < 2) parts.add(city);
    if (parts.length < 2 && founded.isNotEmpty) {
      parts.add('Est. $founded');
    }
    if (parts.length < 2 && capacity.isNotEmpty) {
      parts.add('$capacity cap');
    }
    if (parts.length < 2 && surface.isNotEmpty) parts.add(surface);

    return parts.join(' • ');
  }

  Widget _buildTeamCard(
    TeamName team,
    Color tint,
    ColorScheme colorScheme,
  ) {
    final name = _getTeamDisplayName(team).trim().isNotEmpty
        ? _getTeamDisplayName(team)
        : team.englishName;
    final venueLine = _getVenueLine(team);
    final logoUrl = _resolveTeamLogo(team);

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () {
        context.pushNamed(RouteNames.teamProfilePage, extra: team);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
                border: Border.all(
                  color: tint.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tint.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => _buildPlaceholderIcon(),
                  errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              style: TextUtils.setTextStyle(
                fontSize: 11.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (venueLine.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                venueLine,
                style: TextUtils.setTextStyle(
                  fontSize: 9.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocBuilder<FollowingBloc, FollowingState>(
              builder: (context, followingState) {
                final followedIds = followingState.followedTeams.toSet();

                return BlocBuilder<MyfavouriteteamsBloc, MyfavouriteteamsState>(
                  builder: (context, state) {
                    if (state.status == favTeamStatus.requested) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 180.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/mirchawoche.gif',
                                width: 120.w,
                                height: 130.h,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    if (state.status == favTeamStatus.success) {
                      final List<TeamName> teams = state.teams
                          .where((team) => followedIds.contains(team.id))
                          .toList();

                      if (teams.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 120.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 70.w,
                                  height: 70.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colorscontainer.greenColor
                                        .withOpacity(0.12),
                                    border: Border.all(
                                      color: Colorscontainer.greenColor
                                          .withOpacity(0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.star_outline_rounded,
                                    size: 32.sp,
                                    color: Colorscontainer.greenColor,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  DemoLocalizations.no_favorite_team,
                                  style: TextUtils.setTextStyle(
                                    fontSize: 14.sp,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                        child: Builder(
                          builder: (context) {
                            final width = MediaQuery.of(context).size.width;
                            final crossAxisCount = width >= 900
                                ? 5
                                : width >= 700
                                    ? 4
                                    : width >= 520
                                        ? 3
                                        : 2;
                            final cardExtent = width >= 700 ? 160.h : 130.h;

                            return GridView.builder(
                              padding: EdgeInsets.only(bottom: 110.h),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 10.h,
                                crossAxisSpacing: 10.w,
                                mainAxisExtent: cardExtent,
                              ),
                              itemCount: teams.length,
                              itemBuilder: (context, index) {
                                final TeamName team = teams[index];
                                final logoUrl = _resolveTeamLogo(team);
                                _getOrLoadDominantColor(logoUrl);
                                final tint = _dominantColors[logoUrl] ??
                                    colorScheme.primary;

                                return _buildTeamCard(team, tint, colorScheme);
                              },
                            );
                          },
                        ),
                      );
                    }

                    if (state.status == favTeamStatus.failure) {
                      return Center(
                        child: Text(
                          DemoLocalizations.informationNotFound,
                          style: TextUtils.setTextStyle(
                              color: Colors.red, fontSize: 16.sp),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),

          // Floating Add Button (kept same size)
          Positioned(
            bottom: 20.h,
            right: 24.w,
            child: InkWell(
              onTap: _showTeamBottomSheet,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.brightness == Brightness.dark
                          ? colorScheme.primary.withOpacity(0.6)
                          : colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(
                          colorScheme.brightness == Brightness.dark
                              ? 0.2
                              : 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }


// Add the missing placeholder icon builder method
Widget _buildPlaceholderIcon() {
  return Image.asset(
    'assets/club-icon.png',
    width: 40.w,
    height: 40.h,
    fit: BoxFit.contain,
  );
}
}

class TeamBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required Set<int> selectedTeamIDs,
  }) async {
    await showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return TeamsPage(selectedTeamIDs: selectedTeamIDs);
          },
        );
      },
    );
  }
}

Future<Color> getDominantColor(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    final image = await decodeImageFromList(bytes);

    final palette = await PaletteGenerator.fromImage(image);
    return palette.dominantColor?.color ?? Colors.blue;
  } catch (e) {
    return Colors.blue;
  }
}
