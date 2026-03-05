import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../state/application/favourite_player/PlayerSelection_bloc.dart';
import '../../../state/application/favourite_player/PlayerSelection_event.dart';
import '../../../state/application/favourite_player/PlayerSelection_state.dart';
import '../../../state/application/set_preference/set_preference_bloc.dart';
import '../../../state/application/set_preference/set_preference_event.dart';
import '../../../state/application/set_preference/set_preference_state.dart';

import '../../../domain/player/Players_for_selection_model.dart';
import '../../../localization/demo_localization.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_utils.dart';
import '../../../components/routenames.dart';
import '../../../main.dart';
import 'waiting_modal.dart';
import 'device_info.dart';

class ChooseFavPlayerEntry extends StatefulWidget {
  final String selectedLanguage;

  const ChooseFavPlayerEntry({super.key, required this.selectedLanguage});

  @override
  State<ChooseFavPlayerEntry> createState() => _PlayerListState();
}

class _PlayerListState extends State<ChooseFavPlayerEntry> {
  static const int _gridCrossAxisCount = 3;
  static const double _gridChildAspectRatio = 0.75;
  static const double _loadMoreThreshold = 600;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isSubmitting = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    final bloc = context.read<PlayerSelectionBloc>();
    bloc.add(FetchPlayersRequested());
    bloc.add(FetchPopularPlayersRequested());
    unawaited(
      globalAnalyticsService.logOnboardingStepViewed('favourite_player_select'),
    ); deviceInfo();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients ||
        _searchController.text.trim().isNotEmpty) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) {
      return;
    }

    final bloc = context.read<PlayerSelectionBloc>();
    final state = bloc.state;
    if (!state.isLoadingMore && !state.hasReachedMax) {
      bloc.add(LoadMorePlayersRequested());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final trimmed = value.trim();
      if (trimmed.length >= 2) {
        unawaited(
          globalAnalyticsService.logOnboardingStepAction(
            stepName: 'favourite_player_select',
            action: 'search',
            extraParameters: {'query_length': trimmed.length},
          ),
        );
      }
      context.read<PlayerSelectionBloc>().add(
            SearchPlayerByNameRequested(playerName: trimmed),
          );
    });
  }

  void _clearSearchAndPop() {
    _debounce?.cancel();
    _searchController.clear();
    unawaited(
      globalAnalyticsService.logOnboardingStepAction(
        stepName: 'favourite_player_select',
        action: 'back_clicked',
        playerCount:
            context.read<PlayerSelectionBloc>().state.selectedPlayerIds.length,
      ),
    );
    context
        .read<PlayerSelectionBloc>()
        .add(SearchPlayerByNameRequested(playerName: ''));
    context.pop();
  }

  void toggleSelection(int playerId) {
    final playerState = context.read<PlayerSelectionBloc>().state;
    final isSelecting = !playerState.selectedPlayerIds.contains(playerId);
    final playerName = _resolvePlayerName(playerId, playerState);
    unawaited(
      globalAnalyticsService.logOnboardingPlayerSelection(
        playerId: playerId,
        playerName: playerName,
        isSelected: isSelecting,
        source: 'favourite_player_select',
      ),
    );

    context
        .read<PlayerSelectionBloc>()
        .add(TogglePlayerSelectionRequested(playerId: playerId));
  }

  Future<void> _refresh() async {
    _debounce?.cancel();
    final bloc = context.read<PlayerSelectionBloc>();
    _searchController.clear();
    bloc.add(SearchPlayerByNameRequested(playerName: ''));
    bloc.add(FetchPlayersRequested());
    bloc.add(FetchPopularPlayersRequested());
  }

  bool get _hasActiveSearch => _searchController.text.trim().isNotEmpty;

  String _resolvePlayerName(int playerId, PlayerSelectionState state) {
    for (final player in state.searchResults) {
      if (player.id == playerId) return player.englishName;
    }
    for (final player in state.players) {
      if (player.id == playerId) return player.englishName;
    }
    for (final player in state.popularPlayers) {
      if (player.id == playerId) return player.englishName;
    }
    return 'unknown_player';
  }

  SliverGridDelegateWithFixedCrossAxisCount _playerGridDelegate() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _gridCrossAxisCount,
      childAspectRatio: _gridChildAspectRatio,
      mainAxisSpacing: 24.h,
      crossAxisSpacing: 20.w,
    );
  }

  // Popular Players Title (only when not searching and has data)
  Widget _buildPopularTitle(PlayerSelectionState state) {
    if (_hasActiveSearch || state.popularPlayers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 10.h),
        child: Text(
          DemoLocalizations.popular,
          style: TextUtils.setTextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Popular Players Grid — EXACT SAME STYLE AS MAIN GRID
  Widget _buildPopularPlayersGrid(PlayerSelectionState state) {
    if (_hasActiveSearch || state.popularPlayers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final selectedIds = state.selectedPlayerIds.toSet();
    final avatarCacheSize =
        (62.w * MediaQuery.devicePixelRatioOf(context)).round();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
      sliver: SliverGrid(
        gridDelegate: _playerGridDelegate(),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final player = state.popularPlayers[index];
            final isSelected = selectedIds.contains(player.id);

            return ModernPlayerCard(
              player: player,
              isSelected: isSelected,
              onTap: () => toggleSelection(player.id),
              selectedLanguage: widget.selectedLanguage,
              avatarCacheSize: avatarCacheSize,
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
    final topInset = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _clearSearchAndPop();
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
                  child: SizedBox(height: topInset + 45.h),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DemoLocalizations.your_favourite_player,
                          style: TextUtils.setTextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          textAlign: TextAlign.center,
                          DemoLocalizations.choose_your_fav_player,
                          style: TextUtils.setTextStyle(
                            fontSize: 13.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 44.h,
                          child: TextFormField(
                            controller: _searchController,
                            style: TextUtils.setTextStyle(
                              fontSize: 14.5.sp,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: DemoLocalizations.searchByName,
                              hintStyle: TextUtils.setTextStyle(
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
                                      .withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22.r),
                                borderSide: BorderSide(
                                  color: Colorscontainer.greenColor
                                      .withValues(alpha: 0.3),
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
                            onChanged: _onSearchChanged,
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
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Text(
                                  '$count ${DemoLocalizations.players} ${DemoLocalizations.selected}',
                                  style: TextUtils.setTextStyle(
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
                  buildWhen: (previous, current) =>
                      previous.popularPlayers != current.popularPlayers ||
                      previous.searchResults != current.searchResults,
                  builder: (context, state) => _buildPopularTitle(state),
                ),

                // Popular Players Grid (same size & layout as main)
                BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                  buildWhen: (previous, current) =>
                      previous.popularPlayers != current.popularPlayers ||
                      previous.searchResults != current.searchResults ||
                      previous.selectedPlayerIds != current.selectedPlayerIds,
                  builder: (context, state) => _buildPopularPlayersGrid(state),
                ),

                // Spacing between popular and all players
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),

                // Main Players Grid (All Players)
                BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status ||
                      previous.players != current.players ||
                      previous.searchResults != current.searchResults ||
                      previous.selectedPlayerIds != current.selectedPlayerIds ||
                      previous.isLoadingMore != current.isLoadingMore ||
                      previous.hasReachedMax != current.hasReachedMax,
                  builder: (context, state) {
                    final hasActiveSearch = _hasActiveSearch;
                    if (state.status == PlayerSelectionStatus.loading &&
                        state.players.isEmpty &&
                        !hasActiveSearch) {
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
                        state.players.isEmpty &&
                        !hasActiveSearch) {
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
                                    style: TextUtils.setTextStyle(
                                        fontSize: 16.sp)),
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

                    final players =
                        hasActiveSearch ? state.searchResults : state.players;
                    final selectedIds = state.selectedPlayerIds.toSet();
                    final avatarCacheSize =
                        (62.w * MediaQuery.devicePixelRatioOf(context)).round();

                    if (hasActiveSearch && players.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 28.h),
                          child: Center(
                            child: Text(
                              'No players found',
                              style: TextUtils.setTextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    int itemCount = players.length;
                    if (!hasActiveSearch && state.isLoadingMore) itemCount += 1;
                    if (!hasActiveSearch &&
                        state.hasReachedMax &&
                        players.isNotEmpty) {
                      itemCount += 1;
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      sliver: SliverGrid(
                        gridDelegate: _playerGridDelegate(),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (!hasActiveSearch &&
                                state.isLoadingMore &&
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

                            if (!hasActiveSearch &&
                                state.hasReachedMax &&
                                index ==
                                    players.length +
                                        (state.isLoadingMore ? 1 : 0)) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: Text(
                                    'No more players',
                                    style: TextUtils.setTextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final player = players[index];
                            final isSelected = selectedIds.contains(player.id);

                            return ModernPlayerCard(
                              player: player,
                              isSelected: isSelected,
                              onTap: () => toggleSelection(player.id),
                              selectedLanguage: widget.selectedLanguage,
                              avatarCacheSize: avatarCacheSize,
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
              top: topInset + 12.h,
              left: 20.w,
              child: GestureDetector(
                onTap: _clearSearchAndPop,
                child: Padding(
                  padding: EdgeInsets.all(8.r),
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
                        buildWhen: (previous, current) =>
                            previous.selectedPlayerIds.length !=
                            current.selectedPlayerIds.length,
                        builder: (context, playerState) {
                          final hasSelection =
                              playerState.selectedPlayerIds.isNotEmpty;

                          return GestureDetector(
                            onTap: (hasSelection && !isSubmitting)
                                ? () {
                                    HapticFeedback.lightImpact();
                                    unawaited(
                                      globalAnalyticsService
                                          .logOnboardingStepAction(
                                        stepName: 'favourite_player_select',
                                        action: 'continue_clicked',
                                        playerCount: playerState
                                            .selectedPlayerIds.length,
                                      ),
                                    );
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
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(28.r),
                                    border: Border.all(
                                      color: Colorscontainer.greenColor
                                          .withValues(alpha: 0.4),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colorscontainer.greenColor
                                            .withValues(alpha: 0.2),
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
                if (state.status == SetPreferenceStatus.loading &&
                    !isSubmitting &&
                    mounted) {
                  setState(() => isSubmitting = true);
                } else if (state.status == SetPreferenceStatus.success) {
                  context.goNamed(RouteNames.home);
                } else if (state.status == SetPreferenceStatus.unauthorized &&
                    mounted) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session expired. Please sign in again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state.status == SetPreferenceStatus.failure &&
                    isSubmitting &&
                    mounted) {
                  setState(() => isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to save preferences. Please try again.'),
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
                color: Colors.black.withValues(alpha: 0.4),
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
  final int avatarCacheSize;

  const ModernPlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.selectedLanguage,
    required this.avatarCacheSize,
  });

  String _firstNonEmpty(List<String> values, {String fallback = ''}) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return fallback;
  }

  String get displayName {
    switch (selectedLanguage) {
      case 'am':
      case 'tr':
        return _firstNonEmpty(
          [
            player.amharicName,
            player.englishName,
            player.oromoName,
            player.somaliName,
          ],
          fallback: 'Unknown Player',
        );
      case 'or':
        return _firstNonEmpty(
          [
            player.oromoName,
            player.englishName,
            player.amharicName,
            player.somaliName,
          ],
          fallback: 'Unknown Player',
        );
      case 'so':
        return _firstNonEmpty(
          [
            player.somaliName,
            player.englishName,
            player.amharicName,
            player.oromoName,
          ],
          fallback: 'Unknown Player',
        );
      default:
        return _firstNonEmpty(
          [
            player.englishName,
            player.amharicName,
            player.oromoName,
            player.somaliName,
          ],
          fallback: 'Unknown Player',
        );
    }
  }

  String get teamName {
    switch (selectedLanguage) {
      case 'am':
      case 'tr':
        return _firstNonEmpty([
          player.team.amharicName,
          player.team.englishName,
          player.team.oromoName,
          player.team.somaliName,
        ]);
      case 'or':
        return _firstNonEmpty([
          player.team.oromoName,
          player.team.englishName,
          player.team.amharicName,
          player.team.somaliName,
        ]);
      case 'so':
        return _firstNonEmpty([
          player.team.somaliName,
          player.team.englishName,
          player.team.amharicName,
          player.team.oromoName,
        ]);
      default:
        return _firstNonEmpty([
          player.team.englishName,
          player.team.amharicName,
          player.team.oromoName,
          player.team.somaliName,
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? Colorscontainer.greenColor
                    : Colors.transparent,
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colorscontainer.greenColor.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: isDark ? 0.22 : 0.09),
                  blurRadius: isSelected ? 14 : 10,
                  offset: Offset(0, isSelected ? 6 : 4),
                ),
              ],
            ),
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
                                color: Colorscontainer.greenColor
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
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
                        memCacheWidth: avatarCacheSize,
                        memCacheHeight: avatarCacheSize,
                        filterQuality: FilterQuality.low,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/playershimmer.png',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                        placeholder: (context, url) => Container(
                          color: isDark ? Colors.white10 : Colors.grey[200],
                          child: Image.asset(
                            'assets/playershimmer.png',
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.6),
                            filterQuality: FilterQuality.low,
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
                        style: TextUtils.setTextStyle(
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
                          memCacheWidth: (13.w * 2).round(),
                          memCacheHeight: (13.w * 2).round(),
                          filterQuality: FilterQuality.low,
                          placeholder: (_, __) => SizedBox(
                            width: 13.w,
                            height: 13.w,
                          ),
                          errorWidget: (_, __, ___) => SizedBox(
                            width: 13.w,
                            height: 13.w,
                          ),
                        ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtils.setTextStyle(
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
