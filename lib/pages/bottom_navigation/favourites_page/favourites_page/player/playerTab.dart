import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../../../../../../components/routenames.dart';
import '../../../../../../../../localization/demo_localization.dart';
import '../../../../../../../../main.dart';

import '../../../../../application/favourite_player/PlayerSelection_bloc.dart';
import '../../../../../application/favourite_player/PlayerSelection_event.dart';
import '../../../../../application/favourite_player/PlayerSelection_state.dart';
import '../../../../../application/following/following_bloc.dart';
import '../../../../../application/following/following_event.dart';
import '../../../../../application/following/following_state.dart';
import '../../../../../domain/player/Players_for_selection_model.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/text_utils.dart';
import 'player_search_page.dart';

class PlayerTab extends StatefulWidget {
  const PlayerTab({super.key});

  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab>
    with AutomaticKeepAliveClientMixin {
  final Map<String, Color> _dominantColors = {};

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
      _ => team.englishName,
    };
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

  void _openPlayerSearch() {
    showSearch(
      context: context,
      delegate: PlayerSearchDelegate(),
    ).then((_) {
      if (mounted) _refreshData();
    });
  }

  Widget _glass({required Widget child, Color? tint}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (tint ?? Colors.white).withOpacity(0.25),
                Colors.black.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: BlocBuilder<FollowingBloc, FollowingState>(
          builder: (context, followingState) {
            final followedIds = followingState.followedPlayers;
            final followedIdSet = followedIds.toSet();

            return BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
              builder: (context, selectionState) {
                final cache = <int, PlayerSelectionModel>{};
                for (final p in selectionState.players) {
                  cache[p.id] = p;
                }
                for (final p in selectionState.popularPlayers) {
                  cache[p.id] = p;
                }
                for (final p in selectionState.searchResults) {
                  cache[p.id] = p;
                }

                final favPlayers = <PlayerSelectionModel>[];
                for (final id in followedIds) {
                  final p = cache[id];
                  if (p != null) favPlayers.add(p);
                }

                final missingCount = followedIds.length - favPlayers.length;
                _maybeLoadMore(selectionState, missingCount);

                if (followedIds.isEmpty) {
                  return _buildEmptyState(followedIdSet);
                }

                if (selectionState.status == PlayerSelectionStatus.loading &&
                    favPlayers.isEmpty) {
                  return _buildLoadingState();
                }

                if (selectionState.status == PlayerSelectionStatus.failure &&
                    favPlayers.isEmpty) {
                  return _buildErrorState();
                }

                if (favPlayers.isEmpty &&
                    selectionState.hasReachedMax &&
                    !selectionState.isLoadingMore) {
                  return _buildErrorState();
                }

                if (favPlayers.isEmpty) {
                  return _buildLoadingState();
                }

                return Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 120.h),
                        itemCount: favPlayers.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.90,
                        ),
                        itemBuilder: (context, index) =>
                            _buildPlayerCard(favPlayers[index]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerSelectionModel player) {
    return FutureBuilder<Color>(
      future: _getDominantColor(player.team.logo),
      builder: (context, snapshot) {
        final dominant = snapshot.data ?? Colors.blueGrey;

        return GestureDetector(
          onTap: () async {
            final result = await context.pushNamed<bool>(
              RouteNames.playerProfile,
              extra: player,
              queryParameters: {
                'id': player.id.toString(),
                'favourite': 'true',
                'apiPhoto': player.photo,
                'teamPic': player.team.logo ?? '',
                'teamId': player.team.id?.toString() ?? '',
              },
            );
            if (result == true && mounted) await _refreshData();
          },
          child: _glass(
            tint: dominant,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarImage(player.photo, player.id),
                  SizedBox(height: 12.h),
                  // Player Name
                  Text(
                    _getLocalizedPlayerName(player),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Team Logo + Team Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (player.team.logo != null &&
                          player.team.logo!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: player.team.logo!,
                          width: 18.r,
                          height: 18.r,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.shield,
                            size: 16.sp,
                          ),
                        )
                      else
                        Icon(Icons.shield, size: 16.sp),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          _getLocalizedTeamName(player.team),
                          style: TextUtils.setTextStyle(
                            fontSize: 12.sp,
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

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openPlayerSearch,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
        child: _glass(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 22.sp),
                SizedBox(width: 12.w),
                Text(
                  DemoLocalizations.searchByName,
                  style: TextUtils.setTextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w500),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String url, int id) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 76.w,
          height: 76.w,
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

  const RecommendedPlayerTile({
    super.key,
    required this.player,
    required this.followedIds,
    required this.getLocalizedPlayerName,
    required this.getLocalizedTeamName,
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

    // Immediate optimistic update (safe because widget is still mounted here)
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
      _optimisticIsFav = target;
    });

    context
        .read<FollowingBloc>()
        .add(ToggleFollowPlayer(
          playerId: widget.player.id,
          playerName: widget.player.englishName.isNotEmpty
              ? widget.player.englishName
              : widget.getLocalizedPlayerName(widget.player),
        ));

    // Cancel any previous subscription
    _followingSubscription?.cancel();
    _followingSubscription =
        context.read<FollowingBloc>().stream.listen((state) {
      // Critical: Check mounted before doing anything
      if (!mounted) return;

      if (state.status == Status.following ||
          state.status == Status.notFollowing ||
          state.status == Status.error ||
          state.status == Status.networkError ||
          state.status == Status.serverError ||
          state.status == Status.unknownError) {
        final serverHasIt =
            state.followedPlayers.contains(widget.player.id);

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

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(widget.player.photo),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Name
            Text(
              widget.getLocalizedPlayerName(widget.player),
              style: TextUtils.setTextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            // Team Logo + Team Name
            Row(
              children: [
                if (widget.player.team.logo != null &&
                    widget.player.team.logo!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: widget.player.team.logo!,
                    width: 16.r,
                    height: 16.r,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.shield, size: 14.sp),
                  )
                else
                  Icon(
                    Icons.shield,
                    size: 14.sp,
                  ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    widget.getLocalizedTeamName(widget.player.team),
                    style: TextUtils.setTextStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 42.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _isProcessing ? null : _handleFollowToggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    key: ValueKey('rec_${widget.player.id}_$isFav'),
                    color: isFav ? Colors.amber : Colorscontainer.greenColor,
                    size: 28.sp,
                  ),
                ),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
