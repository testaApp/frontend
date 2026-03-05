import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/routenames.dart';

class entrypage extends StatefulWidget {
  const entrypage({super.key});

  @override
  State<entrypage> createState() => entryPageState();
}

class entryPageState extends State<entrypage> {
  static const String _introAssetPath = 'assets/Testa-intro.gif';
  static const String _introFallbackAssetPath =
      'assets/testa_logo_transparent.png';
  bool _didPrecacheIntro = false;
  bool _isIntroReady = false;

  @override
  void initState() {
    super.initState();
    _navigateToNextPageAfterDelay();
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
        debugPrint('Entry intro GIF precache failed: $error');
      }),
    );
  }

  void _navigateToNextPageAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      final String currentPath = GoRouterState.of(context).uri.path;

      if (currentPath != '/entrypage') {
        debugPrint(
            '🚫 Notification navigation active. Cancelling auto-home redirect.');
        return;
      }

      debugPrint('✅ No notification, proceeding to home.');
      context.goNamed(RouteNames.home);
    });
  }

  Widget _buildFallbackLogo() {
    return Center(
      key: const ValueKey('entry_intro_logo'),
      child: Image.asset(
        _introFallbackAssetPath,
        width: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.sports_soccer,
          color: Colors.white,
          size: 96,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF068657),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: ColoredBox(
        color: const Color(0xFF068657),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _isIntroReady
              ? Image.asset(
                  _introAssetPath,
                  key: const ValueKey('entry_intro_gif'),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackLogo(),
                )
              : _buildFallbackLogo(),
        ),
      ),
    );
  }
}
