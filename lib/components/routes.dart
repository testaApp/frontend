import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_bloc.dart';
import '../bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_event.dart';
import '../bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_bloc.dart';
import '../bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_event.dart';
import '../bloc/news/news_bloc.dart';
import '../bloc/news/news_event.dart';
import '../domain/player/playerModel.dart';
import '../domain/player/playerName.dart';
import '../main.dart';
import '../pages/appbar_pages/enadamt/enadamt_new.dart';
import '../pages/appbar_pages/enadamt/program_detail_page.dart';
import '../pages/bottom_navigation/matches/matchDetail.dart';
import '../pages/bottom_navigation/matches/matches.dart';
import '../models/news.dart';
import '../models/teamName.dart';
import '../Homepage.dart';
import '../pages/navigation/notifications_page.dart';
import '../pages/appbar_pages/news/main_news/news_detail.dart';
import '../pages/appbar_pages/news/transfer_news/top_transfer/transfer/transfer_bloc.dart';
import '../pages/appbar_pages/news/transfer_news/top_transfer/transfer/transfer_event.dart';
import '../pages/appbar_pages/news/transfer_news/top_transfer/transferpage.dart';
import '../pages/bottom_navigation/favourites_page/favourites_page/player/playerProfilePage.dart';
import '../pages/bottom_navigation/favourites_page/team/team_profile_page.dart';
import '../pages/entry_pages/choos_fav_players_list.dart';
import '../pages/entry_pages/entrypage.dart';
import '../pages/entry_pages/introduction_page.dart';
import '../pages/entry_pages/language.dart';
import '../pages/entry_pages/top_of_teamslist_choose.dart';
import '../pages/entry_pages/videointro.dart';
import '../pages/login/login.dart';
import '../pages/login/passcode.dart';
import '../pages/login/upload_profile_pic_page.dart';
import '../pages/navigation/settings_page.dart';
import '../pages/payment/payment_page.dart';
import '../util/auth/tokens.dart';
import 'routenames.dart';

Future<bool> checkLoggedIn() async {
  final token = await getRefreshToken();
  return token != null;
}

