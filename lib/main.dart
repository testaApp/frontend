import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'application/Favourite_team/favouriteteam_bloc.dart';
import 'application/auth/auth_bloc.dart';
import 'application/favourite_league/favourite_league_bloc.dart';
import 'application/favourite_player/PlayerSelection_bloc.dart';
import 'application/favourite_player/favouriteplayer_bloc.dart';
import 'application/following/following_bloc.dart';
import 'application/matchdetail/fixtureEvents/events/bloc/fixtureevent_bloc.dart';
import 'application/matchdetail/head_to_head/head_to_head_bloc.dart';
import 'application/matchdetail/match/match_bloc.dart';
import 'application/matchdetail/matchStatistics/match_statistics_bloc.dart';
import 'application/persistent_player/persistent_player_bloc.dart';
import 'application/product/product_bloc.dart';
import 'application/provider/song_model_provider.dart';
import 'application/scroller/scroller_bloc.dart';
import 'application/seasons_page/seasons_page_bloc.dart';
import 'application/set_preference/set_preference_bloc.dart';
import 'application/team/team_bloc.dart';
import 'application/testing/bloc/audio_bloc.dart';
import 'application/volume_bloc/volume_bloc.dart';
import 'apptheme.dart';
import 'bloc/availableSeasons/available_seasons_bloc.dart';
import 'bloc/highlightTv_bloc/highlightTv_Event.dart';
import 'bloc/highlightTv_bloc/highlightTv_bloc.dart';
import 'bloc/knockout/Knockout_bloc.dart';
import 'bloc/leagues_page/top_assist/top_assist_bloc.dart';

import 'bloc/leagues_page/top_scorer/top_scorers_bloc.dart';
import 'bloc/leagues_page/top_yellow_card/top_yellow_bloc.dart';
import 'bloc/leagues_page/top_red/top_red_bloc.dart';

import 'bloc/lineups/lineups_bloc.dart';
import 'bloc/live-tv-player_bloc-state-event/video_player_bloc.dart';
import 'bloc/live_tv/live_tv_bloc.dart';
import 'bloc/live_tv/live_tv_event.dart';
import 'bloc/matches_page_highlights_page/bloc/highlights_page_bloc.dart';
import 'bloc/mirchaweche/my_fav/my_fav_player/myfavourite_players_bloc.dart';
import 'bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_bloc.dart';
import 'bloc/mirchaweche/players/player_profile/player_profile_bloc.dart';
import 'bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import 'bloc/mirchaweche/teams/last_five_matches/last_five_matches_bloc.dart';
import 'bloc/mirchaweche/teams/previous&next_matchs/matches_bloc.dart';
import 'bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_bloc.dart';
import 'bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_bloc.dart';
import 'bloc/news/news_bloc.dart';
import 'bloc/payment_bloc/payment_bloc.dart';
import 'application/enadamt/podcast/podcast_bloc.dart';
import 'bloc/quiz_bloc/quiz_bloc.dart';
import 'bloc/social_media/social_media_bloc.dart';
import 'bloc/standings/bloc/content_bloc.dart';
import 'bloc/video/video_bloc.dart';
import 'components/routes.dart';
import 'domain/product/productRepository.dart';
import 'pages/appbar_pages/enadamt/audio_handler_new.dart';
import 'pages/navigation/quiz/quiz_repository.dart';
import 'services/fcm_service.dart';
import 'services/service_locator.dart';
import 'pages/navigation/themeprovider.dart';
import 'util/add_to_hive.dart';
import 'util/auth/store_info.dart';
import 'util/auth/tokens.dart';
import 'util/baseUrl.dart';
import 'util/notifiers/username_notifier.dart';

Future<void> deleteLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await clearTokens();
}

