import 'dart:async';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:blogapp/components/routenames.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

final RegExp _geezRegex = RegExp(r'[\u1200-\u137F\u1380-\u139F\u2D80-\u2DDF]');

bool _usesGeezScript(String text) => _geezRegex.hasMatch(text);

class LanguageChoose extends StatefulWidget {
  const LanguageChoose({super.key});

  @override
  State<LanguageChoose> createState() => _LanguageChooseState();
}

class _LanguageChooseState extends State<LanguageChoose>
    with SingleTickerProviderStateMixin {
  static const String _lottieAssetPath = 'assets/testa_video.json';
  static const String _fallbackImagePath = 'assets/testa_video_starting.png';
  static const String _termsUrl = 'https://testa.et/terms-and-conditions';

  String selectedLanguage = 'am';
  late Future<LottieComposition> _compositionFuture;
  late AnimationController _glowController;
  late TapGestureRecognizer _termsTapRecognizer;
  bool _isContinuing = false;
  bool _didPrecacheFallback = false;

  final List<LanguageOption> languageOptions = [
    LanguageOption('am', 'አማርኛ', 'Amharic'),
    LanguageOption('or', 'Afaan Oromoo', 'Oromo'),
    LanguageOption('tr', 'ትግርኛ', 'Tigrinya'),
    LanguageOption('so', 'Af-Soomaali', 'Somali'),
    LanguageOption('en', 'English', 'English'),
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
    _compositionFuture = AssetLottie(_lottieAssetPath).load();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _termsTapRecognizer = TapGestureRecognizer()..onTap = _openTermsUrl;
    unawaited(
        globalAnalyticsService.logOnboardingStepViewed('language_select'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheFallback) return;
    _didPrecacheFallback = true;
    unawaited(precacheImage(const AssetImage(_fallbackImagePath), context));
  }

  @override
  void dispose() {
    _termsTapRecognizer.dispose();
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
                  _fallbackImagePath,
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
                                fontFamily: _usesGeezScript(textList.join(' '))
                                    ? 'AbyssinicaSIL-Regular'
                                    : null,
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
                  ),
                ),

                /// TERMS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextUtils.setTextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
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
                          recognizer: _termsTapRecognizer,
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
                          onTap: _isContinuing ? null : _continueToNextPage,
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
                                  fontFamily: _usesGeezScript(getContinueText())
                                      ? 'AbyssinicaSIL-Regular'
                                      : null,
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
    if (selectedLanguage == code) return;
    setState(() => selectedLanguage = code);
    unawaited(
      globalAnalyticsService.logOnboardingStepAction(
        stepName: 'language_select',
        action: 'language_chosen',
        extraParameters: {'language_code': code},
      ),
    );
  }

  Future<void> _continueToNextPage() async {
    if (_isContinuing) return;
    setState(() {
      _isContinuing = true;
    });

    try {
      localLanguageNotifier.value = selectedLanguage;

      final box = Hive.isBoxOpen('settings')
          ? Hive.box('settings')
          : await Hive.openBox('settings');
      await box.put('language', selectedLanguage);
      await globalAnalyticsService.logOnboardingStepAction(
        stepName: 'language_select',
        action: 'continue_clicked',
        extraParameters: {'language_code': selectedLanguage},
      );

      if (!mounted) return;
      await context.pushNamed(
        RouteNames.IntroductionPage,
        extra: selectedLanguage,
      );
    } catch (e) {
      unawaited(
        globalAnalyticsService.logOnboardingStepAction(
          stepName: 'language_select',
          action: 'continue_failed',
          extraParameters: {'error_type': e.runtimeType.toString()},
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to continue: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isContinuing = false;
        });
      }
    }
  }

  Future<void> _openTermsUrl() async {
    unawaited(
      globalAnalyticsService.logOnboardingStepAction(
        stepName: 'language_select',
        action: 'terms_opened',
      ),
    );
    await _launchURL(_termsUrl);
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open terms and conditions')),
      );
      return;
    }

    if (!mounted) return;
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

/// ================= GLASS GRID =================

class GlassLanguageGrid extends StatelessWidget {
  final List<LanguageOption> languageOptions;
  final String selectedLanguage;
  final Function(String) onSelectLanguage;

  const GlassLanguageGrid({
    super.key,
    required this.languageOptions,
    required this.selectedLanguage,
    required this.onSelectLanguage,
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
          onTap: () => onSelectLanguage(option.code),
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
                    fontFamily: _usesGeezScript(option.nativeName)
                        ? 'AbyssinicaSIL-Regular'
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.englishName,
                  style: TextUtils.setTextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
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

  LanguageOption(this.code, this.nativeName, this.englishName);
}
