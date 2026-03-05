import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

import 'package:blogapp/state/application/Favourite_team/favouriteteam_bloc.dart';
import 'package:blogapp/state/application/auth/auth_bloc.dart';
import 'package:blogapp/state/application/favourite_league/favourite_league_bloc.dart';
import 'package:blogapp/state/application/favourite_player/PlayerSelection_bloc.dart';
import 'package:blogapp/state/application/favourite_player/favouriteplayer_bloc.dart';
import 'package:blogapp/state/application/following/following_bloc.dart';
import 'package:blogapp/state/application/matchdetail/fixtureEvents/events/bloc/fixtureevent_bloc.dart';
import 'package:blogapp/state/application/matchdetail/head_to_head/head_to_head_bloc.dart';
import 'package:blogapp/state/application/matchdetail/match/match_bloc.dart';
import 'package:blogapp/state/application/matchdetail/matchStatistics/match_statistics_bloc.dart';
import 'package:blogapp/state/application/persistent_player/persistent_player_bloc.dart';
import 'package:blogapp/state/application/provider/song_model_provider.dart';
import 'package:blogapp/state/application/seasons_page/seasons_page_bloc.dart';
import 'package:blogapp/state/application/set_preference/set_preference_bloc.dart';
import 'package:blogapp/state/application/team/team_bloc.dart';
import 'apptheme.dart';
import 'package:blogapp/state/bloc/availableSeasons/available_seasons_bloc.dart';
import 'package:blogapp/state/bloc/highlightTv_bloc/highlightTv_bloc.dart';
import 'package:blogapp/state/bloc/knockout/Knockout_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_assist/top_assist_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_scorer/top_scorers_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_yellow_card/top_yellow_bloc.dart';
import 'package:blogapp/state/bloc/leagues_page/top_red/top_red_bloc.dart';
import 'package:blogapp/state/bloc/lineups/lineups_bloc.dart';
import 'package:blogapp/state/bloc/live-tv-player_bloc-state-event/video_player_bloc.dart';
import 'package:blogapp/state/bloc/live_tv/live_tv_bloc.dart';
import 'package:blogapp/state/bloc/matches_page_highlights_page/bloc/highlights_page_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/my_fav/my_fav_player/myfavourite_players_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/my_fav/my_fav_team/myfavouriteteams_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/players/player_profile/player_profile_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/players/player_teammates/teammates_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/last_five_matches/last_five_matches_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/previous&next_matchs/matches_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/team_profile_standing/team_profile_standing_bloc.dart';
import 'package:blogapp/state/bloc/mirchaweche/teams/team_profile_statistics/team_profile_statistics_bloc.dart';
import 'package:blogapp/state/bloc/news/news_bloc.dart';
import 'package:blogapp/state/application/enadamt/podcast/podcast_bloc.dart';
import 'package:blogapp/state/bloc/standings/bloc/content_bloc.dart';
import 'package:blogapp/state/bloc/video/video_bloc.dart';
import 'components/routes.dart';
import 'package:blogapp/features/enadamt/pages/enadamt/audio_handler_new.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_repository.dart';
import 'services/analytics_service.dart';
import 'services/fcm_service.dart';
import 'services/following_storage_service.dart';
import 'services/sync_service.dart';
import 'services/service_locator.dart';
import 'package:blogapp/features/navigation/pages/themeprovider.dart';
import 'package:blogapp/core/storage/add_to_hive.dart';
import 'package:blogapp/features/auth/services/store_info.dart';
import 'package:blogapp/features/auth/services/firebase_auth_service.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/core/notifiers/username_notifier.dart';

//intiate firebase analytics observer
final FirebaseAnalytics observer = FirebaseAnalytics.instance;
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// BACKGROUND MESSAGE HANDLER (must be top-level)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('ðŸ”” Background message received â†’ ${message.messageId}');
  debugPrint('   Type: ${message.data['type']}');
  // FCM will display the notification automatically
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Global variables
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
late GoRouter globalRouter;
ValueNotifier<String> localLanguageNotifier = ValueNotifier('am');
late FollowingStorageService globalStorageService;
late FollowingAnalyticsService globalAnalyticsService;
Future<void>? _audioHandlerInitialization;
const List<String> supportedLocalizationLanguages = [
  'am',
  'en',
  'tr',
  'so',
  'or',
];

class _LocalizationNetworkMetrics {
  int totalRequests = 0;
  int failedRequests = 0;
  int totalRequestBytes = 0;
  int totalDecodedResponseBytes = 0;
  int totalContentLengthBytes = 0;
  int contentLengthSamples = 0;

