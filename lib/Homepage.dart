import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_open_app_settings/flutter_open_app_settings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;

import 'application/persistent_player/persistent_player_bloc.dart';
import 'application/persistent_player/persistent_player_state.dart';
import 'localization/demo_localization.dart';
import 'main.dart';
import 'notifications/notifier.dart';
import 'pages/appbar_pages/enadamt/enadamt_new.dart';
import 'pages/appbar_pages/enadamt/live_audio_player.dart';
import 'pages/appbar_pages/news/foryou/foryou.dart';
import 'pages/appbar_pages/news/main_news/news_feed.dart';
import 'pages/bottom_navigation/matches/matches.dart';
import 'pages/bottom_navigation/standing/standings_page.dart';
import 'pages/bottom_navigation/Tv/tv.dart';
import 'pages/constants/colors.dart';
import 'pages/constants/text_utils.dart';
import 'pages/navigation/navigation_draw.dart';
import 'presentation/userPreferencesPage.dart';

import 'pages/appbar_pages/custom_app_bar.dart';
import 'services/fcm_service.dart';

class NewsHomeScreen extends StatefulWidget {
  const NewsHomeScreen({super.key});

  @override
  State<NewsHomeScreen> createState() => _NewsHomeScreenState();
}

class _NewsHomeScreenState extends State<NewsHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late PageController _pageController;
  late TabController _tabController;
  late Map<int, bool> _loadedTabs;

  // SharedPreferences keys
  static const String _keyNotificationAsked = 'notification_permission_asked';
  static const String _keyNotificationDeclinedTime = 'notification_declined_time';
  static const int _daysBeforeAskingAgain = 2; // Ask again after 2 days if declined

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadedTabs = {0: true, 1: false, 2: false};

    _tabController.addListener(() {
      if (!_loadedTabs[_tabController.index]!) {
        setState(() {
          _loadedTabs[_tabController.index] = true;
        });
      }
    });

    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addObserver(this);
    
    // Request permission after first frame - but only if we haven't asked before
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        await _requestFCMPermissionIfNeeded();
      });
    });
  }

  Future<void> _registerFcmTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastKnownToken = prefs.getString('last_fcm_token');

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('⚠️ No FCM token available');
        return;
      }

      if (token != lastKnownToken) {
        // Token is new or changed → register it
        await FCMService().requestPermissionAndRegisterToken();
        await prefs.setString('last_fcm_token', token);
        debugPrint('✅ FCM token registered (new/changed): $token');
      } else {
        debugPrint('ℹ️ FCM token unchanged — skipping registration');
      }
    } catch (e) {
      debugPrint('⚠️ FCM token handling failed: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _checkAndRegisterFCMAfterSettingsReturn();
    }
  }

  Future<void> _checkAndRegisterFCMAfterSettingsReturn() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerFcmTokenIfNeeded();
      debugPrint('✅ FCM registered after returning from settings (if needed)');
    } else {
      debugPrint('ℹ️ Still not authorized after settings visit');
    }
  }

  Future<bool> _shouldAskForPermission() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we've already asked
    final hasAsked = prefs.getBool(_keyNotificationAsked) ?? false;
    
    if (!hasAsked) {
      // Never asked before - we should ask
      return true;
    }
    
    // Check if user declined and if enough time has passed
    final declinedTime = prefs.getInt(_keyNotificationDeclinedTime);
    if (declinedTime != null) {
      final declinedDate = DateTime.fromMillisecondsSinceEpoch(declinedTime);
      final daysSinceDeclined = DateTime.now().difference(declinedDate).inDays;
      
      if (daysSinceDeclined >= _daysBeforeAskingAgain) {
        // It's been long enough, ask again
        return true;
      }
    }
    
    // We've asked before and not enough time has passed
    return false;
  }

  Future<void> _markPermissionAsked({bool wasDeclined = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationAsked, true);
    
    if (wasDeclined) {
      await prefs.setInt(_keyNotificationDeclinedTime, DateTime.now().millisecondsSinceEpoch);
    } else {
      // User accepted, remove the declined timestamp
      await prefs.remove(_keyNotificationDeclinedTime);
    }
  }

  Future<void> _requestFCMPermissionIfNeeded() async {
    // Get current notification settings
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    // If already authorized, just register the token if needed
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerFcmTokenIfNeeded();
      return;
    }

    // Check if we should ask for permission based on our stored preferences
    final shouldAsk = await _shouldAskForPermission();
    if (!shouldAsk) {
      debugPrint('⏭️ Skipping notification permission request (already asked recently)');
      return;
    }

    // If permission is denied, notDetermined, or provisional, show our custom dialog
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      final currentContext = context;
      if (!mounted) return;

      // Show dialog asking user to enable notifications
      final userWants = await showGeneralDialog<bool>(
        context: currentContext,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(165),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionBuilder: (context, animation, _, __) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).transform(Curves.easeOutCubic.transform(animation.value));

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          final backgroundColor = theme.dialogTheme.backgroundColor ??
              (isDark ? Colors.black : Colors.white);

          final titleColor = theme.textTheme.titleLarge?.color ??
              (isDark ? Colors.white : Colors.black);

          final bodyColor = (theme.textTheme.bodyMedium?.color ??
                  (isDark ? Colors.white : Colors.black))
              .withAlpha((isDark ? 165 : 204).toInt());

          final secondaryColor = (theme.textTheme.bodyMedium?.color ??
                  (isDark ? Colors.white : Colors.black))
              .withAlpha((isDark ? 128 : 153).toInt());

          return Transform.translate(
            offset: Offset(0, slide.dy * 100),
            child: Opacity(
              opacity: animation.value,
              child: Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        size: 28,
                        color: Colorscontainer.greenColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        DemoLocalizations.notification_title,
                        style: TextUtils.setTextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: titleColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DemoLocalizations.notification_body,
                        style: TextUtils.setTextStyle(
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: bodyColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colorscontainer.greenColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            DemoLocalizations.notification_enable,
                            style: TextUtils.setTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isDark ? Colors.black : Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, false),
                          child: Text(
                            DemoLocalizations.notification_not_now,
                            style: TextUtils.setTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      // Handle user's choice
      if (userWants == true) {
        await _markPermissionAsked(wasDeclined: false);

        debugPrint('🟢 User wants notifications — proceeding');

        // Try to request permission
        NotificationSettings? result;

        try {
          debugPrint('🔔 Attempting to show system permission dialog');
          result = await FirebaseMessaging.instance.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

          debugPrint('📋 System permission result: ${result.authorizationStatus}');
        } catch (e) {
          debugPrint('⚠️ requestPermission() failed: $e');
        }

        // Check final status after the request attempt
        final finalSettings = await FirebaseMessaging.instance.getNotificationSettings();

        if (finalSettings.authorizationStatus == AuthorizationStatus.authorized) {
          // Success — register token smartly
          await _registerFcmTokenIfNeeded();
        } 
        else if (finalSettings.authorizationStatus == AuthorizationStatus.denied) {
          // Still denied after request → guide to settings
          debugPrint('📱 Permission is denied → opening app settings');
          if (defaultTargetPlatform == TargetPlatform.android) {
            await FlutterOpenAppSettings.openAppsSettings(
              settingsCode: SettingsCode.NOTIFICATION,
            );
            debugPrint('📱 Opened Android app-specific notification settings');
          } else {
            await AppSettings.openAppSettings();
            debugPrint('📱 Opened iOS / other platform app settings');
          }
        } 
        else {
          debugPrint('ℹ️ Permission in another state: ${finalSettings.authorizationStatus}');
        }
      } 
      else if (userWants == false) {
        debugPrint('❌ User explicitly declined');
        await _markPermissionAsked(wasDeclined: true);
      } 
      else {
        debugPrint('⏭️ Dialog dismissed');
        await _markPermissionAsked(wasDeclined: true);
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: localLanguageNotifier,
        builder: (context, language, child) {
          return Scaffold(
            drawer: const Offcanvas(),
            appBar: CustomAppBar(
              tabController: _tabController,
              onTabTapped: (index) {
                _pageController.jumpToPage(index);
              },
            ),
            body: SafeArea(
              top: false,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _tabController.animateTo(index);
                  });
                },
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTabContent(
                      0, const Newsfeed(key: PageStorageKey('newsfeed'))),
                  _buildTabContent(
                      1, const ForYouScreen(key: PageStorageKey('foryou'))),
                  _buildTabContent(
                      2, const EnadamtNew(key: PageStorageKey('enadamt'))),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTabContent(int index, Widget child) {
    if (!_loadedTabs[index]!) {
      return const Center(child: CircularProgressIndicator());
    }
    return child;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;

  Widget? newsScreen;
  Widget? standingPage;
  Widget? matchesPage;
  Widget? userPreferencesPage;
  Widget? highlightsPage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _buildCurrentScreen(),
                ),
                BlocBuilder<PersistentPlayerBloc, PersistentPlayerState>(
                  builder: (context, state) {
                    if (state.status == PersistentPlayerStatus.hidden) {
                      return const SizedBox.shrink();
                    }

                    return LiveAudioPlayer(
                      avatar: state.avatar,
                      name: state.name,
                      station: state.station,
                      program: state.program,
                      liveLink: state.liveLink,
                    );
                  },
                ),
                ValueListenableBuilder<String>(
                  valueListenable: localLanguageNotifier,
                  builder: (context, language, child) {
                    return CustomBottomNavBar(
                      currentIndex: currentTab,
                      onTap: (index) {
                        setState(() {
                          currentTab = index;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentTab) {
      case 0:
        newsScreen ??= const NewsHomeScreen();
        return newsScreen!;
      case 1:
        standingPage ??= const StandingPage();
        return standingPage!;
      case 2:
        matchesPage ??= const MatchesPage();
        return matchesPage!;
      case 3:
        userPreferencesPage ??= const UserPreferencesPage();
        return userPreferencesPage!;
      case 4:
        highlightsPage ??= const Tv();
        return highlightsPage!;
      default:
        return const SizedBox.shrink();
    }
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        boxShadow: const [],
        border: const Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, CupertinoIcons.sportscourt,
              DemoLocalizations.homepage, 0),
          _buildNavItemWithSvg(
              context, 'assets/trophy.svg', DemoLocalizations.leagues, 1),
          _buildNavItem(
              context, Icons.scoreboard_rounded, DemoLocalizations.games, 2),
          _buildNavItem(context, CupertinoIcons.heart_fill,
              DemoLocalizations.favourite, 3),
          _buildNavItem(
              context, CupertinoIcons.tv_fill, DemoLocalizations.video, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: isSelected
                ? Colorscontainer.greenColor
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colorscontainer.greenColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithSvg(
      BuildContext context, String svgPath, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            height: 19.h,
            width: 20.w,
            color: isSelected
                ? Colorscontainer.greenColor
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          Text(
            label,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colorscontainer.greenColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedTabIndicator extends Decoration {
  final BoxPainter _painter;

  RoundedTabIndicator(
      {required Color color, required double radius, required double weight})
      : _painter = _RoundedLinePainter(color, radius, weight);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RoundedLinePainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double weight;

  _RoundedLinePainter(Color color, this.radius, this.weight)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final Rect indicatorRect = Rect.fromLTRB(
      rect.left,
      rect.bottom - weight,
      rect.right,
      rect.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(indicatorRect, Radius.circular(radius)),
      _paint,
    );
  }
}