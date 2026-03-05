import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/state/application/persistent_player/persistent_player_bloc.dart';
import 'package:blogapp/state/application/persistent_player/persistent_player_event.dart';
import 'package:blogapp/services/service_locator.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class LiveAudioPlayer extends StatefulWidget {
  final String avatar;
  final String name;
  final String station;
  final String program;
  final String liveLink;
  final bool isPersistent;
  final VoidCallback? onClose;

  const LiveAudioPlayer({
    super.key,
    required this.avatar,
    required this.name,
    required this.station,
    required this.program,
    required this.liveLink,
    this.isPersistent = true,
    this.onClose,
  });

  @override
  State<LiveAudioPlayer> createState() => _LiveAudioPlayerState();
}

class _LiveAudioPlayerState extends State<LiveAudioPlayer> {
  late AudioHandler _audioHandler;
  StreamSubscription<PlaybackState>? _playbackStateSubscription;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioHandler = getIt<AudioHandler>();
    _listenToPlaybackState();
    _initializeAudio();
  }

  @override
  void didUpdateWidget(covariant LiveAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liveLink != oldWidget.liveLink ||
        widget.name != oldWidget.name ||
        widget.station != oldWidget.station ||
        widget.program != oldWidget.program ||
        widget.avatar != oldWidget.avatar) {
      _initializeAudio();
    }
  }

  Future<void> _initializeAudio() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isPlaying = false;
      });
    }

    try {
      final mediaItem = MediaItem(
          id: widget.liveLink,
          album: widget.station,
          title: widget.name,
          artist: widget.program,
          artUri: Uri.parse(widget.avatar),
          extras: {'url': widget.liveLink});

      await _audioHandler.playMediaItem(mediaItem);
    } catch (e) {
      print('Error initializing audio player: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
        });
      }
    }
  }

  void _listenToPlaybackState() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription =
        _audioHandler.playbackState.listen((playbackState) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playbackState.playing;
        _isLoading = playbackState.processingState ==
                AudioProcessingState.loading ||
            playbackState.processingState == AudioProcessingState.buffering;
      });
    });
  }

  Future<void> _handlePlayPause() async {
    if (_isLoading) return; // Prevent multiple taps while loading

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isPlaying) {
        await _audioHandler.pause();
      } else {
        await _audioHandler.play();
      }
    } catch (e) {
      print('Error handling play/pause: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _playbackStateSubscription?.cancel();
    _audioHandler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = widget.isPersistent
        ? MediaQuery.of(context).padding.bottom
        : MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15),
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.black.withOpacity(0.75),
                          Colors.black.withOpacity(0.65),
                        ]
                      : [
                          Colors.white.withOpacity(0.75),
                          Colors.white.withOpacity(0.65),
                        ],
                ),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildAvatar(),
                  SizedBox(width: 10.w),
                  _buildTextContent(isDarkMode),
                  _buildControls(isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 36.h,
      width: 36.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.avatar,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[850],
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white54,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(bool isDarkMode) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: TextUtils.setTextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            '${widget.station} • ${widget.program}',
            style: TextUtils.setTextStyle(
              color:
                  isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
              fontSize: 12.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isDarkMode) {
    return Row(
      children: [
        _buildControlButton(
          onTap: _handlePlayPause,
          child: _isLoading
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : Colors.black87),
                  ),
                )
              : Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  size: 28.r,
                ),
          color: Colorscontainer.greenColor,
        ),
        SizedBox(width: 8.w),
        _buildControlButton(
          onTap: () async {
            try {
              await _audioHandler.stop();
              await _audioHandler.customAction('dispose');
            } catch (e) {
              print('Error closing player: $e');
            } finally {
              if (widget.onClose != null) {
                widget.onClose!();
              }
              if (mounted) {
                context
                    .read<PersistentPlayerBloc>()
                    .add(HidePersistentPlayer());
              }
            }
          },
          child: Icon(
            Icons.close_rounded,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            size: 24.r,
          ),
          color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required Widget child,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.r,
        width: 32.r,
        decoration: BoxDecoration(
          color: onTap == null ? color.withOpacity(0.5) : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollingText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _textWidth = 0;
  double _containerWidth = 0;
  final _gap = 30.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(_scroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureText();
    });
  }

  void _measureText() {
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    _textWidth = textPainter.width;

    final containerWidth = context.size?.width ?? 0;
    _containerWidth = containerWidth;

    if (_textWidth > _containerWidth) {
      _animationController.repeat();
    }
  }

  void _scroll() {
    if (_textWidth > _containerWidth) {
      final maxScroll = _textWidth - _containerWidth + _gap;
      final offset = _animationController.value * maxScroll;
      _scrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ExcludeSemantics(
        excluding: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              color: widget.style.color?.withOpacity(1.0),
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
