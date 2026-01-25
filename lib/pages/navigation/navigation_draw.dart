import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../components/routenames.dart';
import '../../localization/demo_localization.dart';
import '../../main.dart';
import 'themeprovider.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../../util/notifiers/username_notifier.dart';
import '../appbar_pages/news/saved_news.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';
import '../login/image_selector.dart';
import '../login/login.dart';
import '../login/profile.dart';
import 'quiz/quiz.dart';
import 'user_notifications.dart';

class Offcanvas extends StatefulWidget {
  const Offcanvas({super.key});

  @override
  State<Offcanvas> createState() => _OffcanvasState();
}

class _OffcanvasState extends State<Offcanvas> {
  String lang = '0';
  PackageInfo packageInfo = PackageInfo(
    version: 'Unknown',
    buildNumber: 'Unknown',
    packageName: 'Unknown',
    appName: 'Testa',
  );
  final Map<String, LottieComposition> _cachedAnimations = {};

  Future<String> _getSelectedradiovalue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang') ?? '0';
  }

  @override
  void initState() {
    super.initState();
    _getSelectedradiovalue().then((value) {
      setState(() {
        lang = value;
      });
    });
    _initPackageInfo();
    _precacheAnimations();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        packageInfo = info;
      });
    } catch (e) {
      print('Error getting package info: $e');
    }
  }

  Future<void> _precacheAnimations() async {
    final animationPaths = [
      'assets/transfer.json',
      'assets/user_notification.json',
      'assets/quiz.json',
      'assets/saved_news.json',
      'assets/gebeya.json',
      'assets/settings.json',
      'assets/share_app.json',
      'assets/rate_us.json'
    ];

    for (final path in animationPaths) {
      try {
        final composition = await AssetLottie(path).load();
        _cachedAnimations[path] = composition;
      } catch (e) {
        print('Error precaching animation $path: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Consumer<ThemeService>(
          builder: (context, themeProvider, child) {
            return ValueListenableBuilder(
              valueListenable: localLanguageNotifier,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        const HeaderWidget(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10.w, 0, 0, 60.w),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    context,
                                    'assets/transfer.json',
                                    true,
                                    DemoLocalizations.transfer_window,
                                    DemoLocalizations.transferWindowDesc,
                                    () =>
                                        context.pushNamed(RouteNames.transfer),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/user_notification.json',
                                    true,
                                    DemoLocalizations.notification,
                                    DemoLocalizations.notificationsDesc,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsPage()),
                                    ),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/quiz.json',
                                    true,
                                    DemoLocalizations.dailyQuizChallenge,
                                    DemoLocalizations.dailyQuizDesc,
                                    () => _handleQuizNavigation(context),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/saved_news.json',
                                    true,
                                    DemoLocalizations.saved_news,
                                    DemoLocalizations.savedNewsDesc,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SavedNewsPage()),
                                    ),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/gebeya.json',
                                    true,
                                    DemoLocalizations.testaMarket,
                                    DemoLocalizations.testaMarketDesc,
                                    // --- MODIFIED ACTION BELOW ---
                                    () async {
                                      const String urlString =
                                          'https://testa.et/gebeya';
                                      final Uri url = Uri.parse(urlString);

                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        // Use ScaffoldMessenger for error handling
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Could not launch $urlString'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/settings.json',
                                    true,
                                    DemoLocalizations.settings,
                                    DemoLocalizations.settingsDesc,
                                    () =>
                                        context.pushNamed(RouteNames.settings),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/share_app.json',
                                    true,
                                    DemoLocalizations.shareApp,
                                    DemoLocalizations.shareAppDesc,
                                    () => Share.share(
                                        'https://testa.et/shareapp'),
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/rate_us.json',
                                    true,
                                    DemoLocalizations.rateUs,
                                    DemoLocalizations.rateUsDesc,
                                    _launchURL,
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'assets/sileegna.png',
                                    false,
                                    DemoLocalizations.aboutUs,
                                    DemoLocalizations.aboutUsDesc,
                                    () async {
                                      final Uri url = Uri.parse(
                                          'https://testa.et/about-us');
                                      if (!await launchUrl(url)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not launch the website')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/sileegna.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'testa app',
                                  style: TextUtils.setTextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Version ${packageInfo.version}',
                                  style: TextUtils.setTextStyle(
                                    fontSize: 10.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showContactOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Contact Options',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                ContactOptionTile(
                  icon: Icons.call,
                  label: 'Call Us',
                  onTap: () {
                    // TODO: Implement logic to initiate a call
                    print('Calling...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: Icons.email,
                  label: 'Email Us',
                  onTap: () {
                    // TODO: Implement logic to send an email
                    print('Sending email...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    // TODO: Implement logic to open Facebook page
                    print('Opening Facebook page...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: FontAwesomeIcons.twitter,
                  label: 'Twitter',
                  onTap: () {
                    // TODO: Implement logic to open Twitter page
                    print('Opening Twitter page...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  onTap: () {
                    // TODO: Implement logic to open WhatsApp chat
                    print('Opening WhatsApp chat...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: FontAwesomeIcons.instagram,
                  label: 'Instagram',
                  onTap: () {
                    // TODO: Implement logic to open Instagram page
                    print('Opening Instagram page...');
                    Navigator.of(context).pop();
                  },
                ),
                ContactOptionTile(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  onTap: () {
                    // TODO: Implement logic to open Telegram chat
                    print('Opening Telegram chat...');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String imagePath,
    bool isLottie,
    String title,
    String descriptionKey,
    Function() onTap,
  ) {
    return ListTile(
      leading: SizedBox(
        width: 30.w,
        height: 30.h,
        child: isLottie
            ? _cachedAnimations.containsKey(imagePath)
                ? Lottie(
                    composition: _cachedAnimations[imagePath],
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.colorFilter(
                          const ['**'],
                          value: ColorFilter.mode(
                            Colorscontainer.greenColor,
                            BlendMode.srcATop,
                          ),
                        ),
                      ],
                    ),
                  )
                : Lottie.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.colorFilter(
                          const ['**'],
                          value: ColorFilter.mode(
                            Colorscontainer.greenColor,
                            BlendMode.srcATop,
                          ),
                        ),
                      ],
                    ),
                  )
            : Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
      ),
      title: Text(
        title,
        style: TextUtils.setTextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15.sp,
        ),
      ),
      subtitle: Text(
        descriptionKey,
        style: TextUtils.setTextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 11.sp,
          fontWeight: FontWeight.w300,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactUsItem(
      BuildContext context, String type, String icon, String contactInfo) {
    return ListTile(
      leading: Image.asset(
        'assets/$icon',
        width: 20.h,
        height: 20.h,
      ),
      title: Text(contactInfo),
      onTap: () async {
        if (type == 'Email') {
          var url = 'support@testa.et';
          if (!await launchUrl(Uri(scheme: 'mailto', path: 'support@testa.et'),
              mode: LaunchMode.platformDefault)) {
            throw Exception('Could not launch $url');
          }
        } else if (type == 'Phone') {
          final Uri launchUri = Uri(scheme: 'tel', path: contactInfo);
          await launchUrl(launchUri);
        }
      },
    );
  }

  void _handleQuizNavigation(BuildContext context) {
    if (userNameNotifier.value != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DailyQuizPage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => _buildAuthDialog(context),
      );
    }
  }

  Widget _buildAuthDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Lock Icon Container
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colorscontainer.greenColor.withOpacity(0.2),
                    Colorscontainer.greenColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      color: Colorscontainer.greenColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 40.w,
                    color: Colorscontainer.greenColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Title with custom styling
            Text(
              'Authentication Required',
              style: TextUtils.setTextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),

            // Description text
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Join our community of quiz enthusiasts! Sign up now to participate in daily challenges, compete with other players, and track your progress.',
                textAlign: TextAlign.center,
                style: TextUtils.setTextStyle(
                  fontSize: 16.sp,
                  height: 1.4,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colorscontainer.greenColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Up Now',
                      style: TextUtils.setTextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Additional Info Text
            SizedBox(height: 16.h),
            Text(
              'It only takes a minute!',
              style: TextUtils.setTextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ContactOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      tileColor: Colors.grey[800],
    );
  }
}

Future<void> _launchURL() async {
  final Uri url = Uri.parse('https://testa.et/appranking');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  Uint8List? _imageData;
  Uint8List? _cachedImageData;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadCachedImage();
    _loadPhoneNumber();
  }

  Future<void> _loadCachedImage() async {
    _cachedImageData = await getCachedImageData();
    if (_cachedImageData != null) {
      setState(() {});
    }
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = prefs.getString('phone') ?? 'Unknown';
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      await _cacheImageData(imageData);
      setState(() {
        _imageData = imageData;
      });

      // Upload the image in the background
      _uploadImage(pickedFile);
    }
  }

  Future<void> _cacheImageData(Uint8List imageData) async {
    final prefs = await SharedPreferences.getInstance();
    String encodedImage = base64Encode(imageData);
    await prefs.setString('cachedImageData', encodedImage);
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    String url = BaseUrl().url;
    var uri = Uri.parse('$url/api/user/uploadImage');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', pickedFile.path));
    request.headers['accesstoken'] = await getAccessToken();

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2(
      firstNotifier: userNameNotifier,
      secondNotifier: phonenumberNotifier,
      builder: (context, userName, phoneNumber, child) {
        return Stack(
          children: [
            SizedBox(
              height: 95.h + 80,
              child: Image.asset(
                'assets/bg_pitch.jpg',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 20.h,
              left: 10.w,
              child: SizedBox(
                height: 95.h + 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageSelector(
                      verificationStatus: userName,
                      imageData: _imageData,
                      cachedImageData: _cachedImageData,
                      pickImage: pickImage,
                    ),
                    userName != null
                        ? Row(
                            children: [
                              SizedBox(width: 40.w),
                              Text(
                                userName,
                                style: TextUtils.setTextStyle(
                                  fontSize: 17.sp,
                                  color: Colorscontainer.greenColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 15.sp,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.grey.shade400, size: 14.sp),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        name: userName,
                                        phoneNumber: phoneNumber ?? '',
                                        imageData: _imageData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : logginButton(context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget logginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, 20.h),
        backgroundColor: Colorscontainer.greenColor.withOpacity(0.7),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
      ),
      child: Text(
        DemoLocalizations.register,
        style: TextUtils.setTextStyle(fontSize: 15.sp, color: Colors.white),
      ),
    );
  }

  Future<Uint8List?> getCachedImageData() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedImage = prefs.getString('cachedImageData');
    if (encodedImage != null) {
      return base64Decode(encodedImage);
    }
    return null;
  }
}

Widget _buildMenuItems({
  required BuildContext context,
  required String imageName,
  required String description,
  required double imgWidth,
  required double height,
  bool isLottie = false,
}) {
  return ListTile(
    leading: SizedBox(
      width: 50.w,
      height: 50.h,
      child: isLottie
          ? Lottie.asset(
              'assets/$imageName',
              height: height.h,
              width: imgWidth.w,
              fit: BoxFit.contain,
            )
          : Image.asset(
              'assets/$imageName',
              height: height.h,
              width: imgWidth.w,
              fit: BoxFit.contain,
            ),
    ),
    title: Text(
      description,
      style: TextUtils.setTextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15.sp,
      ),
    ),
  );
}

Widget aboutusDialogue(BuildContext context) {
  return AlertDialog(
    backgroundColor: Colorscontainer.greenShade,
    insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 80.h),
    contentPadding: EdgeInsets.zero,
    alignment: Alignment.center,
    actionsPadding: EdgeInsets.zero,
    title: Text(
      'Roshan technologies™',
      textAlign: TextAlign.start,
      style: GoogleFonts.roboto(
        fontSize: 20.sp,
        color: const Color.fromARGB(255, 255, 215, 0),
      ),
    ),
    titlePadding: EdgeInsets.only(bottom: 15.h, left: 10.w),
    content: SizedBox(
      width: double.maxFinite,
      child: Scrollbar(
        interactive: true,
        thickness: 3.0.w,
        thumbVisibility: true,
        radius: Radius.circular(15.0.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              '''In the bustling tech hub of Addis Ababa, Roshan Technologies is making waves with their latest venture, "Testa" – a cutting-edge football mobile application. As Ethiopia's capital continues to solidify its place on the global technological stage, local innovators like Roshan Technologies are pushing the envelope, and Testa is a testament to this movement. Testa isn't just another football app; it's a fusion of intuitive design, real-time updates, and in-depth match analytics tailored for the African market and beyond. With Testa, users can track scores, follow their favorite teams, and get insights straight from the footballing world, all at their fingertips. Roshan Technologies, known for their forward-thinking approaches, have integrated features that cater to both casual fans and die-hard enthusiasts.  This Addis Ababa-based company is not only setting new standards for sports apps but also showcasing the potential of Ethiopian tech enterprises on the world stage. Their commitment to quality and innovation is apparent in Testa, providing a seamless user experience and bridging the gap between football fans and the game they love. With Testa, Roshan Technologies is truly redefining the way we experience football on mobile.''',
              style: GoogleFonts.ropaSans(color: Colors.white),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    ),
    actions: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: Colorscontainer.greenColor,
                ),
              ),
            ),
            child: Text(
              'close',
              style: GoogleFonts.ropaSans(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget contactusDialogue(BuildContext context) {
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  return AlertDialog(
    backgroundColor: const Color.fromARGB(255, 75, 105, 76).withOpacity(0.85),
    insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 80.h),
    contentPadding: EdgeInsets.zero,
    alignment: Alignment.center,
    actionsPadding: EdgeInsets.zero,
    title: Text('Roshan technologies™',
        textAlign: TextAlign.start,
        style: GoogleFonts.ropaSans(
          fontSize: 15.sp,
          color: const Color.fromARGB(255, 255, 215, 0),
        )),
    titlePadding: EdgeInsets.only(bottom: 15.h, left: 10.w, top: 10.h),
    content: SizedBox(
      height: 80.h,
      child: Padding(
        padding: EdgeInsets.only(left: 15.0.w),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 57.w,
                  child: Text(
                    'Email : ',
                    style: GoogleFonts.ropaSans(
                        fontSize: 20.sp, color: Colors.white),
                  ),
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () async {
                    var url = 'support@testa.et';
                    if (!await launchUrl(
                        Uri(scheme: 'mailto', path: 'support@testa.et'),
                        mode: LaunchMode.platformDefault)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: Text('support@testa.et',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ropaSans(
                          fontSize: 20.sp, color: Colors.blue)),
                ))
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                SizedBox(
                  width: 57.w,
                  child: Text(
                    'Phone : ',
                    style: GoogleFonts.ropaSans(
                        fontSize: 20.sp, color: Colors.white),
                  ),
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () async {
                    await makePhoneCall('+251940404050');
                  },
                  child: Text(' +251940404050',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ropaSans(
                          fontSize: 20.sp, color: Colors.blue)),
                ))
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 2, color: Colorscontainer.greenColor))),
            child: Text(
              'close',
              style: GoogleFonts.ropaSans(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ),
      ),
    ],
  );
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> firstNotifier;
  final ValueListenable<B> secondNotifier;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.firstNotifier,
    required this.secondNotifier,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: firstNotifier,
      builder: (context, firstValue, child) {
        return ValueListenableBuilder<B>(
          valueListenable: secondNotifier,
          builder: (context, secondValue, child) {
            return builder(context, firstValue, secondValue, child);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

Widget _buildSavedNewsMenuItem(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.bookmark, color: Colors.yellow),
    title: Text(
      DemoLocalizations.saved_news,
      style: TextUtils.setTextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15.sp,
      ),
    ),
    onTap: () {
      // Navigate to SavedNewsPage directly without using routes
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavedNewsPage()),
      );
    },
  );
}
