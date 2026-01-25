import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;

import '../../../../bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_bloc.dart';
import '../../../../bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_event.dart';
import '../../../../bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_state.dart';
import '../../../../components/routenames.dart';
import '../../../../localization/demo_localization.dart';
import '../../../../main.dart';
import '../../../../models/teamName.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
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
  }

  Future<Color> _getOrLoadDominantColor(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) return Colors.blue;

    if (!_dominantColors.containsKey(logoUrl)) {
      final color = await getDominantColor(logoUrl);
      setState(() {
        _dominantColors[logoUrl] = color;
      });
    }
    return _dominantColors[logoUrl] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocBuilder<MyfavouriteteamsBloc, MyfavouriteteamsState>(
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
                  final List<TeamName> teams = state.teams;

                  if (teams.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 150.0, left: 20, right: 20),
                        child: Text(
                          DemoLocalizations.no_favorite_team,
                          style: TextUtils.setTextStyle(
                            fontSize: 15.sp,
                            color: Colorscontainer.greenColor,
                            engFont: 12.sp,
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 0),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w, // reduced
                        crossAxisSpacing: 10.w, // reduced
                        childAspectRatio:
                            1.05, // increased → makes cards smaller & taller
                      ),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final TeamName team = teams[index];
                        _getOrLoadDominantColor(team.logo);

                        String name = team.amharicName;
                        if (localLanguageNotifier.value == 'am' ||
                            localLanguageNotifier.value == 'tr') {
                          name = team.amharicName;
                        } else if (localLanguageNotifier.value == 'or') {
                          name = team.oromoName;
                        } else if (localLanguageNotifier.value == 'so') {
                          name = team.somaliName;
                        }

                        return InkWell(
                          onTap: () {
                            context.pushNamed(RouteNames.teamProfilePage,
                                extra: team);
                          },
                          child: Container(
                            margin: EdgeInsets.all(4.w), // small outer margin
                            padding: EdgeInsets.only(
                                top: 10.h,
                                left: 10.w,
                                right: 10.w,
                                bottom: 8.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.brightness == Brightness.dark
                                    ? colorScheme.surfaceContainerHighest
                                        .withOpacity(0.2)
                                    : colorScheme.outline.withOpacity(0.1),
                                width: 1.5,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.brightness == Brightness.dark
                                      ? colorScheme.surface.withOpacity(0.8)
                                      : colorScheme.surface,
                                  _dominantColors[team.logo]?.withOpacity(
                                          colorScheme.brightness ==
                                                  Brightness.dark
                                              ? 0.4
                                              : 0.8) ??
                                      colorScheme.primary.withOpacity(
                                          colorScheme.brightness ==
                                                  Brightness.dark
                                              ? 0.4
                                              : 0.8),
                                ],
                              ),
                              boxShadow: [
                                if (colorScheme.brightness ==
                                    Brightness.light) ...[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ] else ...[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ],
                            ),
                            child: Column(
                              children: [
                                // Smaller logo
                                Expanded(
                                  flex: 2, // reduced from 3
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Image.network(
                                      team.logo ?? '',
                                      fit: BoxFit.contain,
                                      height: 60.h, // explicit smaller height
                                      errorBuilder: (_, __, ___) => Image.asset(
                                          'assets/club-icon.png',
                                          height: 60.h),
                                    ),
                                  ),
                                ),
                                // Smaller text area
                                Expanded(
                                  flex: 1, // reduced from 2
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: TextUtils.setTextStyle(
                                          fontSize: 12.sp, // reduced
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        team.venuename ?? '',
                                        style: TextUtils.setTextStyle(
                                          fontSize: 10.sp, // reduced
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

// ... (rest of the file: _showTeamBottomSheet, TeamBottomSheet, getDominantColor remain unchanged)}
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