  void reset() {
    totalRequests = 0;
    failedRequests = 0;
    totalRequestBytes = 0;
    totalDecodedResponseBytes = 0;
    totalContentLengthBytes = 0;
    contentLengthSamples = 0;
  }

  void recordResponse({
    required String languageCode,
    required int statusCode,
    required int requestBytes,
    required int decodedResponseBytes,
    required int? contentLengthBytes,
  }) {
    totalRequests++;
    if (statusCode != 200) {
      failedRequests++;
    }
    totalRequestBytes += requestBytes;
    totalDecodedResponseBytes += decodedResponseBytes;
    if (contentLengthBytes != null) {
      totalContentLengthBytes += contentLengthBytes;
      contentLengthSamples++;
    }

    final contentLengthInfo = contentLengthBytes == null
        ? 'n/a'
        : '${_formatBytes(contentLengthBytes)} ($contentLengthBytes B)';
    debugPrint(
      'ðŸŒ [Localization] $languageCode â€¢ status=$statusCode â€¢ req=${_formatBytes(requestBytes)} ($requestBytes B) '
      'â€¢ resp(decoded)=${_formatBytes(decodedResponseBytes)} ($decodedResponseBytes B) '
      'â€¢ resp(content-length)=$contentLengthInfo',
    );
  }

  void recordTransportFailure({
    required String languageCode,
    required int requestBytes,
    required Object error,
  }) {
    totalRequests++;
    failedRequests++;
    totalRequestBytes += requestBytes;

    debugPrint(
      'ðŸŒ [Localization] $languageCode â€¢ transport-failure=$error '
      'â€¢ req=${_formatBytes(requestBytes)} ($requestBytes B)',
    );
  }

  void printSummary({required String context}) {
    debugPrint(
      'ðŸ“Š [$context] Localization network summary: '
      'requests=$totalRequests, failed=$failedRequests, '
      'request=${_formatBytes(totalRequestBytes)} ($totalRequestBytes B), '
      'response(decoded)=${_formatBytes(totalDecodedResponseBytes)} ($totalDecodedResponseBytes B), '
      'response(content-length)=${_formatBytes(totalContentLengthBytes)} '
      '($totalContentLengthBytes B across $contentLengthSamples responses)',
    );
  }
}

final _localizationNetworkMetrics = _LocalizationNetworkMetrics();

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

void resetLocalizationNetworkDebugMetrics() {
  _localizationNetworkMetrics.reset();
}

void printLocalizationNetworkDebugSummary({
  String context = 'Localization',
}) {
  _localizationNetworkMetrics.printSummary(context: context);
}

Future<void> _runStartupStep(
  String label,
  Future<void> Function() step, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  try {
    await step().timeout(timeout);
  } catch (error, stackTrace) {
    debugPrint('Startup step failed [$label]: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _initializeAudioHandlerIfNeeded() {
  if (getIt.isRegistered<AudioHandler>()) {
    return Future.value();
  }

  _audioHandlerInitialization ??= () async {
    try {
      final audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.myapp.audio',
          androidNotificationChannelName: 'Playback',
          androidNotificationChannelDescription: 'Podcast playback controls',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: false,
          preloadArtwork: true,
        ),
      );

      if (!getIt.isRegistered<AudioHandler>()) {
        getIt.registerSingleton<AudioHandler>(audioHandler);
      }
    } catch (error) {
      _audioHandlerInitialization = null;
      rethrow;
    }
  }();

  return _audioHandlerInitialization!;
}

Future<void> _runPostLoginStartupSync(String languageCode) async {
  final following =
      await syncFollowingDataAfterLogin(storageService: globalStorageService);
  await enableAllNotificationPrefs();
  await ensureBreakingNewsSubscription();
  await resubscribeUserTopics(
    matchIds: following.matchIds,
    podcastIds: following.podcastIds,
    languageCode: languageCode,
  );
}

Future<void> ensureAudioHandlerReady() => _initializeAudioHandlerIfNeeded();

Future<void> deleteLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final currentLang = localLanguageNotifier.value;

  // 1. Clean up FCM topics
  await FCMTopicManager.cleanupOnLogout(currentLang);

  // 2. Clear the Analytics User ID (This is the important part!)
  await FirebaseAnalytics.instance.setUserId(id: null);

  // 3. Clear local storage
  await prefs.clear();
  await signOutToAnonymous();

  debugPrint(
      'User logged out â†’ Analytics ID cleared & FCM topics cleaned up');
  // 4. Clear Following Storage
  await globalStorageService.clearAll();
  debugPrint('âœ… Following storage cleared on logout');
}