Future<void> fetchLocalizationValues(String languageCode) async {
  final box1 = await Hive.openBox<LocalizationData>('localization');

  final url = BaseUrl().url;
  final response = await http.get(
    Uri.parse('$url/api/localization?languageCode=$languageCode'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, String> localizedValues =
        data.map((key, value) => MapEntry(key, value.toString()));

    // Store the localized values in the Hive box
    for (final entry in localizedValues.entries) {
      final localizationData =
          LocalizationData(key: entry.key, value: entry.value);
      await box1.put('$languageCode-${entry.key}', localizationData);
    }
  } else {
    // Handle error
  }
}

late GoRouter globalRouter;
ValueNotifier<String> localLanguageNotifier = ValueNotifier('am');
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMService().initialize(); // Basic setup only

// For returning users: quietly register if setup done
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('setup_done') ?? false) {
    await FCMService().requestPermissionAndRegisterToken();
  }
  // Initialize service locator first (without audio handler)
  await setupServiceLocator();

  // Then initialize audio service
  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.myapp.audio',
      androidNotificationChannelName: 'Audio Service',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      preloadArtwork: true,
    ),
  );

  // Register audio handler in service locator
  getIt.registerSingleton<AudioHandler>(audioHandler);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  ErrorWidget.builder = (errorDetails) {
    return const Text('');
  };

  await Hive.initFlutter();
  Hive.registerAdapter(LocalizationDataAdapter());
  var box = await Hive.openBox('settings');
  localLanguageNotifier.value = box.get('language', defaultValue: 'am');
  String? name = await getInformation(key: 'name');
  String? phoneNumber = await getInformation(key: 'phoneNumber');

  userNameNotifier.value = name;
  phonenumberNotifier.value = phoneNumber;

  String initLocation = await checkLoggedIn() ? '/entrypage' : '/videointro';

  globalRouter = createRoute(initLocation);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          RepositoryProvider<QuizRepository>(
            create: (context) => QuizRepository(
              secureStorage: const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true),
                iOptions: IOSOptions(),
              ),
            ),
          ),
          BlocProvider(create: (context) => PersistentPlayerBloc()),

          BlocProvider<TeamBloc>(
            create: (context) => TeamBloc(),
          ),
          BlocProvider<AudioBloc>(
            create: (context) => AudioBloc(),
          ),
          BlocProvider<QuizBloc>(
            create: (context) => QuizBloc(
              quizRepository: context.read<QuizRepository>(),
            ),
          ),
          BlocProvider<VideoBloc>(
            create: (context) => VideoBloc(),
          ),
          BlocProvider<SocialMediaBloc>(
            create: (context) => SocialMediaBloc(),
            child: Container(),
          ),
          BlocProvider(create: (context) => VideoPlayerBloc()),
          // BlocProvider(
          //   create: (context) => YoutubePlayerBloc(),
          // ),
          BlocProvider<LiveTvBloc>(
            create: (context) => LiveTvBloc()..add(LiveTvRequested()),
          ),

          BlocProvider<HighlightTvBloc>(
            create: (context) => HighlightTvBloc()
              ..add(FetchRecentHighlights())
              ..add(const FetchCategories(1)),
          ),
          BlocProvider<VolumeBloc>(create: (context) => VolumeBloc()),
          BlocProvider<FixtureeventBloc>(
            create: (context) => FixtureeventBloc(),
          ),

          BlocProvider<TopScorersBloc>(
            create: (context) => TopScorersBloc(),
          ),
          BlocProvider<TopAssistorsBloc>(
            create: (context) => TopAssistorsBloc(),
          ),
          BlocProvider<TopRedCardsBloc>(
            create: (context) => TopRedCardsBloc(),
            lazy: false,
          ),

          BlocProvider<MatchesPageBloc>(
            create: (context) => MatchesPageBloc(),
          ),

          // BlocProvider<CompletedBloc>(
          //   create: (context) => CompletedBloc(),
          // ),

          // BlocProvider<HeresayBloc>(
          //   create: (context) => HeresayBloc(),
          // ),
          BlocProvider<KnockoutBloc>(
            create: (context) => KnockoutBloc(),
          ),

          // ChangeNotifierProvider(
          //   create: (context) => DataState(),
          //   child: Dynamicad(),
          // ),

          // BlocProvider<FixtureBloc>(
          //   create: (context) => FixtureBloc(),
          // ),

          BlocProvider<ContentBloc>(
            create: (context) => ContentBloc(),
          ),
          BlocProvider<MatchStatisticsBloc>(
            create: (context) => MatchStatisticsBloc(),
          ),

          BlocProvider<HighlightsPageBloc>(
            create: (context) => HighlightsPageBloc(),
          ),

          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(repository: ProductRepository()),
          ),
          BlocProvider<ScrollerBloc>(
            create: (context) => ScrollerBloc(),
          ),

          ChangeNotifierProvider<SongModelProvider>(
            create: (_) => SongModelProvider(),
          ),
          ChangeNotifierProvider<ThemeService>(
            create: (context) => ThemeService(),
          ),
          BlocProvider<PodcastsBloc>(create: (context) => PodcastsBloc()),
          BlocProvider<LineupsBloc>(
            create: (context) => LineupsBloc(),
          ),
          BlocProvider<FavouriteplayerBloc>(
              create: (context) => FavouriteplayerBloc()),
          BlocProvider<TopYellowCardsBloc>(
              create: (context) => TopYellowCardsBloc()),
          BlocProvider<PlayerSelectionBloc>(
            create: (context) => PlayerSelectionBloc(),
          ),

          // Keep your existing TopYellowCardsBloc
          BlocProvider<TopYellowCardsBloc>(
            create: (context) => TopYellowCardsBloc(),
          ),
          BlocProvider<FavouriteTeamBloc>(
            create: (context) => FavouriteTeamBloc(),
          ),
          BlocProvider<AvailableSeasonsBloc>(
              create: (context) => AvailableSeasonsBloc()),
          BlocProvider<NewsBloc>(
            create: (context) => NewsBloc(),
          ),
          BlocProvider<ContentBloc>(
            create: (context) => ContentBloc(),
          ),
          BlocProvider<HeadToHeadBloc>(
            create: (context) => HeadToHeadBloc(),
          ),
          BlocProvider<MyfavouritePlayersBloc>(
            create: (context) => MyfavouritePlayersBloc(),
          ),
          BlocProvider<TeammatesBloc>(create: (context) => TeammatesBloc()),
          BlocProvider<PlayerProfileBloc>(
              create: (context) => PlayerProfileBloc()),
          BlocProvider<MyfavouriteteamsBloc>(
              create: (context) => MyfavouriteteamsBloc()),
          BlocProvider<TeamProfileStatisticsBloc>(
              create: (context) => TeamProfileStatisticsBloc()),
          BlocProvider<TeamProfileStandingBloc>(
              create: (context) => TeamProfileStandingBloc()),
          BlocProvider<LastFiveMatchesBloc>(
              create: (context) => LastFiveMatchesBloc()),
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          BlocProvider<SetPreferenceBloc>(
              create: (context) => SetPreferenceBloc()),
          BlocProvider<FavouriteLeagueBloc>(
              create: (context) => FavouriteLeagueBloc()),
          BlocProvider<SeasonsPageBloc>(create: (context) => SeasonsPageBloc()),
          BlocProvider<FollowingBloc>(create: (context) => FollowingBloc()),
          BlocProvider<MatchBloc>(create: (context) => MatchBloc()),
          BlocProvider<PaymentBloc>(create: (context) => PaymentBloc()),
        ],
        //         child: DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (context) => MyApp(), // Wrap your app
        // ),

        child: MyApp(
          initLocation: initLocation,
        ),
      ),
    ),
  );
  // Get theme provider from the nearest context
}

