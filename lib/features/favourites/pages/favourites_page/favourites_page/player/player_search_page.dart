import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:blogapp/state/application/favourite_player/PlayerSelection_bloc.dart';
import 'package:blogapp/state/application/favourite_player/PlayerSelection_event.dart';
import 'package:blogapp/state/application/favourite_player/PlayerSelection_state.dart';
import 'package:blogapp/state/application/following/following_bloc.dart';
import 'package:blogapp/state/application/following/following_event.dart';
import 'package:blogapp/state/application/following/following_state.dart';
import 'package:blogapp/state/application/following/following_state.dart';
import 'package:blogapp/domain/player/Players_for_selection_model.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

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
    final scheme = Theme.of(context).colorScheme;

    final pName = _localizedName();
    final teamName = _localizedTeamName().trim().isNotEmpty
        ? _localizedTeamName()
        : widget.player.team.englishName;
    final teamLogo = _resolveTeamLogo();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: scheme.surface,
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              _PlayerAvatar(widget.player),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtils.setTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (teamLogo.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: teamLogo,
                            width: 16.r,
                            height: 16.r,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.shield,
                              size: 14.sp,
                              color: scheme.onSurface.withOpacity(0.5),
                            ),
                          )
                        else
                          Icon(
                            Icons.shield,
                            size: 14.sp,
                            color: scheme.onSurface.withOpacity(0.5),
                          ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            teamName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtils.setTextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: scheme.onSurface.withOpacity(0.6),
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
      'or' => widget.player.oromoName,
      'so' => widget.player.somaliName,
      _ => widget.player.englishName,
    };
  }

  String _englishName() {
    return widget.player.englishName.isNotEmpty
        ? widget.player.englishName
        : _localizedName();
  }

  String _localizedTeamName() {
    final lang = localLanguageNotifier.value;
    return switch (lang) {
      'am' || 'tr' => widget.player.team.amharicName,
      'or' => widget.player.team.oromoName,
      'so' => widget.player.team.somaliName,
      _ => widget.player.team.englishName,
    };
  }

  String _resolveTeamLogo() {
    final logo = widget.player.team.logo;
    if (logo.isNotEmpty && logo.startsWith('http')) return logo;
    if (widget.player.team.id > 0) {
      return 'https://media.api-sports.io/football/teams/${widget.player.team.id}.png';
    }
    return '';
  }
}

class _PlayerAvatar extends StatelessWidget {
  final PlayerSelectionModel player;
  const _PlayerAvatar(this.player);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photoUrl = player.photo.isNotEmpty
        ? player.photo
        : 'https://media.api-sports.io/football/players/${player.id}.png';

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest.withOpacity(0.7),
        border: Border.all(color: scheme.outline.withOpacity(0.2), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(color: scheme.surfaceContainerHighest),
        errorWidget: (_, __, ___) =>
            Icon(Icons.person, color: scheme.onSurface.withOpacity(0.5)),
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
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: isProcessing ? null : onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: isFav
                    ? Colorscontainer.greenColor
                    : scheme.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      isFav ? Colorscontainer.greenColor : scheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                key: ValueKey('fav_$id$isFav'),
                size: 18.sp,
                color: isFav
                    ? Colors.white
                    : scheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          if (isProcessing)
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
