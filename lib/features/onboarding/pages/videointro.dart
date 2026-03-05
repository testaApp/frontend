import 'dart:async';

import '../../../main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoIntroPage extends StatefulWidget {
  const VideoIntroPage({super.key});

  @override
  State<VideoIntroPage> createState() => _VideoIntroPageState();
}

class _VideoIntroPageState extends State<VideoIntroPage> {
  static const String _introAssetPath = 'assets/Testa-intro.gif';
  static const String _introFallbackAssetPath =
      'assets/testa_video_starting.png';
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;
  final int _totalFiles = supportedLocalizationLanguages.length;
  int _loadedFiles = 0;
  bool _didPrecacheIntro = false;
  bool _isIntroReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(globalAnalyticsService.logOnboardingStepViewed('video_intro'));
    _startFetchingLocalizations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheIntro) return;
    _didPrecacheIntro = true;
    unawaited(
      precacheImage(const AssetImage(_introAssetPath), context).then((_) {
        if (!mounted) return;
        setState(() {
          _isIntroReady = true;
        });
      }).catchError((error, stackTrace) {
        debugPrint('Intro GIF precache failed: $error');
      }),
    );
  }

  Future<void> _startFetchingLocalizations() async {
    resetLocalizationNetworkDebugMetrics();
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingProgress = 0.0;
      _loadedFiles = 0;
    });

    try {
      await Future.wait(
        supportedLocalizationLanguages.map((languageCode) async {
          await fetchLocalizationValues(languageCode);
          if (!mounted) return;
          setState(() {
            _loadedFiles++;
            _loadingProgress = (_loadedFiles / _totalFiles).clamp(0.0, 1.0);
          });
        }),
      );
      printLocalizationNetworkDebugSummary(
        context: 'VideoIntro preload',
      );
      await globalAnalyticsService.logOnboardingStepAction(
        stepName: 'video_intro',
        action: 'localization_preload_success',
        extraParameters: {'languages_count': _totalFiles},
      );

      if (mounted) {
        context.go('/language');
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to preload localizations: $e');
      debugPrint('$stackTrace');
      printLocalizationNetworkDebugSummary(
        context: 'VideoIntro preload (failed)',
      );
      unawaited(
        globalAnalyticsService.logOnboardingStepAction(
          stepName: 'video_intro',
          action: 'localization_preload_failed',
          extraParameters: {
            'error_type': e.runtimeType.toString(),
          },
        ),
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restartPage() async {
    unawaited(
      globalAnalyticsService.logOnboardingStepAction(
        stepName: 'video_intro',
        action: 'retry_clicked',
      ),
    );
    await _startFetchingLocalizations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Image.asset(
                    _isIntroReady ? _introAssetPath : _introFallbackAssetPath,
                    key: ValueKey(_isIntroReady),
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white24,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: height * 0.1,
                left: 0,
                right: 0,
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: width * 0.8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 8,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    value: _loadingProgress,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        )
                      : _hasError
                          ? ElevatedButton.icon(
                              onPressed: _restartPage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Network Error. Tap to retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.05,
                                  vertical: height * 0.02,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
