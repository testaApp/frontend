import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/routenames.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import '../../Homepage.dart';
import 'themeprovider.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';
import '../../services/fcm_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String mode = '0';
  String lang = '0';

  Future<void> storeLanguage(String value) async {
    var box = await Hive.openBox('settings');
    await box.put('language', value);
  }

  Future<void> _saveSelectedradiovalue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', value);
    await fetchLocalizationValues(value);
  }

  Future<String> _getSelectedradiovalue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang') ?? '0';
  }

  Future<void> _getselectedlang(String lang) async {
    String url = BaseUrl().url;
    String accesstoken = await getAccessToken();
    await http.post(Uri.parse('$url/api/authentication/languageupdate'),
        body: json.encode({'language': lang}),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': accesstoken
        });
  }

  PackageInfo packageInfo = PackageInfo(
    version: 'Unknown',
    buildNumber: 'Unknown',
    packageName: 'Unknown',
    appName: 'testa',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _getSelectedradiovalue().then((value) {
      setState(() {
        lang = value;
      });
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.h,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colorscontainer.greenColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor:
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.only(bottom: 16.h),
              title: Text(
                DemoLocalizations.settings,
                style: TextUtils.setTextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colorscontainer.greenColor.withOpacity(0.1),
                      Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DemoLocalizations.settingsDesc,
                    style: TextUtils.setTextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSettingsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            title: DemoLocalizations.theme,
            icon: Icons.palette_outlined,
            onTap: () => _showThemeBottomSheet(),
            subtitle: DemoLocalizations.theme,
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: DemoLocalizations.language,
            icon: Icons.language,
            onTap: () => _showLanguageBottomSheet(),
            subtitle: DemoLocalizations.languageSetting,
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: DemoLocalizations.notification,
            icon: Icons.notifications_outlined,
            onTap: () => context.pushNamed(RouteNames.notificationSettings),
            subtitle: DemoLocalizations.notificationsDesc,
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: 'Terms and Conditions',
            icon: Icons.description_outlined,
            onTap: () async {
              final Uri url =
                  Uri.parse('https://testa.et/app/privacy-terms-conditions');
              if (!await launchUrl(url)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch the website')),
                );
              }
            },
            subtitle: DemoLocalizations.terms_conditions_agreement,
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: DemoLocalizations.contactUs,
            icon: Icons.help_outline,
            onTap: () => _launchHelpCenter(),
            subtitle: DemoLocalizations.contactUsDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    IconData? icon,
    String? image,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colorscontainer.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: image != null
                  ? Image.asset(
                      image,
                      width: 24.sp,
                      height: 24.sp,
                    )
                  : Icon(
                      icon,
                      color: Colorscontainer.greenColor,
                      size: 24.sp,
                    ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextUtils.setTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextUtils.setTextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1,
        color: Theme.of(context).dividerColor.withOpacity(0.1),
      ),
    );
  }

  void _showThemeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.light_mode_outlined),
                  title: const Text('Light'),
                  trailing: themeService.themeMode == ThemeMode.light
                      ? Icon(Icons.check, color: Colorscontainer.greenColor)
                      : null,
                  onTap: () {
                    themeService.setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark'),
                  trailing: themeService.themeMode == ThemeMode.dark
                      ? Icon(Icons.check, color: Colorscontainer.greenColor)
                      : null,
                  onTap: () {
                    themeService.setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('System'),
                  trailing: themeService.themeMode == ThemeMode.system
                      ? Icon(Icons.check, color: Colorscontainer.greenColor)
                      : null,
                  onTap: () {
                    themeService.setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final availableLanguages = {
          'am': {
            'name': 'አማርኛ',
            'english': 'Amharic',
            'icon': 'assets/ETHIOPIC_SYLLABLE_GLOTTAL_A.svg.png',
            'available': true
          },
          'or': {
            'name': 'Afaan Oromoo',
            'english': 'Oromo',
            'icon': 'assets/Gadaa_flag.svg.png',
            'available': true
          },
          'tr': {
            'name': 'ትግርኛ',
            'english': 'Tigrinya',
            'icon': 'assets/tigrigna-bg.png',
            'available': true
          },
          'so': {
            'name': 'Af-Soomaali',
            'english': 'Somali',
            'icon': 'assets/Camel_somali.png',
            'available': true
          },
          'en': {
            'name': 'English',
            'english': 'English',
            'icon': 'assets/English_language.png',
            'available': true
          },
        };

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  DemoLocalizations.language,
                  style: TextUtils.setTextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16.h,
                  ),
                  itemCount: availableLanguages.length,
                  itemBuilder: (context, index) {
                    final entry = availableLanguages.entries.elementAt(index);
                    final isAvailable = entry.value['available'] as bool;

                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colorscontainer.greenColor.withOpacity(0.1),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                entry.value['icon'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.language,
                                    color: Colorscontainer.greenColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            entry.value['name'] as String,
                            style: TextUtils.setTextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            entry.value['english'] as String,
                            style: TextUtils.setTextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          trailing: isAvailable
                              ? (lang == entry.key
                                  ? Icon(Icons.check_circle,
                                      color: Colorscontainer.greenColor)
                                  : null)
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colorscontainer.greenColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'Coming Soon',
                                    style: TextUtils.setTextStyle(
                                      fontSize: 10.sp,
                                      color: Colorscontainer.greenColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                          onTap: () async {
                            if (!isAvailable) return;

                            if (lang == entry.key) {
                              Navigator.pop(
                                  context); // Same language, just close
                              return;
                            }

                            // Capture the SettingsPage context (this one stays valid)
                            final settingsPageContext = context;
                            final oldLang = lang; // Store old language

                            // Optimistically update UI
                            setState(() {
                              lang = entry.key;
                            });
                            localLanguageNotifier.value = entry.key;

                            // Close bottom sheet immediately
                            Navigator.pop(context);

                            // Perform all async operations
                            try {
                              await Future.wait([
                                storeLanguage(entry.key),
                                _saveSelectedradiovalue(entry.key),
                                _getselectedlang(entry.key),
                                fetchLocalizationValues(entry.key),
                              ]);

                              // CRITICAL FIX: Update FCM subscriptions for language change
                              // This will properly unsubscribe from old language topics
                              // and subscribe to new language topics
                              debugPrint('🌍 Updating FCM subscriptions: $oldLang → ${entry.key}');
                              await FCMTopicManager.updateLanguageSubscriptions(
                                oldLanguageCode: oldLang,
                                newLanguageCode: entry.key,
                              );

                              // Navigate to home only if SettingsPage is still mounted
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  settingsPageContext,
                                  MaterialPageRoute(
                                      builder: (_) => const NewsHomeScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              // Show error ONLY if SettingsPage is still on screen
                              if (settingsPageContext.mounted) {
                                ScaffoldMessenger.of(settingsPageContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Failed to update language: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        if (entry.key != availableLanguages.keys.last)
                          const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchHelpCenter() async {
    final Uri url = Uri.parse('https://your-help-center-url.com');
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch help center')),
      );
    }
  }
}