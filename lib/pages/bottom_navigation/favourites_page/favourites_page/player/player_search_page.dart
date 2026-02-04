import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../application/favourite_player/PlayerSelection_bloc.dart';
import '../../../../../application/favourite_player/PlayerSelection_event.dart';
import '../../../../../application/favourite_player/PlayerSelection_state.dart';
import '../../../../../application/following/following_bloc.dart';
import '../../../../../application/following/following_event.dart';
import '../../../../../application/following/following_state.dart';
import '../../../../../domain/player/Players_for_selection_model.dart';
import '../../../../../../../../main.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../constants/text_utils.dart';

class PlayerSearchDelegate extends SearchDelegate<String> {
  Timer? _debounce;

  @override
  String get searchFieldLabel => DemoLocalizations.searchByName;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        titleTextStyle: TextUtils.setTextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextUtils.setTextStyle(
          color: Colors.grey.shade500,
          fontSize: 15.sp,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        opacity: query.isEmpty ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        child: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final bool isQueryEmpty = query.trim().isEmpty;

    if (!isQueryEmpty) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        context.read<PlayerSelectionBloc>().add(
              SearchPlayerByNameRequested(playerName: query.trim()),
            );
      });
    }

    context.read<FollowingBloc>().add(LoadFollowedPlayers());

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<PlayerSelectionBloc>()),
        BlocProvider.value(value: context.read<FollowingBloc>()),
      ],
      child: BlocBuilder<PlayerSelectionBloc, PlayerSelectionState>(
        builder: (context, state) {
          final list =
              isQueryEmpty ? state.popularPlayers : state.searchResults;

          if (state.status == PlayerSelectionStatus.loading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: list.length,
            itemBuilder: (context, index) => _PlayerTile(player: list[index]),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class _PlayerTile extends StatefulWidget {
  final PlayerSelectionModel player;
  const _PlayerTile({required this.player});

  @override
  State<_PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<_PlayerTile> {
  StreamSubscription? _followingSubscription;
  bool? _optimisticFav;
  bool _isProcessing = false;

  @override
  void dispose() {
    _followingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followingState = context.watch<FollowingBloc>().state;
    final bool isFavFromLocal =
        followingState.followedPlayers.contains(widget.player.id);

    final bool currentFav = _optimisticFav ?? isFavFromLocal;

    final pName = _localizedName();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.grey.shade900.withOpacity(0.65),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              _PlayerAvatar(widget.player),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Player name
                    Text(
                      pName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtils.setTextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Team logo + team name
                    Row(
                      children: [
                        if (widget.player.team.logo.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: widget.player.team.logo,
                            width: 18.r,
                            height: 18.r,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => Icon(Icons.shield,
                                size: 14.sp, color: Colors.grey),
                          ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            localLanguageNotifier.value == 'am'
                                ? widget.player.team.amharicName
                                : widget.player.team.englishName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _FavouriteButton(
                isFav: currentFav,
                isProcessing: _isProcessing,
                onTap: () => _handleToggle(context, currentFav),
                id: widget.player.id,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleToggle(BuildContext context, bool currentStatus) {
    final followingBloc = context.read<FollowingBloc>();
    final bool targetStatus = !currentStatus;

    setState(() {
      _isProcessing = true;
      _optimisticFav = targetStatus;
    });

    followingBloc.add(ToggleFollowPlayer(
      playerId: widget.player.id,
      playerName: _englishName(),
    ));

    _followingSubscription?.cancel();
    _followingSubscription = followingBloc.stream.listen((state) {
      if (state.status == Status.following ||
          state.status == Status.notFollowing ||
          state.status == Status.error ||
          state.status == Status.networkError ||
          state.status == Status.serverError ||
          state.status == Status.unknownError) {
        final bool hasPlayer =
            state.followedPlayers.contains(widget.player.id);

        if (hasPlayer == targetStatus ||
            state.status == Status.error ||
            state.status == Status.networkError ||
            state.status == Status.serverError ||
            state.status == Status.unknownError) {
          if (!mounted) return;
          setState(() {
            _optimisticFav = null;
            _isProcessing = false;
          });
          _followingSubscription?.cancel();
        }
      }
    });
  }

  String _localizedName() {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' => widget.player.amharicName,
      'tr' => widget.player.amharicName,
      'om' => widget.player.oromoName,
      'so' => widget.player.somaliName,
      _ => widget.player.englishName,
    };
  }

  String _englishName() {
    return widget.player.englishName.isNotEmpty
        ? widget.player.englishName
        : _localizedName();
  }
}

class _PlayerAvatar extends StatelessWidget {
  final PlayerSelectionModel player;
  const _PlayerAvatar(this.player);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.r,
      height: 54.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade900],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: player.photo.isNotEmpty
            ? player.photo
            : 'https://media.api-sports.io/football/players/${player.id}.png',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade800),
        errorWidget: (_, __, ___) =>
            Icon(Icons.person, color: Colors.grey.shade500),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  final bool isFav;
  final bool isProcessing;
  final VoidCallback onTap;
  final int id;

  const _FavouriteButton({
    required this.isFav,
    required this.isProcessing,
    required this.onTap,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isProcessing ? null : onTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          isFav ? Icons.star_rounded : Icons.star_border_rounded,
          key: ValueKey('fav_$id$isFav'),
          size: 28.sp,
          color: isFav ? Colors.amber : Colors.grey.shade500,
        ),
      ),
    );
  }
}
