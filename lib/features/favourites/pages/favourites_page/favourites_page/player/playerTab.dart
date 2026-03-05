import 'dart:async';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';

import 'package:blogapp/state/application/favourite_player/PlayerSelection_bloc.dart';
import 'package:blogapp/state/application/favourite_player/PlayerSelection_event.dart';
import 'package:blogapp/state/application/favourite_player/PlayerSelection_state.dart';
import 'package:blogapp/state/application/following/following_bloc.dart';
import 'package:blogapp/state/application/following/following_event.dart';
import 'package:blogapp/state/application/following/following_state.dart';
import 'package:blogapp/domain/player/Players_for_selection_model.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'player_search_page.dart';

class PlayerTab extends StatefulWidget {
  const PlayerTab({super.key});

  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab>
    with AutomaticKeepAliveClientMixin {
  final Map<String, Color> _dominantColors = {};
  List<int> _lastRequestedFavIds = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    context.read<FollowingBloc>().add(LoadFollowedPlayers());
    context.read<PlayerSelectionBloc>().add(FetchPlayersRequested());
    context.read<PlayerSelectionBloc>().add(FetchPopularPlayersRequested());
  }

  String _getLocalizedPlayerName(PlayerSelectionModel player) {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' || 'tr' => player.amharicName,
      'so' => player.somaliName,
      'or' => player.oromoName,
      _ => player.englishName,
    };
  }

  String _getLocalizedTeamName(PlayerSelectionTeam team) {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' || 'tr' => team.amharicName,
      'so' => team.somaliName,
      'or' => team.oromoName,
      _ => team.englishName,
    };
  }

  String _resolveTeamLogo(PlayerSelectionTeam team) {
    final logo = team.logo;
    if (logo.isNotEmpty && logo.startsWith('http')) return logo;
    if (team.id > 0) {
      return 'https://media.api-sports.io/football/teams/${team.id}.png';
    }
    return '';
  }

  Future<Color> _getDominantColor(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Colors.blueGrey.shade700;
    }

    if (_dominantColors.containsKey(logoUrl)) {
      return _dominantColors[logoUrl]!;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(logoUrl),
        size: const Size(40, 40),
      );
      final color = palette.dominantColor?.color ?? Colors.blueGrey.shade700;
      _dominantColors[logoUrl] = color;
      return color;
    } catch (_) {
      return Colors.blueGrey.shade700;
    }
  }

  void _maybeLoadMore(
      PlayerSelectionState selectionState, int missingCount) {
    if (missingCount <= 0) return;
    if (selectionState.status != PlayerSelectionStatus.success) return;
    if (selectionState.isLoadingMore || selectionState.hasReachedMax) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PlayerSelectionBloc>().add(LoadMorePlayersRequested());
    });
  }

  void _maybeFetchFavouritePlayers(
    List<int> followedIds,
    List<int> missingIds,
  ) {
    final shouldDispatch =
        missingIds.isNotEmpty || !listEquals(followedIds, _lastRequestedFavIds);

    if (!shouldDispatch) return;

    _lastRequestedFavIds = List<int>.from(followedIds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<PlayerSelectionBloc>()
          .add(FetchPlayersByIdsRequested(ids: followedIds));
    });
  }

  void _openPlayerSearch() {
    showSearch(
      context: context,
      delegate: PlayerSearchDelegate(),
    ).then((_) {
      if (mounted) _refreshData();
    });
  }

  Widget _glass({required Widget child, Color? tint}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            scheme.surface.withOpacity(0.95),
            (tint ?? scheme.primary).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: BlocBuilder<FollowingBloc, FollowingState>(
        builder: (context, followingState) {
          final followedIds = followingState.followedPlayers;
          final normalizedIds = LinkedHashSet<int>.from(followedIds).toList();
          final followedIdSet = normalizedIds.toSet();

          return BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
            builder: (context, selectionState) {
              final cache = <int, PlayerSelectionModel>{};
              for (final p in selectionState.players) {
                cache[p.id] = p;
              }
              for (final p in selectionState.popularPlayers) {
                cache[p.id] = p;
              }
              for (final p in selectionState.favouritePlayers) {
                cache[p.id] = p;
              }
              for (final p in selectionState.searchResults) {
                cache[p.id] = p;
              }

              final missingIds = <int>[];
              for (final id in normalizedIds) {
                if (!cache.containsKey(id)) missingIds.add(id);
              }

              _maybeLoadMore(selectionState, missingIds.length);
              _maybeFetchFavouritePlayers(normalizedIds, missingIds);

              if (normalizedIds.isEmpty) {
                if (selectionState.status == PlayerSelectionStatus.loading) {
                  return _buildLoadingState();
                }
                return _buildEmptyState(followedIdSet);
              }

              final hasAnyResolved = missingIds.length < normalizedIds.length;

              if (selectionState.status == PlayerSelectionStatus.failure &&
                  !hasAnyResolved) {
                return _buildErrorState();
              }

              if (!hasAnyResolved &&
                  selectionState.hasReachedMax &&
                  !selectionState.isLoadingMore) {
                return _buildErrorState();
              }

              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width >= 900
                            ? 5
                            : width >= 700
                                ? 4
                                : width >= 520
                                    ? 3
                                    : 2;
                        final cardExtent = width >= 700 ? 150.h : 118.h;

                        return GridView.builder(
                          key: const PageStorageKey('players_grid'),
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                          itemCount: normalizedIds.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 8.h,
                            crossAxisSpacing: 8.w,
                            mainAxisExtent: cardExtent,
                          ),
                          itemBuilder: (context, index) {
                            final id = normalizedIds[index];
                            final p = cache[id];
                            return KeyedSubtree(
                              key: ValueKey('player_$id'),
                              child: p == null
                                  ? _buildPlayerPlaceholderCard()
                                  : _buildPlayerCard(p),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(PlayerSelectionModel player) {
    final teamLogo = _resolveTeamLogo(player.team);
    final localizedTeam = _getLocalizedTeamName(player.team).trim().isNotEmpty
        ? _getLocalizedTeamName(player.team)
        : player.team.englishName;

    return FutureBuilder<Color>(
      future: _getDominantColor(teamLogo),
      builder: (context, snapshot) {
        final dominant = snapshot.data ?? Colors.blueGrey;

        return InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () async {
            final result = await context.pushNamed<bool>(
              RouteNames.playerProfile,
              extra: player,
              queryParameters: {
                'id': player.id.toString(),
                'favourite': 'true',
                'apiPhoto': player.photo,
                'teamPic': teamLogo,
                'teamId': player.team.id.toString(),
              },
            );
            if (result == true && mounted) await _refreshData();
          },
          child: _glass(
            tint: dominant,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarImage(player.photo, player.id),
                  SizedBox(height: 6.h),
                  Text(
                    _getLocalizedPlayerName(player),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (teamLogo.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: teamLogo,
                          width: 14.r,
                          height: 14.r,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.shield,
                            size: 12.sp,
                          ),
                        )
                      else
                        Icon(Icons.shield, size: 12.sp),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          localizedTeam,
                          style: TextUtils.setTextStyle(
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerPlaceholderCard() {
    final scheme = Theme.of(context).colorScheme;
    final fill = scheme.surfaceContainerHighest.withOpacity(0.6);

    return _glass(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: 70.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 52.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: fill.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openPlayerSearch,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
        child: _glass(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 18.sp),
                SizedBox(width: 10.w),
                Text(
                  DemoLocalizations.searchByName,
                  style: TextUtils.setTextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Set<int> followedIds) {
    return BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
      builder: (context, selectionState) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmptyHeader(),
              SmoothAutoScrollingAvatarList(
                  players: selectionState.popularPlayers),
              _buildSearchBar(),
              _buildRecommendationList(
                  selectionState.popularPlayers, followedIds),
              SizedBox(height: 120.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DemoLocalizations.choose_your_fav_player,
            style: TextUtils.setTextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            DemoLocalizations.no_favorite_player,
            style: TextUtils.setTextStyle(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalAvatars(List<PlayerSelectionModel> players) {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: players.isEmpty ? 5 : players.length,
        itemBuilder: (context, index) {
          if (players.isEmpty) return _buildPlaceholderCircle();
          final p = players[index];
          return Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor:
                  Colors.white24, // optional border/placeholder color
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: p.photo,
                  width: 72.r, // diameter = radius * 2
                  height: 72.r,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 36.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationList(
      List<PlayerSelectionModel> players, Set<int> followedIds) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DemoLocalizations.popular,
            style: TextUtils.setTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: players.length > 6 ? 6 : players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return RecommendedPlayerTile(
                key: ValueKey('rec_${player.id}'),
                player: player,
                followedIds: followedIds,
                getLocalizedPlayerName: _getLocalizedPlayerName,
                getLocalizedTeamName: _getLocalizedTeamName,
                getTeamLogoUrl: _resolveTeamLogo,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String url, int id) {
    final size = 52.w;
    final borderColor =
        Theme.of(context).colorScheme.outline.withOpacity(0.2);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (c, u, e) => Image.asset('assets/playershimmer.png'),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCircle() => Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 15.w),
        decoration:
            const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      );

  Widget _buildLoadingState() =>
      Center(child: Image.asset('assets/mirchawoche.gif', width: 90.w));

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 42.sp,
            ),
            SizedBox(height: 16.h),
            TextButton(onPressed: _refreshData, child: const Text("Retry")),
          ],
        ),
      );
}

class SmoothAutoScrollingAvatarList extends StatefulWidget {
  final List<PlayerSelectionModel> players;
  final double scrollSpeed; // pixels per second

  const SmoothAutoScrollingAvatarList({
    super.key,
    required this.players,
    this.scrollSpeed = 30, // adjust speed as needed
  });

  @override
  State<SmoothAutoScrollingAvatarList> createState() =>
      _SmoothAutoScrollingAvatarListState();
}

class _SmoothAutoScrollingAvatarListState
    extends State<SmoothAutoScrollingAvatarList> {
  late ScrollController _scrollController;
  late double _maxScrollExtent;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!mounted || widget.players.isEmpty) return;

    // Duplicate the list virtually by scrolling continuously
    _maxScrollExtent = _scrollController.position.maxScrollExtent;

    while (mounted) {
      final currentOffset = _scrollController.offset;
      final distance = _maxScrollExtent - currentOffset;

      // Duration based on scrollSpeed
      final duration = Duration(
          milliseconds: (distance / widget.scrollSpeed * 1000).toInt());

      await _scrollController.animateTo(
        _maxScrollExtent,
        duration: duration,
        curve: Curves.linear,
      );

      // Reset to start without animation to prevent glitch
      if (!mounted) return;
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list =
        widget.players.isEmpty ? List.generate(5, (_) => null) : widget.players;

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: list.length * 2, // duplicate for seamless loop
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemBuilder: (context, index) {
          final p = list[index % list.length];
          if (p == null) return _buildPlaceholderCircle();

          return Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor: Colors.white24,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: p.photo,
                  width: 72.r,
                  height: 72.r,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, size: 36.r, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderCircle() => Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 15.w),
        decoration:
            const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      );
}

// ======================= RECOMMENDED PLAYER TILE (CRASH-PROOF) =======================

class RecommendedPlayerTile extends StatefulWidget {
  final PlayerSelectionModel player;
  final Set<int> followedIds;
  final String Function(PlayerSelectionModel) getLocalizedPlayerName;
  final String Function(PlayerSelectionTeam) getLocalizedTeamName;
  final String Function(PlayerSelectionTeam) getTeamLogoUrl;

  const RecommendedPlayerTile({
    super.key,
    required this.player,
    required this.followedIds,
    required this.getLocalizedPlayerName,
    required this.getLocalizedTeamName,
    required this.getTeamLogoUrl,
  });

  @override
  State<RecommendedPlayerTile> createState() => _RecommendedPlayerTileState();
}

class _RecommendedPlayerTileState extends State<RecommendedPlayerTile> {
  StreamSubscription? _followingSubscription;

  bool? _optimisticIsFav;
  bool _isProcessing = false;

  @override
  void dispose() {
    _followingSubscription?.cancel();
    super.dispose();
  }

  void _handleFollowToggle() {
    final backendIsFav = widget.followedIds.contains(widget.player.id);
    final currentDisplay = _optimisticIsFav ?? backendIsFav;
    final target = !currentDisplay;

    if (!mounted) return;
    setState(() {
      _isProcessing = true;
      _optimisticIsFav = target;
    });

    context.read<FollowingBloc>().add(ToggleFollowPlayer(
          playerId: widget.player.id,
          playerName: widget.player.englishName.isNotEmpty
              ? widget.player.englishName
              : widget.getLocalizedPlayerName(widget.player),
        ));

    _followingSubscription?.cancel();
    _followingSubscription =
        context.read<FollowingBloc>().stream.listen((state) {
      if (!mounted) return;

      if (state.status == Status.following ||
          state.status == Status.notFollowing ||
          state.status == Status.error ||
          state.status == Status.networkError ||
          state.status == Status.serverError ||
          state.status == Status.unknownError) {
        final serverHasIt = state.followedPlayers.contains(widget.player.id);

        if (serverHasIt == target ||
            state.status == Status.error ||
            state.status == Status.networkError ||
            state.status == Status.serverError ||
            state.status == Status.unknownError) {
          if (!mounted) return;
          setState(() {
            _optimisticIsFav = null;
            _isProcessing = false;
          });
          _followingSubscription?.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backendIsFav = widget.followedIds.contains(widget.player.id);
    final isFav = _optimisticIsFav ?? backendIsFav;
    final scheme = Theme.of(context).colorScheme;
    final teamLogo = widget.getTeamLogoUrl(widget.player.team);
    final teamName = widget.getLocalizedTeamName(widget.player.team).trim().isNotEmpty
        ? widget.getLocalizedTeamName(widget.player.team)
        : widget.player.team.englishName;
    final photoUrl = widget.player.photo.isNotEmpty
        ? widget.player.photo
        : 'https://media.api-sports.io/football/players/${widget.player.id}.png';

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: scheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                width: 40.r,
                height: 40.r,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Icon(
                  Icons.person,
                  size: 24.sp,
                  color: scheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.getLocalizedPlayerName(widget.player),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextUtils.setTextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (teamLogo.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: teamLogo,
                          width: 14.r,
                          height: 14.r,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.shield,
                            size: 12.sp,
                          ),
                        )
                      else
                        Icon(
                          Icons.shield,
                          size: 12.sp,
                        ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          teamName,
                          style: TextUtils.setTextStyle(
                            fontSize: 10.sp,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            SizedBox(
              width: 34.w,
              height: 34.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: _isProcessing ? null : _handleFollowToggle,
                    borderRadius: BorderRadius.circular(12.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: isFav
                            ? Colors.amber
                            : scheme.surfaceContainerHighest.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isFav
                              ? Colors.amber
                              : scheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 16.sp,
                        color: isFav
                            ? Colors.white
                            : scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