Future<Box<LocalizationData>> _getLocalizationBox() async {
  if (Hive.isBoxOpen('localization')) {
    return Hive.box<LocalizationData>('localization');
  }

  return Hive.openBox<LocalizationData>('localization');
}

Future<void> fetchLocalizationValues(
  String languageCode, {
  Box<LocalizationData>? box,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final localizationBox = box ?? await _getLocalizationBox();
  final url = BaseUrl().url;
  final uri = Uri.parse('$url/api/localization?languageCode=$languageCode');
  final requestBytes = utf8.encode(uri.toString()).length;
  late final http.Response response;

  try {
    response = await http.get(uri).timeout(timeout);
  } catch (error) {
    _localizationNetworkMetrics.recordTransportFailure(
      languageCode: languageCode,
      requestBytes: requestBytes,
      error: error,
    );
    rethrow;
  }

  final contentLengthBytes =
      int.tryParse(response.headers['content-length'] ?? '');
  _localizationNetworkMetrics.recordResponse(
    languageCode: languageCode,
    statusCode: response.statusCode,
    requestBytes: requestBytes,
    decodedResponseBytes: response.bodyBytes.length,
    contentLengthBytes: contentLengthBytes,
  );

  if (response.statusCode != 200) {
    throw HttpException(
      'Localization request failed for "$languageCode": ${response.statusCode}',
    );
  }

  final decodedBody = json.decode(response.body);
  if (decodedBody is! Map<String, dynamic>) {
    throw const FormatException('Unexpected localization payload format');
  }

  final localizedEntries = <String, LocalizationData>{};
  decodedBody.forEach((key, value) {
    final normalizedKey = key.toString();
    localizedEntries['$languageCode-$normalizedKey'] = LocalizationData(
      key: normalizedKey,
      value: value.toString(),
    );
  });

  if (localizedEntries.isNotEmpty) {
    await localizationBox.putAll(localizedEntries);
  }
}

Future<void> preloadLocalizations() async {
  final localizationBox = await _getLocalizationBox();
  await Future.wait([
    for (final languageCode in supportedLocalizationLanguages)
      fetchLocalizationValues(languageCode, box: localizationBox),
  ]);
}

Future<void> preloadLocalizationsPrioritized({
  required String primaryLanguageCode,
  Duration deferredDelay = const Duration(seconds: 2),
}) async {
  final localizationBox = await _getLocalizationBox();
  final normalizedPrimary =
      supportedLocalizationLanguages.contains(primaryLanguageCode)
          ? primaryLanguageCode
          : supportedLocalizationLanguages.first;

  await fetchLocalizationValues(
    normalizedPrimary,
    box: localizationBox,
  );

  await Future.delayed(deferredDelay);

  await Future.wait([
    for (final languageCode in supportedLocalizationLanguages)
      if (languageCode != normalizedPrimary)
        fetchLocalizationValues(languageCode, box: localizationBox),
  ]);
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Future.wait([
    _runStartupStep(
      'anonymous_auth',
      FirebaseAuthService.initializeAnonymousAuth,
      timeout: const Duration(seconds: 20),
    ),
    _runStartupStep('hive_init', Hive.initFlutter),
    _runStartupStep(
      'system_ui',
      () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    ),
    _runStartupStep(
      'awesome_notifications',
      FCMService.initializeAwesomeNotifications,
    ),
  ]);

  // Do not block first frame on audio setup; warm it up in background.
  unawaited(
    _runStartupStep(
      'audio_handler',
      ensureAudioHandlerReady,
      timeout: const Duration(seconds: 10),
    ),
  );
  await _runStartupStep('service_locator', setupServiceLocator);

  ErrorWidget.builder = (errorDetails) => ColoredBox(
        color: const Color(0xFF111111),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Something went wrong.\n${errorDetails.exceptionAsString()}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  globalStorageService = FollowingStorageService();
  await Future.wait([
    _runStartupStep('fcm_service_init', () => FCMService().initialize()),
    _runStartupStep('following_storage_init', globalStorageService.init),
  ]);
  debugPrint('âœ… Following Storage Service initialized');

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LocalizationDataAdapter());
  }

  final prefsFuture = SharedPreferences.getInstance();

  final currentUser = FirebaseAuth.instance.currentUser;
  final isLoggedIn = currentUser != null && !currentUser.isAnonymous;
  final shouldSkipOnboarding = isLoggedIn;

  globalAnalyticsService = FollowingAnalyticsService();
  debugPrint('âœ… Following Analytics Service initialized');
  var box = await Hive.openBox('settings');
  localLanguageNotifier.value = box.get('language', defaultValue: 'am');

  unawaited(
    (() async {
      final name = await getInformation(key: 'name');
      final phoneNumber = await getInformation(key: 'phoneNumber');
      userNameNotifier.value = name;
      phonenumberNotifier.value = phoneNumber;
    })()
        .catchError((error, stackTrace) {
      debugPrint('User profile bootstrap load failed: $error');
    }),
  );

  final prefs = await prefsFuture;
  if (shouldSkipOnboarding) {
    await prefs.setBool('setup_done', true);
    unawaited(
      _runPostLoginStartupSync(localLanguageNotifier.value)
          .catchError((error, stackTrace) {
        debugPrint('Post-login startup sync failed: $error');
      }),
    );
  }
  final setupDone = prefs.getBool('setup_done') ?? false;
  String initLocation = setupDone ? '/entrypage' : '/videointro';
  final initialNotificationRoute = await FCMService.consumeInitialLaunchRoute();
  if (initialNotificationRoute != null && initialNotificationRoute.isNotEmpty) {
    initLocation = initialNotificationRoute;
  }
  debugPrint('Resolved initial route: $initLocation');

  globalRouter = createRoute(initLocation);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) => runApp(
      MultiProvider(
        providers: [
          RepositoryProvider<QuizRepository>(
            create: (context) => QuizRepository(),
          ),
          BlocProvider(create: (context) => PersistentPlayerBloc()),
          BlocProvider<TeamBloc>(create: (context) => TeamBloc()),
          BlocProvider<VideoBloc>(create: (context) => VideoBloc()),
          BlocProvider(create: (context) => VideoPlayerBloc()),
          BlocProvider<LiveTvBloc>(
            create: (context) => LiveTvBloc(),
          ),
          BlocProvider<HighlightTvBloc>(
            create: (context) => HighlightTvBloc(),
          ),
          BlocProvider<FixtureeventBloc>(
              create: (context) => FixtureeventBloc()),
          BlocProvider<TopScorersBloc>(create: (context) => TopScorersBloc()),
          BlocProvider<TopAssistorsBloc>(
              create: (context) => TopAssistorsBloc()),
          BlocProvider<TopRedCardsBloc>(
            create: (context) => TopRedCardsBloc(),
          ),
          BlocProvider<MatchesPageBloc>(create: (context) => MatchesPageBloc()),
          BlocProvider<KnockoutBloc>(create: (context) => KnockoutBloc()),
          BlocProvider<ContentBloc>(create: (context) => ContentBloc()),
          BlocProvider<MatchStatisticsBloc>(
            create: (context) => MatchStatisticsBloc(),
          ),
          BlocProvider<HighlightsPageBloc>(
            create: (context) => HighlightsPageBloc(),
          ),
          ChangeNotifierProvider<SongModelProvider>(
            create: (_) => SongModelProvider(),
          ),
          ChangeNotifierProvider<ThemeService>(
            create: (context) => ThemeService(),
          ),
          BlocProvider<PodcastsBloc>(
            create: (context) => PodcastsBloc(),
          ),
          BlocProvider<LineupsBloc>(create: (context) => LineupsBloc()),
          BlocProvider<FavouriteplayerBloc>(
              create: (context) => FavouriteplayerBloc()),
          BlocProvider<TopYellowCardsBloc>(
              create: (context) => TopYellowCardsBloc()),
          BlocProvider<PlayerSelectionBloc>(
            create: (context) => PlayerSelectionBloc(
              storageService: globalStorageService,
            ),
          ),
          BlocProvider<FavouriteTeamBloc>(
            create: (context) => FavouriteTeamBloc(),
          ),
          BlocProvider<AvailableSeasonsBloc>(
              create: (context) => AvailableSeasonsBloc()),
          BlocProvider<NewsBloc>(create: (context) => NewsBloc()),
          BlocProvider<HeadToHeadBloc>(create: (context) => HeadToHeadBloc()),
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
          BlocProvider<FollowingBloc>(
            create: (context) => FollowingBloc(
              storageService: globalStorageService,
              analyticsService: globalAnalyticsService,
            ),
          ),
          BlocProvider<MatchBloc>(create: (context) => MatchBloc()),
        ],
        child: MyApp(initLocation: initLocation),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initLocation;
  const MyApp({super.key, required this.initLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _didScheduleAudioWarmup = false;
  bool _didScheduleLocalizationWarmup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService.flushPendingDeepLinkNavigation();
      _initDeepLinks();
      _scheduleDeferredAudioWarmup();
      _scheduleDeferredLocalizationWarmup();
      _checkInitialNotification();
    });
  }

  void _scheduleDeferredAudioWarmup() {
    if (widget.initLocation == '/videointro') {
      return;
    }

    if (_didScheduleAudioWarmup) return;
    _didScheduleAudioWarmup = true;

    final warmupDelay = widget.initLocation == '/entrypage'
        ? const Duration(milliseconds: 3200)
        : const Duration(milliseconds: 800);

    Future.delayed(warmupDelay, () {
      unawaited(
        ensureAudioHandlerReady().catchError((error, stackTrace) {
          debugPrint('Background audio handler initialization failed: $error');
        }),
      );
    });
  }

  void _scheduleDeferredLocalizationWarmup() {
    if (widget.initLocation == '/videointro') {
      return;
    }

    if (_didScheduleLocalizationWarmup) return;
    _didScheduleLocalizationWarmup = true;

    Future.delayed(const Duration(milliseconds: 2200), () {
      unawaited(
        preloadLocalizationsPrioritized(
          primaryLanguageCode: localLanguageNotifier.value,
        ).catchError((error, stackTrace) {
          debugPrint('Background localization preload failed: $error');
        }),
      );
    });
  }

  // âœ… NEW: Check for initial notification from awesome_notifications
  Future<void> _checkInitialNotification() async {
    if (mounted) {
      await FCMService.checkInitialNotificationAction();
      await FCMService().checkInitialFcmLaunchMessage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      globalAnalyticsService
          .trackAppLifecycle(state: state)
          .catchError((error, stackTrace) {
        debugPrint('Lifecycle analytics tracking failed: $error');
      }),
    );
    if (state == AppLifecycleState.resumed) {
      _updateSystemUIAfterBuild();
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint(
            'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');
        debugPrint('ðŸ”— DEEP LINK RECEIVED (App Running)');
        debugPrint('   URI: $uri');
        debugPrint(
            'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');

        _handleDeepLink(uri);
      },
      onError: (Object err) {
        debugPrint('âŒ Deep link stream error: $err');
      },
    );

    // Handle initial link (cold start via deep link, not notification)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint(
            'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');
        debugPrint('ðŸš€ INITIAL DEEP LINK DETECTED (Cold Start)');
        debugPrint('   URI: $initialUri');
        debugPrint(
            'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•');

        // Process after a delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _handleDeepLink(initialUri);
            }
          });
        });
      }
    } catch (e) {
      debugPrint('âŒ Failed to get initial deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    try {
      final hostLower = uri.host.toLowerCase();
      final queryParams = uri.queryParameters;
      final pathSegments = uri.pathSegments;

      debugPrint('ðŸ§­ Processing deep link');
      debugPrint('   Host: $hostLower');
      debugPrint('   Path segments: $pathSegments');
      debugPrint('   Query: $queryParams');

      if (hostLower == 'matchdetail') {
        final fixtureId = queryParams['fixtureId']?.trim();
        if (fixtureId != null && fixtureId.isNotEmpty) {
          debugPrint('â†’ Navigating to match detail: fixtureId=$fixtureId');
          globalRouter.go('/matchDetail?fixtureId=$fixtureId');
          return;
        }
      } else if (hostLower == 'newsdetail') {
        final newsId = pathSegments.isNotEmpty ? pathSegments.last : null;
        final lang = queryParams['lang']?.trim();

        if (newsId != null && newsId.isNotEmpty) {
          if (lang != null && lang.isNotEmpty) {
            localLanguageNotifier.value = lang;
            debugPrint('â†’ Language set to: $lang');
          }
          debugPrint('â†’ Navigating to news detail: newsId=$newsId');
          globalRouter.go('/newsDetail/$newsId');
          return;
        }
      } else if (hostLower == 'podcast') {
        final podcastId = pathSegments.isNotEmpty ? pathSegments.last : null;
        if (podcastId != null && podcastId.isNotEmpty) {
          debugPrint('â†’ Navigating to podcast: id=$podcastId');
          globalRouter.go('/podcast/$podcastId', extra: queryParams);
          return;
        }
      }

      debugPrint('âš ï¸ Unknown deep link format â†’ ignoring');
      return;
    } catch (e, stack) {
      debugPrint('âŒ Deep link handling failed: $e');
      debugPrint('Stack: $stack');
      return;
    }
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
                builder: (context, child) => child!,
              ),
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}