GoRouter createRoute(String initialLocation) {
  return GoRouter(
    observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
    initialLocation: initialLocation,
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'rootNavigator'),
    debugLogDiagnostics: true,
    routes: [
      _createGoRoute(
        path: '/videointro',
        name: 'videoIntro',
        builder: (context, state) => const VideoIntroPage(),
      ),
      _createGoRoute(
        path: '/language',
        name: RouteNames.chooselanguage,
        builder: (context, state) => const LanguageChoose(),
      ),
      _createGoRoute(
        path: '/podcast/:id',
        name: 'podcastLive',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;

          // Helper to safely parse rssLink
          List<String> parseRssLinks(dynamic data) {
            if (data == null) return const [];
            try {
              if (data is String) {
                final decoded = jsonDecode(data);
                return List<String>.from(decoded);
              } else if (data is List) {
                return List<String>.from(data);
              }
            } catch (e) {
              debugPrint('❌ Error parsing rssLink: $e');
            }
            return const [];
          }

          // Safe boolean parsing
          bool parseIsLive(dynamic value) {
            if (value == null) return false;
            if (value is bool) return value;
            if (value is String) return value.toLowerCase() == 'true';
            return false;
          }

          // Get user's preferred language from extra data or use current
          final userLanguage = extra?['language']?.toString() ?? localLanguageNotifier.value;

          debugPrint('📻 Opening podcast with language: $userLanguage');
          debugPrint('   ID: $id');
          debugPrint('   Program: ${extra?['program']}');

          return Program(
            id: id,
            programId: extra?['programId']?.toString() ?? '',
            name: extra?['name']?.toString() ?? '',
            program: extra?['program']?.toString() ?? '',
            station: extra?['station']?.toString() ?? '',
            description: extra?['description']?.toString() ?? '',
            avatar: extra?['avatar']?.toString() ?? '',
            liveLink: extra?['liveLink']?.toString() ?? '',
            rssLink: parseRssLinks(extra?['rssLink']),
            time: const [],
            isProgram: parseIsLive(extra?['isLive']),
          );
        },
      ),

      _createGoRoute(
        path: '/transfer',
        name: RouteNames.transfer,
        builder: (context, state) {
          return MultiProvider(
            providers: [
              BlocProvider(
                create: (_) => TransferBloc()..add(TransferRequested()),
              ),
              BlocProvider(
                create: (_) => NewsBloc()
                  ..add(TransferNewsRequested(
                      language: localLanguageNotifier.value)),
              ),
            ],
            child: TransferPage(onScroll: (offset) {}),
          );
        },
      ),
      _createGoRoute(
        path: '/settings',
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
         _createGoRoute(
        path: '/enadamt',
        name: RouteNames.enadamt,
        builder: (context, state) => const EnadamtNew(),
      ),
          _createGoRoute(
        path: '/matchespage',
        name: RouteNames.matchespage,
        builder: (context, state) => const MatchesPage(),
      ),
      _createGoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const Login(),
      ),
      _createGoRoute(
        path: '/profile',
        name: RouteNames.playerProfile,
        builder: (context, state) {
          String? val = state.uri.queryParameters['favourite'];
          String? teamLogo = state.uri.queryParameters['teamPic'];

          if (state.extra != null) {
            if (val == null) {
              if (state.extra is PlayerName) {
                return PlayerProfilePage(
                  playerName: state.extra as PlayerName,
                  teamPic: teamLogo,
                );
              }
            } else {
              if (state.extra is PlayerProfile) {
                return PlayerProfilePage(
                  profile: state.extra as PlayerProfile,
                  teamPic: teamLogo,
                );
              }
            }
          }

          return PlayerProfilePage(
            teamPic: teamLogo,
          );
        },
      ),
      _createGoRoute(
        path: '/teamProfilePage',
        name: RouteNames.teamProfilePage,
        builder: (context, state) {
          final TeamName teamName = state.extra! as TeamName;

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => TeamProfileStandingBloc()
                  ..add(
                    TeamStandingRequested(
                      teamId: teamName.id,
                    ),
                  ),
              ),
              BlocProvider(
                create: (_) => TeamProfileStatisticsBloc()
                  ..add(
                    TeamProfileStatisticsRequested(
                      teamId: teamName.id,
                    ),
                  ),
              ),
            ],
            child: TeamProfilePage(
              teamName: teamName,
            ),
          );
        },
      ),
      _createGoRoute(
        path: '/passcode',
        name: RouteNames.passcode,
        builder: (context, state) {
          String phoneNumber = state.uri.queryParameters['phoneNumber']!;
          String name = state.uri.queryParameters['name']!;
          return PassCode(phoneNumber: phoneNumber, name: name);
        },
      ),
      _createGoRoute(
        path: '/entrypage',
        name: RouteNames.entrypage,
        builder: (context, state) => const entrypage(),
      ),
      _createGoRoute(
        path: '/favteam_entry',
        name: RouteNames.favouriteTeam_entry,
        builder: (context, state) {
          final selectedLanguage = state.extra as String;
          return FollowTeamsPageEntry(selectedLanguage: selectedLanguage);
        },
      ),
      _createGoRoute(
        path: '/favplayer_entry',
        name: RouteNames.favouritePlayer_entry,
        builder: (context, state) {
          final selectedLanguage = state.extra as String? ?? 'en';
          return ChooseFavPlayerEntry(selectedLanguage: selectedLanguage);
        },
      ),
      _createGoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      _createGoRoute(
        path: '/IntroductionPage',
        name: RouteNames.IntroductionPage,
        builder: (context, state) {
          final selectedLanguage = state.extra as String;
          return IntroductionPage(selectedLanguage: selectedLanguage);
        },
      ),
_createGoRoute(
  path: '/newsDetail/:id',
  name: RouteNames.newsDetail,
  builder: (context, state) {
    final id = state.pathParameters['id'];

    // Handle language from query parameters (deep link)
    final lang = state.uri.queryParameters['lang'];
    if (lang != null && lang.isNotEmpty) {
      localLanguageNotifier.value = lang;
    }

    return NewsDetailPage(id: id);
  },
),

      _createGoRoute(
        path: '/notificationSettings',
        name: RouteNames.notificationSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      _createGoRoute(
        path: '/matchDetail',
        name: RouteNames.matchDetail,
        builder: (context, state) {
          final fixtureIdString = state.uri.queryParameters['fixtureId'];
          final fixtureId = int.tryParse(fixtureIdString ?? '');

          if (fixtureId == null) {
            return const Scaffold(body: Center(child: Text("Invalid Match ID")));
          }

          return MatchDetailsPage(fixtureId: fixtureId);
        },
      ),
      _createGoRoute(
        path: '/payment',
        name: RouteNames.payment,
        builder: (context, state) => const PaymentPage(title: ''),
      ),
      _createGoRoute(
        path: '/upload-profile-pic',
        name: RouteNames.uploadProfilePic,
        builder: (context, state) => const UploadProfilePicPage(),
      ),
    ],
  );
}

GoRoute _createGoRoute({
  required String path,
  required String name,
  required GoRouterWidgetBuilder builder,
}) {
  return GoRoute(
    path: path,
    name: name,
    builder: builder,
  );
}