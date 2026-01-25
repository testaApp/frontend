import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/routenames.dart';
import '../../main.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';

class LanguageChoose extends StatefulWidget {
  const LanguageChoose({super.key});

  @override
  State<LanguageChoose> createState() => _LanguageChooseState();
}

class _LanguageChooseState extends State<LanguageChoose>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'am';
  late Future<LottieComposition> _compositionFuture;
  late AnimationController _glowController;

  final List<LanguageOption> languageOptions = [
    LanguageOption('am', 'አማርኛ', 'Amharic', true),
    LanguageOption('or', 'Afaan Oromoo', 'Oromo', true),
    LanguageOption('tr', 'ትግርኛ', 'Tigrinya', true),
    LanguageOption('so', 'Af-Soomaali', 'Somali', true),
    LanguageOption('en', 'English', 'English', true),
  ];

  final List<List<String>> texts = [
    ['Welcome', 'choose your language'],
    ['እንኳን ደህና መጡ!', 'ቋንቋ ይምረጡ'],
    ['Baga nagayaan dhufte!', 'Afaan filadhu'],
    ['መርሓባ', 'ቋንቋ ምረጹ'],
    ['Soo dhawoow', 'dooro luqaddaada'],
    ['Welcome', 'choose your language'],
  ];

  String getContinueText() {
    switch (selectedLanguage) {
      case 'am':
        return 'ቀጥል';
      case 'tr':
        return 'ቀጽል';
      case 'or':
        return 'Itti fufi';
      case 'so':
        return 'Sii wad';
      case 'en':
        return 'Continue';
      default:
        return 'Continue';
    }
  }

  @override
  void initState() {
    super.initState();
    _compositionFuture = AssetLottie('assets/testa_video.json').load();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    return Scaffold(
      body: Stack(
        children: [
          /// FULLSCREEN LOTTIE (FIXED)
          FutureBuilder<LottieComposition>(
            future: _compositionFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Positioned.fill(
                  child: Lottie(
                    composition: snapshot.data!,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Positioned.fill(
                child: Image.asset(
                  'assets/testa_video_starting.png',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          /// DARK OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// FIXED HEIGHT WELCOME (NO JUMPING)
                SizedBox(
                  height: shortestSide * 0.28,
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: texts
                          .map(
                            (textList) => TyperAnimatedText(
                              textList.join('\n'),
                              textAlign: TextAlign.center,
                              textStyle: TextUtils.setTextStyle(
                                color: Colors.white,
                                fontSize: shortestSide * 0.055,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                              speed: const Duration(milliseconds: 90),
                            ),
                          )
                          .toList(),
                      repeatForever: true,
                    ),
                  ),
                ),

                /// GRID
                Expanded(
                  child: GlassLanguageGrid(
                    languageOptions: languageOptions,
                    selectedLanguage: selectedLanguage,
                    onSelectLanguage: _selectLanguage,
                    onUnavailableLanguage: _showUnavailableLanguageDialog,
                  ),
                ),

                /// TERMS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextUtils.setTextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: shortestSide * 0.03,
                      ),
                      children: [
                        const TextSpan(
                            text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextUtils.setTextStyle(
                            color: Colorscontainer.greenColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchURL(
                                'https://testa.et/terms-and-conditions'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// ELEVATED FUTURISTIC CONTINUE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, _) {
                      return Material(
                        color: Colors.transparent,
                        elevation: 18,
                        shadowColor:
                            Colorscontainer.greenColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(32),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: _continueToNextPage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colorscontainer.greenColor
                                      .withValues(alpha: 0.35),
                                  Colorscontainer.greenColor
                                      .withValues(alpha: 0.35),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colorscontainer.greenColor.withValues(
                                    alpha:
                                        0.35 + (_glowController.value * 0.65),
                                  ),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  offset: const Offset(0, 8),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                getContinueText(),
                                textAlign: TextAlign.center,
                                style: TextUtils.setTextStyle(
                                  fontSize: shortestSide * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(String code) {
    setState(() => selectedLanguage = code);
  }

  Future<void> _continueToNextPage() async {
    localLanguageNotifier.value = selectedLanguage;

    final box = await Hive.openBox('settings');
    await box.put('language', selectedLanguage);

    if (!mounted) return;

    await context.pushNamed(
      RouteNames.IntroductionPage,
      extra: selectedLanguage,
    );
  }

  void _showUnavailableLanguageDialog(
      BuildContext context, LanguageOption language) {}

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

/// ================= GLASS GRID =================

class GlassLanguageGrid extends StatelessWidget {
  final List<LanguageOption> languageOptions;
  final String selectedLanguage;
  final Function(String) onSelectLanguage;
  final Function(BuildContext, LanguageOption) onUnavailableLanguage;

  const GlassLanguageGrid({
    super.key,
    required this.languageOptions,
    required this.selectedLanguage,
    required this.onSelectLanguage,
    required this.onUnavailableLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: languageOptions.length,
      itemBuilder: (_, i) {
        final option = languageOptions[i];
        return GlassLanguageCard(
          option: option,
          isSelected: selectedLanguage == option.code,
          onTap: () => option.isAvailable
              ? onSelectLanguage(option.code)
              : onUnavailableLanguage(context, option),
        );
      },
    );
  }
}

/// ================= CARD =================

class GlassLanguageCard extends StatelessWidget {
  final LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const GlassLanguageCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colorscontainer.greenColor
                : Colors.white.withValues(alpha: 0.24),
            width: 1.5,
          ),
          gradient: isSelected
              ? LinearGradient(colors: [
                  Colorscontainer.greenColor.withValues(alpha: 0.35),
                  Colorscontainer.greenColor.withValues(alpha: 0.1),
                ])
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.nativeName,
                  style: TextUtils.setTextStyle(
                    color: Colors.white,
                    fontSize: shortestSide * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.englishName,
                  style: TextUtils.setTextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: shortestSide * 0.025,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final bool isAvailable;

  LanguageOption(
      this.code, this.nativeName, this.englishName, this.isAvailable);
}