class MyApp extends StatefulWidget {
  final String initLocation;
  const MyApp({super.key, required this.initLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleDeepLink();
    _loadLanguage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Update system UI when app resumes
        _updateSystemUIAfterBuild();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }

  _loadLanguage() async {
    var box = await Hive.openBox('settings');
    localLanguageNotifier.value = box.get('language', defaultValue: 'am');
  }

  void _updateSystemUIAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final themeService = Provider.of<ThemeService>(context, listen: false);
      final brightness = MediaQuery.of(context).platformBrightness;

      final isDarkMode = themeService.themeMode == ThemeMode.dark ||
          (themeService.themeMode == ThemeMode.system &&
              brightness == Brightness.dark);

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeService>(
          builder: (context, themeService, _) {
            // Schedule system UI update after build completes
            _updateSystemUIAfterBuild();

            return Directionality(
              textDirection: TextDirection.ltr,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: globalRouter,
                title: 'Home',
                themeMode: themeService.themeMode,
                theme: lightMode,
                darkTheme: darkMode,
                builder: (context, child) {
                  return child!;
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeepLink() async {
    final appLinks = AppLinks();
    final Uri? uri = await appLinks.getInitialLink();
    if (uri != null) {
      openAppLink(uri);
    }

    appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'news') {
      final newsId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      final lang = uri.queryParameters['lang'] ?? localLanguageNotifier.value;

      if (newsId != null) {
        localLanguageNotifier.value = lang;
        globalRouter.go('/news/$newsId', extra: lang);
      }
    } else {
      globalRouter.go('/home');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
