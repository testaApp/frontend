import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Custom imports
import 'package:blogapp/state/bloc/lineups/lineups_bloc.dart';
import 'package:blogapp/state/bloc/lineups/lineups_event.dart';
import 'package:blogapp/state/bloc/lineups/lineups_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/widgets/match_detail/lineupWgt.dart';
import 'package:blogapp/shared/widgets/match_detail/substitutes.dart';

// Constants
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class LineupsView extends StatefulWidget {
  const LineupsView({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.fixtureId,
  });

  final String? homeTeamName;
  final String? awayTeamName;
  final int? homeTeamId;
  final int? awayTeamId;
  final int fixtureId; // Made non-nullable since it's required

  @override
  State<LineupsView> createState() => _LineupsViewState();
}

class _LineupsViewState extends State<LineupsView> {
  int selectedIdx = 0; // 0 = Home, 1 = Away

  @override
  void initState() {
    super.initState();
    context.read<LineupsBloc>().add(
          LineupsRequested(
            fixtureId: widget.fixtureId,
            homeTeamId: widget.homeTeamId!,
            awayTeamId: widget.awayTeamId!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: BlocBuilder<LineupsBloc, LineupsState>(
        builder: (context, state) {
          // Loading State
          if (state.lineupsStatus == LineupStatus.requestInProgress ||
              state.lineupsStatus == LineupStatus.unknown) {
            return SizedBox(
              height: 300.h,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.grey),
              ),
            );
          }

          // Success State (with or without fallback)
          if (state.lineupsStatus == LineupStatus.requestSuccess &&
              state.lineups.isNotEmpty) {
            final currentLineup = state.lineups[selectedIdx];

            return Column(
              children: [
                SizedBox(height: 15.h),

                // Team Toggle Selector
                _buildTeamSelector(),

                SizedBox(height: 25.h),

                if (state.isFallback)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        // Use a very light blue or a neutral grey instead of orange
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Better for multi-line text
                        children: [
                          Icon(
                              Icons
                                  .lightbulb_outline, // Lightbulb feels like a "pro-tip" or info
                              color: Colors.blue.shade600,
                              size: 20.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              DemoLocalizations.previousMatchLineup,
                              style: TextUtils.setTextStyle(
                                fontSize: 13
                                    .sp, // Slightly smaller feels less aggressive
                                fontWeight: FontWeight.w500,
                                color: Colors
                                    .blue.shade900, // Deep blue for readability
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Formation Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colorscontainer.greyShade.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: Colorscontainer.greenColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    "${DemoLocalizations.lineUp}: ${currentLineup.formation ?? '-'}",
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // Field Graphic
                SizedBox(
                  height: 460.h,
                  child: LineupsWgt(lineup: currentLineup),
                ),

                SizedBox(height: 25.h),

                // Manager Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DemoLocalizations.coach,
                        style: TextUtils.setTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildManagerCard(currentLineup),
                    ],
                  ),
                ),

                SizedBox(height: 15.h),

                // Substitutes Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DemoLocalizations.substitutionPlayers,
                        style: TextUtils.setTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SubstitutesTable(currentLineup.substitutes),
                    ],
                  ),
                ),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 40.h),
              ],
            );
          }

          // Error or Empty State
          final bool hasError =
              state.lineupsStatus == LineupStatus.requestFailure;
          final String message = hasError
              ? (DemoLocalizations.error ?? "Error loading lineups")
              : (state.fallbackMessage ??
                  DemoLocalizations.unableToFindAlignment ??
                  "Lineup not Available");

          return SizedBox(
            height: 300.h,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasError
                        ? Icons.error_outline
                        : Icons.sentiment_dissatisfied,
                    size: 48.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    DemoLocalizations.unableToFindAlignment ??
                        "Lineup not Available",
                    style: TextUtils.setTextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<LineupsBloc>().add(
                                LineupsRequested(
                                  fixtureId: widget.fixtureId,
                                  homeTeamId: widget.homeTeamId!,
                                  awayTeamId: widget.awayTeamId!,
                                ),
                              );
                        },
                        child: Text(DemoLocalizations.tryAgain ?? "Retry"),
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

  // Team Selector
  Widget _buildTeamSelector() {
    final bool isHomeSelected = selectedIdx == 0;

    return Container(
      height: 52.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated sliding background
          AnimatedAlign(
            alignment:
                isHomeSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40.w) / 2,
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colorscontainer.greenColor,
                    Colorscontainer.greenColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colorscontainer.greenColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Row(
            children: [
              Expanded(
                child: _buildSlidingTabItem(
                  title: widget.homeTeamName ?? "Home",
                  index: 0,
                  isSelected: isHomeSelected,
                ),
              ),
              Expanded(
                child: _buildSlidingTabItem(
                  title: widget.awayTeamName ?? "Away",
                  index: 1,
                  isSelected: !isHomeSelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingTabItem({
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (selectedIdx != index) {
          setState(() {
            selectedIdx = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          style: TextUtils.setTextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
            fontSize: isSelected ? 16.sp : 15.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ).copyWith(
            shadows: isSelected
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  // Manager Card – null-safe
  Widget _buildManagerCard(dynamic currentLineup) {
    final coach = currentLineup.coach;
    final String coachName =
        coach?.name ?? DemoLocalizations.coach ?? "Unknown Coach";
    final String? coachPhoto = coach?.photo;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colorscontainer.greyShade2.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colorscontainer.greyShade,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: coachPhoto ?? '',
                width: 44.r,
                height: 44.r,
                fit: BoxFit.cover,
                placeholder: (_, __) => Icon(
                  Icons.person,
                  size: 24.r,
                  color: Colors.white70,
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.person,
                  size: 24.r,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coachName,
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                DemoLocalizations.coach,
                style: TextUtils.setTextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
