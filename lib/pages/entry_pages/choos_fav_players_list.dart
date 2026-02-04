import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../application/favourite_player/PlayerSelection_bloc.dart';
import '../../application/favourite_player/PlayerSelection_event.dart';
import '../../application/favourite_player/PlayerSelection_state.dart';
import '../../application/set_preference/set_preference_bloc.dart';
import '../../application/set_preference/set_preference_event.dart';
import '../../application/set_preference/set_preference_state.dart';

import '../../domain/player/Players_for_selection_model.dart';
import '../../localization/demo_localization.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';
import 'waiting_modal.dart';
import '../../components/routenames.dart';

class ChooseFavPlayerEntry extends StatefulWidget {
  final String selectedLanguage;

  const ChooseFavPlayerEntry({super.key, required this.selectedLanguage});

  @override
  State<ChooseFavPlayerEntry> createState() => _PlayerListState();
}

class _PlayerListState extends State<ChooseFavPlayerEntry>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool isSubmitting = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);

    context.read<PlayerSelectionBloc>().add(FetchPlayersRequested());
    context.read<PlayerSelectionBloc>().add(FetchPopularPlayersRequested());

    context
        .read<PlayerSelectionBloc>()
        .add(SearchPlayerByNameRequested(playerName: ""));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      context.read<PlayerSelectionBloc>().add(LoadMorePlayersRequested());
    }
  }

 void toggleSelection(int playerId) {
  final playerState = context.read<PlayerSelectionBloc>().state;
  final isSelecting = !playerState.selectedPlayerIds.contains(playerId);

  if (isSelecting) {
    // Log the follow event
    FirebaseAnalytics.instance.logEvent(
      name: 'follow_player',
      parameters: {
        'player_id': playerId,
        'screen': 'onboarding_entry',
      },
    );
  }

  context
      .read<PlayerSelectionBloc>()
      .add(TogglePlayerSelectionRequested(playerId: playerId));
}

  Future<void> _refresh() async {
    context.read<PlayerSelectionBloc>().add(FetchPlayersRequested());
    context.read<PlayerSelectionBloc>().add(FetchPopularPlayersRequested());
  }

  // Popular Players Title (only when not searching and has data)
  Widget _buildPopularTitle(PlayerSelectionState state) {
    if (state.searchResults.isNotEmpty || state.popularPlayers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 10.h),
        child: Text(
          DemoLocalizations.popular ?? "Popular Players",
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Popular Players Grid — EXACT SAME STYLE AS MAIN GRID
  Widget _buildPopularPlayersGrid(PlayerSelectionState state) {
    if (state.searchResults.isNotEmpty || state.popularPlayers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          mainAxisSpacing: 24.h,
          crossAxisSpacing: 20.w,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final player = state.popularPlayers[index];
            final isSelected = state.selectedPlayerIds.contains(player.id);

            return ModernPlayerCard(
              player: player,
              isSelected: isSelected,
              onTap: () => toggleSelection(player.id),
              selectedLanguage: widget.selectedLanguage,
            );
          },
          childCount: state.popularPlayers.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        context
            .read<PlayerSelectionBloc>()
            .add(SearchPlayerByNameRequested(playerName: ""));
        context.pop();
        return false;
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Add top padding to account for floating back button
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 20.h),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DemoLocalizations.your_favourite_player,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          textAlign: TextAlign.center,
                          DemoLocalizations.choose_your_fav_player,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 44.h,
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: DemoLocalizations.searchByName,
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black38,
                                fontSize: 14.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colorscontainer.greenColor,
                                size: 20.sp,
                              ),
                              filled: true,
                              fillColor: isDark ? Colors.white10 : Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 16.w),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22.r),
                                borderSide: BorderSide(
                                  color: Colorscontainer.greenColor
                                      .withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22.r),
                                borderSide: BorderSide(
                                  color: Colorscontainer.greenColor
                                      .withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22.r),
                                borderSide: BorderSide(
                                  color: Colorscontainer.greenColor,
                                  width: 1.8,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              _debounce?.cancel();
                              _debounce =
                                  Timer(const Duration(milliseconds: 400), () {
                                context.read<PlayerSelectionBloc>().add(
                                      SearchPlayerByNameRequested(
                                          playerName: value),
                                    );
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: BlocBuilder<PlayerSelectionBloc,
                              PlayerSelectionState>(
                            buildWhen: (p, c) =>
                                p.selectedPlayerIds.length !=
                                c.selectedPlayerIds.length,
                            builder: (context, state) {
                              final count = state.selectedPlayerIds.length;
                              if (count == 0) return const SizedBox.shrink();

                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colorscontainer.greenColor
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Text(
                                  '$count ${DemoLocalizations.players} ${DemoLocalizations.selected}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colorscontainer.greenColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                ),

                // Popular Players Title
                BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                  builder: (context, state) => _buildPopularTitle(state),
                ),

                // Popular Players Grid (same size & layout as main)
                BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                  builder: (context, state) => _buildPopularPlayersGrid(state),
                ),

                // Spacing between popular and all players
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),

                // Main Players Grid (All Players)
                BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                  builder: (context, state) {
                    if (state.status == PlayerSelectionStatus.loading &&
                        state.players.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colorscontainer.greenColor,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      );
                    }

                    if (state.status == PlayerSelectionStatus.failure &&
                        state.players.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100.h),
                            child: Column(
                              children: [
                                Icon(Icons.wifi_off_rounded,
                                    size: 60.sp, color: Colors.grey),
                                SizedBox(height: 16.h),
                                Text(DemoLocalizations.networkProblem,
                                    style: TextStyle(fontSize: 16.sp)),
                                SizedBox(height: 16.h),
                                ElevatedButton.icon(
                                  onPressed: _refresh,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(DemoLocalizations.tryAgain),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colorscontainer.greenColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final players = state.searchResults.isNotEmpty
                        ? state.searchResults
                        : state.players;

                    int itemCount = players.length;
                    if (state.isLoadingMore) itemCount += 1;
                    if (state.hasReachedMax && players.isNotEmpty)
                      itemCount += 1;

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 24.h,
                          crossAxisSpacing: 20.w,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (state.isLoadingMore &&
                                index == players.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.h),
                                  child: CircularProgressIndicator(
                                    color: Colorscontainer.greenColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            }

                            if (state.hasReachedMax &&
                                index ==
                                    players.length +
                                        (state.isLoadingMore ? 1 : 0)) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: Text(
                                    "No more players",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final player = players[index];
                            final isSelected =
                                state.selectedPlayerIds.contains(player.id);

                            return ModernPlayerCard(
                              player: player,
                              isSelected: isSelected,
                              onTap: () => toggleSelection(player.id),
                              selectedLanguage: widget.selectedLanguage,
                            );
                          },
                          childCount: itemCount,
                        ),
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),

            // FLOATING BACK BUTTON
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () {
                  context
                      .read<PlayerSelectionBloc>()
                      .add(SearchPlayerByNameRequested(playerName: ""));
                  context.pop();
                },
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colorscontainer.greenColor,
                    size: 24.sp,
                  ),
                ),
              ),
            ),

            // Next Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                        builder: (context, playerState) {
                          final hasSelection =
                              playerState.selectedPlayerIds.isNotEmpty;

                          return GestureDetector(
                            onTap: (hasSelection && !isSubmitting)
                                ? () {
                                    HapticFeedback.lightImpact();
                                    context
                                        .read<SetPreferenceBloc>()
                                        .add(SetPreferenceRequested());
                                  }
                                : null,
                            child: Opacity(
                              opacity:
                                  (hasSelection && !isSubmitting) ? 1.0 : 0.5,
                              child: AnimatedScale(
                                scale: (hasSelection && !isSubmitting)
                                    ? 1.0
                                    : 0.95,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colorscontainer.greenColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(28.r),
                                    border: Border.all(
                                      color: Colorscontainer.greenColor
                                          .withOpacity(0.4),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colorscontainer.greenColor
                                            .withOpacity(0.2),
                                        blurRadius: 12.r,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DemoLocalizations.next,
                                        style: TextUtils.setTextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colorscontainer.greenColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colorscontainer.greenColor,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Save Preferences Listener
            BlocListener<SetPreferenceBloc, SetPreferenceState>(
              listener: (context, state) {
                if (state.status == SetPreferenceStatus.loading) {
                  setState(() => isSubmitting = true);
                } else if (state.status == SetPreferenceStatus.success) {
                  context.goNamed(RouteNames.home);
                } else if (state.status == SetPreferenceStatus.failure) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Failed to save preferences. Please try again."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),

            // Loading Modal
            if (isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: WaitingModal(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ModernPlayerCard extends StatelessWidget {
  final PlayerSelectionModel player;
  final bool isSelected;
  final VoidCallback onTap;
  final String selectedLanguage;

  const ModernPlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.selectedLanguage,
  });

  String get displayName {
    switch (selectedLanguage) {
      case 'am':
      case 'tr':
        return player.amharicName;
      case 'or':
        return player.oromoName;
      case 'so':
        return player.somaliName;
      default:
        return player.englishName;
    }
  }

  String get teamName {
    switch (selectedLanguage) {
      case 'am':
      case 'tr':
        return player.team.amharicName;
      default:
        return player.team.englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colorscontainer.greenColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colorscontainer.greenColor.withOpacity(0.4)
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: isSelected ? 20 : 12,
              offset: Offset(0, isSelected ? 8 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isSelected ? 8.0 : 0.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    Colorscontainer.greenColor.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: player.photo.isNotEmpty
                            ? player.photo
                            : 'https://media.api-sports.io/football/players/${player.id}.png',
                        height: 62.w,
                        width: 62.w,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            (62.w * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        memCacheHeight:
                            (62.w * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/playershimmer.png',
                          fit: BoxFit.cover,
                        ),
                        placeholder: (context, url) => Container(
                          color: isDark ? Colors.white10 : Colors.grey[200],
                          child: Image.asset(
                            'assets/playershimmer.png',
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        displayName,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (player.team.logo.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: player.team.logo,
                          height: 13.w,
                          width: 13.w,
                          placeholder: (_, __) => SizedBox(width: 13.w),
                        ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
