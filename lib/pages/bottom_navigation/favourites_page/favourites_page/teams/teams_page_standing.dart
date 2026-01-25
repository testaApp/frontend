import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../bloc/mirchaweche/my_fav/my_fav_player/myfavourite_players_bloc.dart';
import '../../../../../bloc/mirchaweche/my_fav/my_fav_player/myfavourite_players_event.dart';
import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_event.dart';
import '../../../../../bloc/mirchaweche/players/player_teammates/teammates_state.dart';
import '../../../../../bloc/mirchaweche/teams/previous&next_matchs/match_page_state.dart';
import '../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_bloc.dart';
import '../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_page_event.dart';
import '../../../../../bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_bloc.dart';
import '../../../../../bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_state.dart';
import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_bloc.dart';
import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_event.dart';
import '../../../../../bloc/mirchaweche/teams/last_five_matches/last_five_matches_state.dart';
import '../../../../../components/getAmharicDay.dart';
import '../../../../../components/timeFormatter.dart';
import '../../../../../domain/player/team_leaders_model.dart';
import '../../../../../localization/demo_localization.dart';
import '../../../../../main.dart';
import '../../../../../models/fixtures/last_5_matches_model.dart';
import '../../../../../models/leagueNames.dart';
import '../../../../../widgets/standing_table_teams_list.dart';
import '../../../../constants/text_utils.dart';
import '../../../standing/leagues_page/Standing/rank_name_others_line.dart';

class TeamsStandingPage extends StatefulWidget {
  final String? teamId;
  final String? teamLogo;
  final String? venuename;
  final String? venuecity;
  final String? venuecapacity;
  final String? venueimage;
  final String? venueaddress;
  final String? founded;
  final String? venuesurface;

  const TeamsStandingPage({
    super.key,
    required this.teamId,
    this.teamLogo,
    this.venuename,
    this.venuecity,
    this.venuecapacity,
    this.venueimage,
    this.venueaddress,
    this.founded,
    this.venuesurface,
  });

  @override
  State<TeamsStandingPage> createState() => _TeamsStandingPageState();
}

class _TeamsStandingPageState extends State<TeamsStandingPage> {
  @override
  @override
  void initState() {
    super.initState();
    if (widget.teamId != null) {
      // Safety check for parsing
      final int? id = int.tryParse(widget.teamId!);
      if (id != null) {
        context.read<TeammatesBloc>().add(TeamLeadersRequested(teamId: id));
      }

      context
          .read<MatchesPageBloc>()
          .add(TeamNextMatchesRequested(widget.teamId!));
      context
          .read<MyfavouritePlayersBloc>()
          .add(PlayersRequested(teamId: widget.teamId));
      context
          .read<LastFiveMatchesBloc>()
          .add(LastFiveMatchesRequested(teamId: widget.teamId!));
    }
  }

