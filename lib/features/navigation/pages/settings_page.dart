import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/Homepage.dart';
import 'package:blogapp/features/navigation/pages/themeprovider.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/services/fcm_service.dart';

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
    final headers = await buildAuthHeaders();
    await http.post(
      Uri.parse('$url/api/authentication/languageupdate'),
      body: json.encode({'language': lang}),
      headers: headers,
    );
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
  HapticFeedback.mediumImpact();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final availableLanguages = {
        'am': {'name': 'አማርኛ', 'english': 'Amharic'},
        'or': {'name': 'Afaan Oromoo', 'english': 'Oromo'},
        'tr': {'name': 'ትግርኛ', 'english': 'Tigrinya'},
        'so': {'name': 'Af-Soomaali', 'english': 'Somali'},
        'en': {'name': 'English', 'english': 'English'},
      };

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Minimal Drag Handle ---
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              width: 35.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Text(
              DemoLocalizations.language,
              style: TextUtils.setTextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 20.h),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.h),
                itemCount: availableLanguages.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final entry = availableLanguages.entries.elementAt(index);
                  final isSelected = lang == entry.key;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colorscontainer.greenColor.withOpacity(0.1) 
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? Colorscontainer.greenColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        _handleLanguageUpdate(entry.key); // Same logic as your original snippet
                      },
                      // --- Minimalist Text Avatar ---
                      leading: Container(
                        width: 42.w,
                        height: 42.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colorscontainer.greenColor : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          entry.value['name']!.substring(0, 1),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextUtils.setTextStyle(
                          fontSize: 16.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        entry.value['english']!,
                        style: TextUtils.setTextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      trailing: isSelected 
                        ? Icon(Icons.check_circle_rounded, color: Colorscontainer.greenColor, size: 22.sp)
                        : null,
                    ),
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
    final Uri url = Uri.parse('https://testa.et/app/help-center');
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch help center')),
      );
    }
  }
  
Future<void> _handleLanguageUpdate(String langCode) async {
  // 1. Capture context before async gaps
  final settingsPageContext = context;
  final oldLang = lang; // This refers to your existing 'lang' variable

  // 2. Immediate UI Feedback
  setState(() {
    lang = langCode;
  });
  localLanguageNotifier.value = langCode;

  // 3. Close the bottom sheet
  Navigator.pop(context);

  try {
    // 4. Run all background updates
    await Future.wait([
      storeLanguage(langCode),
      _saveSelectedradiovalue(langCode),
      _getselectedlang(langCode),
      fetchLocalizationValues(langCode),
    ]);

    // 5. Update FCM Subscriptions
    debugPrint('🌍 Updating FCM: $oldLang → $langCode');
    await FCMTopicManager.updateLanguageSubscriptions(
      oldLanguageCode: oldLang,
      newLanguageCode: langCode,
    );

    // 6. No navigation needed; UI reacts to localLanguageNotifier updates.
  } catch (e) {
    // 7. Error Handling
    if (settingsPageContext.mounted) {
      ScaffoldMessenger.of(settingsPageContext).showSnackBar(
        SnackBar(
          content: Text('Failed to update language: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}}
