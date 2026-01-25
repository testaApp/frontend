import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../../../main.dart';

class FastYouTubePlayer extends StatefulWidget {
  final String? videoUrl;
  final bool autoPlay;

  const FastYouTubePlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<FastYouTubePlayer> createState() => _FastYouTubePlayerState();
}

class _FastYouTubePlayerState extends State<FastYouTubePlayer>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
  PodPlayerController? _podController;
  String? _videoId;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = false;
  bool _useFallback = false;
  bool _isLoadingFallback = false;
  bool _isCustomFullScreen = false;
  late AnimationController _controlsAnimationController;
  Timer? _hideControlsTimer;

  String _getLocalizedText(String key) {
    final currentLanguage = localLanguageNotifier.value;
    final translations = {
      'loading': {
        'en': 'Loading video...',
        'am': 'Loading video...',
        'om': 'Loading video...',
        'so': 'Loading video...',
        'tr': 'Loading video...',
      },
      'error_generic': {
        'en': 'Unable to play this video',
        'am': 'ይህን ቪዲዮ ማጫወት አልተቻለም',
        'om': 'Viidiyoo kana taphachuu hin dandeenye',
        'so': 'Lama ciyaari karo muuqaalkan',
        'tr': 'ነዚ ቪድዮ ምጽዋት ኣይከኣለን',
      },
      'go_back': {
        'en': 'Go Back',
        'am': 'ተመለስ',
        'om': 'Deebi\'i',
        'so': 'Dib u noqo',
        'tr': 'ተመለስ',
      },
      'retry': {
        'en': 'Retry',
        'am': 'እንደገና ሞክር',
        'om': 'Irra deebi\'ii yaali',
        'so': 'Dib u isku day',
        'tr': 'ደጊምካ ፈትን',
      },
    };
    return translations[key]?[currentLanguage] ??
        translations[key]?['en'] ??
        '';
  }

  late final List<DeviceOrientation> _originalOrientations;
  @override
  void initState() {
    super.initState();
    _originalOrientations = [DeviceOrientation.portraitUp];

    // Your existing code...
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _extractVideoId();
    if (_videoId != null) {
      _initializePlayer();
    }
  }

  void _extractVideoId() {
    try {
      if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;
      final input = widget.videoUrl!.trim();
      if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(input)) {
        _videoId = input;
        return;
      }
      _videoId = YoutubePlayer.convertUrlToId(input);
      _videoId ??= input;
    } catch (e) {
      debugPrint('Error extracting video ID: $e');
      _videoId = widget.videoUrl;
    }
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        enableCaption: true,
        forceHD: false,
        loop: false,
        isLive: false,
        hideThumbnail: true,
        useHybridComposition: true,
        disableDragSeek: false,
      ),
    )..addListener(_playerListener);
  }

  Future<void> _initializeFallbackPlayer() async {
    if (_isLoadingFallback) return;
    setState(() {
      _isLoadingFallback = true;
      _hasError = false;
    });

    try {
      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(_videoId!);
      final streamInfo =
          manifest.muxed.withHighestBitrate(); // or .first for fastest
      if (streamInfo == null) throw Exception('No suitable stream found');

      final videoUrl = streamInfo.url.toString();
      _podController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(videoUrl),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: true,
          isLooping: false,
          videoQualityPriority: [1080, 720, 480, 360],
        ),
        // ignore: unawaited_futures
      )..initialise();

      yt.close();
      if (mounted) {
        setState(() {
          _useFallback = true;
          _isPlayerReady = true;
          _isLoadingFallback = false;
        });
      }
    } catch (e) {
      debugPrint('Fallback player error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoadingFallback = false;
          _errorMessage = _getLocalizedText('error_generic');
        });
      }
    }
  }

  void _playerListener() {
    if (mounted) {
      if (_controller.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
          _hasError = false;
        });
      }

      if (_isPlayerReady && _showControls) {
        setState(() {});
      }

      if (_controller.value.hasError && !_useFallback && !_isLoadingFallback) {
        _initializeFallbackPlayer();
      }
    }
  }

  void _toggleCustomFullScreen() {
    setState(() {
      _isCustomFullScreen = !_isCustomFullScreen;
    });

    if (_isCustomFullScreen) {
      // ENTER fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // EXIT fullscreen → restore original app orientation behavior
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(_originalOrientations);
    }

    _showControls = true;
    _autoHideControls();
  }

  void _toggleControls() {
    _hideControlsTimer?.cancel();
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _autoHideControls();
    }
  }

  void _autoHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        final isPlaying = _useFallback
            ? (_podController?.isVideoPlaying ?? false)
            : _controller.value.isPlaying;
        if (isPlaying) {
          setState(() => _showControls = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controlsAnimationController.dispose();
    _controller.dispose();
    _podController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(_originalOrientations);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _videoId!.isEmpty) {
      return _buildErrorScaffold(_getLocalizedText('error_generic'));
    }

    if (_useFallback) {
      return _buildFallbackPlayer();
    }

    final bool isLandscape = _isCustomFullScreen;

    return PopScope(
      canPop: !isLandscape,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isLandscape) {
          _toggleCustomFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video player - fills screen properly in fullscreen
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: false,
                      bottomActions: const [],
                      topActions: const [],
                      aspectRatio: 16 / 9,
                      onReady: () {
                        setState(() {
                          _isPlayerReady = true;
                          if (widget.autoPlay) _showControls = false;
                        });
                      },
                      onEnded: (_) {
                        setState(() => _showControls = true);
                        _controlsAnimationController.forward();
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Loading / Error
            if (!_isPlayerReady || _isLoadingFallback)
              _buildLoadingIndicator(alternative: _isLoadingFallback),
            if (_hasError) _buildErrorOverlay(),

            // Custom controls overlay
            if (_isPlayerReady && !_hasError)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildAdvancedControls(isFullScreen: isLandscape),
                  ),
                ),
              ),

            // Back button (only in portrait)
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_podController != null)
            Center(
              child: PodVideoPlayer(controller: _podController!),
            )
          else
            _buildLoadingIndicator(alternative: true),
          if (!_isCustomFullScreen) _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    // if (!_showControls) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 6,
      child: IconButton(
        icon:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
        tooltip: _getLocalizedText('go_back'),
      ),
    );
  }

  Widget _buildAdvancedControls({required bool isFullScreen}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.2, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Center play/pause
          Center(
            child: _buildGlassButton(
              icon: _controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 72,
              onPressed: () {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
                setState(() {});
                _autoHideControls();
              },
            ),
          ),

          // Progress bar and buttons - moved up
          Positioned(
            bottom: isFullScreen ? 60 : 90, // Higher up
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildBottomControls(isFullScreen: isFullScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            _formatDuration(_controller.value.position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFFFF0000),
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFFFF0000).withOpacity(0.3),
              ),
              child: Slider(
                value: _controller.value.position.inSeconds.toDouble().clamp(
                    0.0, _controller.metadata.duration.inSeconds.toDouble()),
                max: _controller.metadata.duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _controller.seekTo(Duration(seconds: value.toInt()));
                },
                onChangeEnd: (_) => _autoHideControls(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_controller.metadata.duration),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls({required bool isFullScreen}) {
    return Row(
      mainAxisAlignment: isFullScreen
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallGlassButton(
          icon: Icons.replay_10_rounded,
          onPressed: () {
            final pos =
                _controller.value.position - const Duration(seconds: 10);
            _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
            _autoHideControls();
          },
        ),
        if (isFullScreen) const SizedBox(width: 40),
        _buildSmallGlassButton(
          icon: Icons.forward_10_rounded,
          onPressed: () {
            final pos =
                _controller.value.position + const Duration(seconds: 10);
            final max = _controller.metadata.duration;
            _controller.seekTo(pos < max ? pos : max);
            _autoHideControls();
          },
        ),
        if (isFullScreen) const SizedBox(width: 40),
        _buildSmallGlassButton(
          icon: isFullScreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          onPressed: _toggleCustomFullScreen,
        ),
      ],
    );
  }

  Widget _buildSmallGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator({bool alternative = false}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(100),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: const Color(0xFFFF0000),
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getLocalizedText('loading'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF0000).withOpacity(0.2),
                      const Color(0xFFFF0000).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF0000).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF0000),
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildErrorButton(
                    icon: Icons.refresh_rounded,
                    label: _getLocalizedText('retry'),
                    onPressed: _retryVideo,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 16),
                  _buildErrorButton(
                    icon: Icons.arrow_back,
                    label: _getLocalizedText('go_back'),
                    onPressed: () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retryVideo() {
    setState(() {
      _hasError = false;
      _isPlayerReady = false;
      _useFallback = false;
      _isLoadingFallback = false;
    });
    _podController?.dispose();
    _podController = null;
    _controller.dispose();
    _initializePlayer();
  }

  Widget _buildErrorButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _buildSmallGlassButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
