import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/services/fcm_service.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool allEnabled = true;
  Map<String, bool> settings = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Map<String, bool> settingsData = {
    'Started': true,
    'Half time': true,
    'Full time': true,
    'Goals': true,
    'Red cards': true,
    'Missed penalty': true,
    'lineup': true,
    'Match reminder': true,
    'Substitution': true,
    'Vibration': true,
    'Sound': true,
    'Breaking News': true,
    'Official Highlights': true,
    'Podcasts': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      settingsData.forEach((key, _) {
        settings[key] = prefs.getBool(key) ?? true;
      });
      
      // Update master toggle based on actual settings
      allEnabled = _areAllSettingsEnabled();
    });
  }

  bool _areAllSettingsEnabled() {
    return settings.values.every((value) => value == true);
  }

  Future<void> _saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget _buildSettingsSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Text(
            title,
            style: TextUtils.setTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: items
                .map((item) => _buildSettingTile(
                      icon: item['icon'],
                      title: item['title'],
                      settingKey: item['key'],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String settingKey,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon,
                    color: Theme.of(context).colorScheme.primary, size: 22.r),
              ),
              title: Text(
                title,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: settings[settingKey] ?? true,
                  onChanged: (value) async {
                    setState(() {
                      settings[settingKey] = value;
                      // Update master toggle after changing individual setting
                      allEnabled = _areAllSettingsEnabled();
                    });
                    
                    await _saveSettings(settingKey, value);

                    final lang = localLanguageNotifier.value;

                    // Handle Breaking News subscription
                    if (settingKey == 'Breaking News') {
                      await FCMTopicManager.updateBreakingNewsSubscription(
                        languageCode: lang,
                        isEnabled: value,
                      );
                    }
                    // Note: Match event settings are stored in SharedPreferences
                    // and used as filters when showing notifications for subscribed matches.
                    // Actual match subscriptions happen on the matches page when user
                    // subscribes to a specific fixture.
                    
                    // Note: 'Podcasts' is handled locally via SharedPreferences filtering
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            Theme.of(context).colorScheme.surface.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DemoLocalizations.notification,
                      style: TextUtils.setTextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DemoLocalizations.notificationsDesc,
                      style: TextUtils.setTextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DemoLocalizations.notificationsEnabled,
                  style: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DemoLocalizations.all,
                  style: TextUtils.setTextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: allEnabled,
            onChanged: (value) async {
              setState(() {
                allEnabled = value;
                // Update all individual settings
                settings.forEach((key, _) {
                  settings[key] = value;
                });
              });

              final lang = localLanguageNotifier.value;

              // Save all settings to SharedPreferences
              for (final entry in settings.entries) {
                await _saveSettings(entry.key, value);
              }

              // Update Breaking News subscription
              await FCMTopicManager.updateBreakingNewsSubscription(
                languageCode: lang,
                isEnabled: value,
              );

              debugPrint('✅ Master toggle: ${value ? "enabled" : "disabled"}');
              
              // Note: Match event settings are stored in SharedPreferences.
              // These act as filters for notifications from matches the user
              // has specifically subscribed to on the matches page.
            },
            activeColor: Theme.of(context).colorScheme.primary,
            activeTrackColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Center(
          child: Text(
            DemoLocalizations.done,
            style: TextUtils.setTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> settingsSections = [
    {
      'title': DemoLocalizations.type,
      'items': [
        {
          'icon': Icons.volume_up,
          'title': DemoLocalizations.sound,
          'key': 'Sound'
        },
        {
          'icon': Icons.vibration,
          'title': DemoLocalizations.vibration,
          'key': 'Vibration'
        },
      ],
    },
    {
      'title': DemoLocalizations.news,
      'items': [
        {
          'icon': Icons.flash_on,
          'title': DemoLocalizations.breakingNews,
          'key': 'Breaking News'
        },
      ],
    },
    {
      'title': DemoLocalizations.liveScore,
      'items': [
        {
          'icon': Icons.timer_outlined,
          'title': DemoLocalizations.matchStarted,
          'key': 'Started'
        },
        {
          'icon': Icons.av_timer_outlined,
          'title': DemoLocalizations.breakTime,
          'key': 'Half time'
        },
        {
          'icon': Icons.timer_rounded,
          'title': DemoLocalizations.matchEnded,
          'key': 'Full time'
        },
        {
          'icon': Icons.sports_soccer_outlined,
          'title': DemoLocalizations.goal,
          'key': 'Goals'
        },
        {
          'icon': Icons.card_membership,
          'title': DemoLocalizations.redCard,
          'key': 'Red cards'
        },
        {
          'icon': Icons.sports_soccer,
          'title': DemoLocalizations.missedPenality,
          'key': 'Missed penalty'
        },
        {
          'icon': Icons.people_outline,
          'title': DemoLocalizations.lineUp,
          'key': 'lineup'
        },
        {
          'icon': Icons.notifications_active_outlined,
          'title': DemoLocalizations.matchReminder,
          'key': 'Match reminder'
        },
        {
          'icon': Icons.swap_horiz,
          'title': DemoLocalizations.subst,
          'key': 'Substitution'
        }, 
        {
          'icon': Icons.video_library_outlined,
          'title': DemoLocalizations.highlight,
          'key': 'Official Highlights'
        },
      ],
    },
    {
      'title': DemoLocalizations.listen,
      'items': [
        {
          'icon': Icons.podcasts,
          'title': DemoLocalizations.listen,
          'key': 'Podcasts'
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                children: [
                  _buildMasterToggle(),
                  SizedBox(height: 24.h),
                  ...settingsSections.map(
                    (section) => _buildSettingsSection(
                      section['title'],
                      List<Map<String, dynamic>>.from(section['items']),
                    ),
                  ),
                ],
              ),
            ),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}