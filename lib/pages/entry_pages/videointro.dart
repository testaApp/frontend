import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';

class VideoIntroPage extends StatefulWidget {
  const VideoIntroPage({super.key});

  @override
  State<VideoIntroPage> createState() => _VideoIntroPageState();
}

class _VideoIntroPageState extends State<VideoIntroPage> {
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;
  final int _totalFiles = 5;
  int _loadedFiles = 0;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  void _initializeAndFetch() {
    _startFetchingLocalizations();
  }

  Future<void> _startFetchingLocalizations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingProgress = 0.0;
      _loadedFiles = 0;
    });

    try {
      // Fetch localizations one by one to track progress
      final languages = ['am', 'en', 'tr', 'so', 'or'];
      for (var lang in languages) {
        await fetchLocalizationValues(lang);
        if (mounted) {
          setState(() {
            _loadedFiles++;
            _loadingProgress = _loadedFiles / _totalFiles;
          });
        }
      }

      if (mounted) {
        context.go('/language');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restartPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingProgress = 0.0;
      _loadedFiles = 0;
    });

    // Add a small delay to ensure state is reset
    await Future.delayed(const Duration(milliseconds: 100));

    // Retry the fetch operation
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
                child: Image.asset(
                  'assets/Testa-intro.gif',
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