  Widget _buildTopPlayerCard(
    BuildContext context,
    String title,
    List<TeamLeader> leaders,
    String statType, // 'goals', 'assists', 'yellow', 'red'
  ) {
    if (leaders.isEmpty) return const SizedBox.shrink();

    // DEBUG: Print player info

    final topPlayer = leaders[0]; // Explicitly use index 0
    final deviceLanguage = localLanguageNotifier.value;

    // Get localized player name
    String getLocalizedPlayerName(TeamLeader leader) {
      switch (deviceLanguage) {
        case 'am':
        case 'tr':
          return leader.player.amharicName.isNotEmpty
              ? leader.player.amharicName
              : leader.player.englishName;
        case 'so':
          return leader.player.somaliName.isNotEmpty
              ? leader.player.somaliName
              : leader.player.englishName;
        case 'or':
          return leader.player.oromoName.isNotEmpty
              ? leader.player.oromoName
              : leader.player.englishName;
        default:
          return leader.player.englishName;
      }
    }

    // Get stat value based on stat type
    int getStatValue(TeamLeader leader) {
      switch (statType) {
        case 'goals':
          return leader.totalGoals;
        case 'assists':
          return leader.assists;
        case 'yellow':
          return leader.yellowCards;
        case 'red':
          return leader.redCards ?? 0; // Use redCards field
        default:
          return 0;
      }
    }

    // Get stat color
    Color getStatColor() {
      switch (statType) {
        case 'goals':
        case 'assists':
          return Theme.of(context).primaryColor;
        case 'yellow':
          return Colors.amber[700]!;
        case 'red':
          return Colors.red[700]!;
        default:
          return Theme.of(context).primaryColor;
      }
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // Top Player
          Row(
            children: [
              // Player Image - smaller
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: topPlayer.player.photo ?? '',
                  height: 55.h,
                  width: 45.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: 20.sp, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: 20.sp, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLocalizedPlayerName(topPlayer),
                      style: TextUtils.setTextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${getStatValue(topPlayer)}',
                      style: TextUtils.setTextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: getStatColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Second and Third Players (if available)
          if (leaders.length > 1) ...[
            SizedBox(height: 8.h),
            Divider(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              height: 1,
            ),
            SizedBox(height: 8.h),

            // Show 2nd and 3rd place players - explicitly iterate from index 1
            ...List.generate(
              leaders.length > 3
                  ? 2
                  : leaders.length - 1, // Show max 2 additional players
              (index) {
                final leader =
                    leaders[index + 1]; // Start from index 1 (second player)

                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: leader.player.photo != null &&
                                leader.player.photo!.isNotEmpty
                            ? CachedNetworkImageProvider(leader.player.photo!)
                            : null,
                        child: leader.player.photo == null ||
                                leader.player.photo!.isEmpty
                            ? Icon(Icons.person,
                                size: 14.sp, color: Colors.grey)
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          getLocalizedPlayerName(leader),
                          style: TextUtils.setTextStyle(fontSize: 11.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${getStatValue(leader)}',
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: getStatColor(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

// Replace the build method in TeamsStandingPage with this:

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamProfileStandingBloc, TeamProfileStandingState>(
      builder: (context, state) {
        if (state.status == teamProfileStandingStatus.initial ||
            state.status == teamProfileStandingStatus.requested) {
          return _buildShimmerLoading();
        }

        if (state.status == teamProfileStandingStatus.success) {
          final standings = state.standings;
          final nameWidth = MediaQuery.of(context).size.width / 2.4;

          // 🔥 KEY FIX: Use CustomScrollView with Slivers instead of SingleChildScrollView
          return CustomScrollView(
            // 🔥 Remove physics - let NestedScrollView handle it
            slivers: [
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Recent / Next Match
                    BlocBuilder<MatchesPageBloc, MatchPageState>(
                      buildWhen: (previous, current) {
                        return previous.nextMatches != current.nextMatches ||
                            (previous.nextMatchesStatus !=
                                    current.nextMatchesStatus &&
                                current.nextMatchesStatus ==
                                    matchpageStatus.requestSuccess);
                      },
                      builder: (context, matchState) {
                        if (matchState.nextMatches.isNotEmpty) {
                          final allMatches = matchState.nextMatches;
                          final now = DateTime.now();

                          final futureMatches = allMatches.where((match) {
                            try {
                              final matchDate =
                                  DateTime.parse(match.date).toLocal();
                              return matchDate.isAfter(now);
                            } catch (e) {
                              return false;
                            }
                          }).toList();

                          futureMatches.sort((a, b) {
                            final dateA = DateTime.parse(a.date).toLocal();
                            final dateB = DateTime.parse(b.date).toLocal();
                            return dateA.compareTo(dateB);
                          });

                          if (futureMatches.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final match = futureMatches.first;
                          final date = getAmharicSubstDate(
                              DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(match.date).toLocal()));
                          final time = formatMatchTime(match.date);

                          final deviceLanguage = localLanguageNotifier.value;
                          final teamhome = _getLocalizedTeamName(
                              match, true, deviceLanguage);
                          final teamaway = _getLocalizedTeamName(
                              match, false, deviceLanguage);

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, bottom: 8.0),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    DemoLocalizations.next_matchs,
                                    style: TextUtils.setTextStyle(
                                      fontSize: 14.2.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      engFont: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildTeamColumn(
                                          match.hometeamlogo,
                                          teamhome,
                                          match.hometeamId,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 28.0),
                                        child: Column(
                                          children: [
                                            Text(date,
                                                style: TextUtils.setTextStyle(
                                                    fontSize: 13.sp)),
                                            Text(time,
                                                style: TextUtils.setTextStyle(
                                                    fontSize: 13.sp)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildTeamColumn(
                                          match.awayteamlogo,
                                          teamaway,
                                          match.awayteamId,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (matchState.nextMatchesStatus ==
                                matchpageStatus.requested &&
                            matchState.nextMatches.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    // Last 5 Matches
                    BlocBuilder<LastFiveMatchesBloc, LastFiveMatchesState>(
                      builder: (context, lastFiveState) {
                        if (lastFiveState.status !=
                            fiveMatchesStatus.requestSuccess) {
                          return const SizedBox.shrink();
                        }

                        final List<LastFiveMatchesByLeague> matchesByLeague =
                            lastFiveState.matchesByLeague;

                        if (matchesByLeague.isEmpty)
                          return const SizedBox.shrink();

                        final filteredLeagues = matchesByLeague
                            .where((league) => league.matches.isNotEmpty)
                            .toList();

                        if (filteredLeagues.isEmpty)
                          return const SizedBox.shrink();

                        return Column(
                          children: filteredLeagues.map((leagueMatches) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 8),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: CachedNetworkImage(
                                              height: 18.h,
                                              width: 18.w,
                                              imageUrl:
                                                  'https://media.api-sports.io/football/leagues/${leagueMatches.leagueId}.png',
                                              placeholder: (_, __) => SizedBox(
                                                  width: 18.w, height: 18.h),
                                              errorWidget: (_, __, ___) => Icon(
                                                  Icons.emoji_events,
                                                  size: 16.sp,
                                                  color: Colors.grey[400]),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              DemoLocalizations.last5Games,
                                              style: TextUtils.setTextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 90.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: leagueMatches.matches.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 8.w),
                                        itemBuilder: (context, index) {
                                          final match =
                                              leagueMatches.matches[index];
                                          final String myTeamId =
                                              widget.teamId ?? '';
                                          final bool isHome =
                                              match.homeTeamId == myTeamId;

                                          final int scored = isHome
                                              ? (match.scoreHome ?? 0)
                                              : (match.scoreAway ?? 0);
                                          final int conceded = isHome
                                              ? (match.scoreAway ?? 0)
                                              : (match.scoreHome ?? 0);

                                          final String myTeamLogo = isHome
                                              ? (match.homeTeamLogo.isNotEmpty
                                                  ? match.homeTeamLogo
                                                  : 'https://media.api-sports.io/football/teams/$myTeamId.png')
                                              : (match.awayTeamLogo.isNotEmpty
                                                  ? match.awayTeamLogo
                                                  : 'https://media.api-sports.io/football/teams/$myTeamId.png');

                                          final String opponentId = isHome
                                              ? match.awayTeamId
                                              : match.homeTeamId;

                                          final String opponentLogo = isHome
                                              ? (match.awayTeamLogo.isNotEmpty
                                                  ? match.awayTeamLogo
                                                  : 'https://media.api-sports.io/football/teams/$opponentId.png')
                                              : (match.homeTeamLogo.isNotEmpty
                                                  ? match.homeTeamLogo
                                                  : 'https://media.api-sports.io/football/teams/$opponentId.png');

                                          return _buildFormItem(
                                            context,
                                            scored,
                                            conceded,
                                            myTeamLogo,
                                            opponentLogo,
                                            isHome,
                                            myTeamId,
                                            opponentId,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // Team Leaders
                    BlocBuilder<TeammatesBloc, TeammatesState>(
                      builder: (context, leaderState) {
                        if (leaderState.topScorers.isEmpty &&
                            leaderState.topAssisters.isEmpty &&
                            leaderState.topYellowCards.isEmpty &&
                            leaderState.topRedCards.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        List<Widget> availableCards = [];

                        if (leaderState.topScorers.isNotEmpty) {
                          availableCards.add(
                            _buildTopPlayerCard(
                              context,
                              DemoLocalizations.goal,
                              leaderState.topScorers,
                              'goals',
                            ),
                          );
                        }

                        if (leaderState.topAssisters.isNotEmpty) {
                          availableCards.add(
                            _buildTopPlayerCard(
                              context,
                              DemoLocalizations.topAssist,
                              leaderState.topAssisters,
                              'assists',
                            ),
                          );
                        }

                        if (leaderState.topYellowCards.isNotEmpty) {
                          availableCards.add(
                            _buildTopPlayerCard(
                              context,
                              DemoLocalizations.yellowCard,
                              leaderState.topYellowCards,
                              'yellow',
                            ),
                          );
                        }

                        if (leaderState.topRedCards.isNotEmpty) {
                          availableCards.add(
                            _buildTopPlayerCard(
                              context,
                              DemoLocalizations.redCard,
                              leaderState.topRedCards,
                              'red',
                            ),
                          );
                        }

                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 10.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DemoLocalizations.players,
                                style: TextUtils.setTextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Column(
                                children: [
                                  for (int i = 0;
                                      i < availableCards.length;
                                      i += 2)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: i < availableCards.length - 2
                                              ? 8.h
                                              : 0),
                                      child: Row(
                                        children: [
                                          Expanded(child: availableCards[i]),
                                          if (i + 1 <
                                              availableCards.length) ...[
                                            SizedBox(width: 8.w),
                                            Expanded(
                                                child: availableCards[i + 1]),
                                          ] else
                                            Expanded(child: SizedBox()),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Standings
                    ...standings.map((standing) => Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 10.h),
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildHeader(standing.leagueName,
                                  Theme.of(context).colorScheme.onSurface),
                              FirstRow(nameWidth: nameWidth),
                              ...standing.tableItems
                                  .map((tableItem) => Container(
                                        color: tableItem.id.toString() ==
                                                widget.teamId.toString()
                                            ? Colors.grey[700]?.withOpacity(0.7)
                                            : Colors.transparent,
                                        child: tablesItem(
                                          context,
                                          tableItem,
                                          nameWidth,
                                          Colors.transparent,
                                          teamProfile: true,
                                        ),
                                      )),
                            ],
                          ),
                        )),

                    // Venue Info
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: _buildVenueCard(),
                    ),

                    SizedBox(height: 16.h),
                  ]),
                ),
              ),
            ],
          );
        }

        // Error states
        if (state.status == teamProfileStandingStatus.notFound) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  DemoLocalizations.informationNotFound,
                  style: TextUtils.setTextStyle(fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 60,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                DemoLocalizations.networkProblem,
                style: TextUtils.setTextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                DemoLocalizations.tryAgain,
                style: TextUtils.setTextStyle(fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

// FORM ITEM WIDGET
  Widget _buildFormItem(
    BuildContext context,
    int scored,
    int conceded,
    String myTeamLogo,
    String opponentLogo,
    bool isHome,
    String myTeamId, // ADD THIS
    String opponentId,
  ) {
    // Determine color ONLY based on main team's result
    Color resultColor;
    if (scored > conceded) {
      resultColor = Colors.green; // Main team WON
    } else if (scored < conceded) {
      resultColor = Colors.red; // Main team LOST
    } else {
      resultColor = Colors.grey; // DRAW
    }

    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$scored - $conceded',
              style: TextUtils.setTextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main team logo
              CachedNetworkImage(
                height: 24.h,
                width: 24.w,
                imageUrl: myTeamLogo,
                placeholder: (_, __) =>
                    const Icon(Icons.shield, color: Colors.grey, size: 20),
                errorWidget: (_, __, ___) => Image.network(
                  'https://media.api-sports.io/football/teams/$myTeamId.png',
                  height: 24.h,
                  width: 24.w,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/club.png',
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Opponent logo
              CachedNetworkImage(
                height: 24.h,
                width: 24.w,
                imageUrl: opponentLogo,
                placeholder: (_, __) =>
                    const Icon(Icons.shield, color: Colors.grey, size: 20),
                errorWidget: (_, __, ___) => Image.network(
                  'https://media.api-sports.io/football/teams/$opponentId.png',
                  height: 24.h,
                  width: 24.w,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/club.png',
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(height: 100.h, color: Colors.white),
              SizedBox(height: 10.h),
              Container(height: 60.h, color: Colors.white),
              SizedBox(height: 20.h),
              Container(height: 200.h, color: Colors.white),
              SizedBox(height: 20.h),
              Container(height: 210.h, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamColumn(String? logoUrl, String teamName, dynamic teamId) {
    final fallbackUrl =
        'https://media.api-sports.io/football/teams/$teamId.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CachedNetworkImage(
          height: 30.h,
          width: 30.w,
          imageUrl:
              (logoUrl != null && logoUrl.isNotEmpty) ? logoUrl : fallbackUrl,
          placeholder: (_, __) =>
              const Icon(Icons.shield, color: Colors.grey, size: 20),
          errorWidget: (_, __, ___) =>
              Image.network(fallbackUrl, height: 30.h, width: 30.w),
        ),
        SizedBox(height: 4.h),
        Text(
          teamName,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextUtils.setTextStyle(fontSize: 12.sp),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Replace your _buildVenueCard() method with this:
// Replace your _buildVenueCard() method with this:
  Widget _buildVenueCard() {
    final hasVenueInfo = (widget.venuename?.isNotEmpty ?? false) ||
        (widget.venuecity?.isNotEmpty ?? false) ||
        (widget.venueaddress?.isNotEmpty ?? false) ||
        (widget.venuesurface?.isNotEmpty ?? false) ||
        (widget.venuecapacity?.isNotEmpty ?? false) ||
        (widget.founded?.isNotEmpty ?? false) ||
        (widget.venueimage?.isNotEmpty ?? false);

    if (!hasVenueInfo) {
      return const SizedBox.shrink();
    }

    // Determine which image to use: venueimage first, fallback to asset
    final bool hasValidVenueImage = widget.venueimage?.isNotEmpty ?? false;
    final String? venueImageUrl = hasValidVenueImage ? widget.venueimage : null;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      height: 230.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Background Image: Venue image → fallback to asset pitch
            Positioned.fill(
              child: hasValidVenueImage
                  ? CachedNetworkImage(
                      imageUrl: venueImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/bg_pitch.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/bg_pitch.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                        );
                      },
                    ),
            ),

            // Dark Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Content (unchanged)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.stadium,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        DemoLocalizations.venue,
                        style: TextUtils.setTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (widget.venuename?.isNotEmpty ?? false)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.greenAccent,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.venuename!,
                            style: TextUtils.setTextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if ((widget.venuecity?.isNotEmpty ?? false) ||
                      (widget.venueaddress?.isNotEmpty ?? false))
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 28.w),
                      child: Text(
                        '${widget.venuecity ?? ''}${(widget.venuecity?.isNotEmpty ?? false) && (widget.venueaddress?.isNotEmpty ?? false) ? ', ' : ''}${widget.venueaddress ?? ''}',
                        style: TextUtils.setTextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.venuecapacity?.isNotEmpty ?? false)
                        _venueInfoCard(
                          icon: Icons.people,
                          value: widget.venuecapacity!,
                          label: DemoLocalizations.capacity,
                        ),
                      if (widget.venuesurface?.isNotEmpty ?? false)
                        _venueInfoCard(
                          icon: Icons.grass,
                          value: widget.venuesurface!,
                          label: DemoLocalizations.surface,
                        ),
                      if (widget.founded?.isNotEmpty ?? false)
                        _venueInfoCard(
                          icon: Icons.calendar_today,
                          value: widget.founded!,
                          label: DemoLocalizations.found,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// New helper method for info cards
  Widget _venueInfoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.greenAccent,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextUtils.setTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Remove the old _venueInfoItem method as it's replaced by _venueInfoCard
// Remove the old _venueInfoItem method as it's replaced by _venueInfoCard
  String _getLocalizedTeamName(dynamic match, bool isHome, String lang) {
    if (isHome) {
      switch (lang) {
        case 'am':
        case 'tr':
          return match.homeTeam_am;
        case 'so':
          return match.homeTeam_so;
        case 'or':
          return match.homeTeam_or;
        default:
          return match.homeTeam;
      }
    } else {
      switch (lang) {
        case 'am':
        case 'tr':
          return match.awayTeam_am;
        case 'so':
          return match.awayTeam_so;
        case 'or':
          return match.awayTeam_or;
        default:
          return match.awayTeam;
      }
    }
  }

  Widget _buildHeader(LeagueName leagueName, Color onSurfaceColor) {
    final String name = switch (localLanguageNotifier.value) {
      'am' || 'tr' => leagueName.amharicName,
      'so' => leagueName.somaliName,
      'or' => leagueName.oromoName,
      _ => leagueName.englishName,
    };

    return SizedBox(
      height: 40.h,
      child: Center(
        child: Text(
          name,
          style: TextUtils.setTextStyle(fontSize: 16.sp, color: onSurfaceColor),
        ),
      ),
    );
  }
}
