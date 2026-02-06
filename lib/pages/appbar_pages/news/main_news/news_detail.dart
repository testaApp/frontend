import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../localization/demo_localization.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_utils.dart';
import '/../components/timeFormatter.dart';
import '/../main.dart';
import '/../models/news.dart';
import '/../repository/news_repository.dart';
import '/../functions/download_and_save_image.dart';

final NewsRepository api = NewsRepository();

class NewsDetailPage extends StatefulWidget {
  final News? news;
  final String? id;

  const NewsDetailPage({
    super.key,
    this.news,
    this.id,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage>
    with SingleTickerProviderStateMixin {
  News? _news;
  bool _isLoading = true;
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAudioLoading = false;
  bool isBookmarked = false;
  late Box savedNewsBox;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _hasError = false;
  String _errorMessage = '';
  static const List<double> _fontScaleSteps = [0.95, 1.0, 1.1, 1.2];
  int _fontScaleIndex = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initHive().then((_) => _loadNewsData());

    // Audio completion listener
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _loadNewsData() async {
    try {
      if (widget.id != null) {
        final detail = await api.getDetails(
          widget.id!,
          localLanguageNotifier.value,
        );
        _news = News.fromJson(detail.data);
        _hasError = false;
      } else if (widget.news != null) {
        _news = widget.news;
        _hasError = false;
      }
    } catch (e, stack) {
      debugPrint("News load error: $e\n$stack");
      _hasError = true;
      _errorMessage = e.toString().contains("SocketException") ||
              e.toString().contains("Failed host")
          ? "No internet connection"
          : "Failed to load news\n${e.toString()}";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_news != null) {
          _checkIfBookmarked();
        }
      }
    }
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen('saved_news')) {
      savedNewsBox = await Hive.openBox('saved_news');
    } else {
      savedNewsBox = Hive.box('saved_news');
    }
  }

  void _checkIfBookmarked() {
    final savedNews = savedNewsBox.get(_news?.id);
    setState(() {
      isBookmarked = savedNews != null;
    });
  }

  Future<void> _toggleBookmark() async {
    if (isBookmarked) {
      await savedNewsBox.delete(_news?.id);
    } else {
      if (savedNewsBox.length >= 30) {
        final oldestKey = savedNewsBox.keys.first;
        await savedNewsBox.delete(oldestKey);
      }
      await savedNewsBox.put(_news?.id, jsonEncode(_news?.toJson()));
    }
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      setState(() {
        isAudioLoading = true;
      });

      final String audioUrl =
          'testa.et/${_news?.id}/${localLanguageNotifier.value}.mp3';

      try {
        await audioPlayer.play(UrlSource(audioUrl)).then((value) {
          setState(() {
            isAudioLoading = false;
            isPlaying = true;
          });
        });
      } catch (error) {
        setState(() {
          isAudioLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error playing audio'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getLocalizedCaption() {
    return _news?.figCaption ?? '';
  }

  void _cycleFontScale() {
    setState(() {
      _fontScaleIndex = (_fontScaleIndex + 1) % _fontScaleSteps.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colorscontainer.greenColor,
            size: 50,
          ),
        ),
      );
    }

    if (_hasError || _news == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_wifi_off_rounded,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 24.h),
                Text(
                  _hasError ? _errorMessage : "News not available",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32.h),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _loadNewsData();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final bool isScrolled = _scrollOffset > 40;
    final int imageCount = _news?.mainImages.length ?? 0;
    final bool hasImages = imageCount > 0;
    final String caption = _getLocalizedCaption().trim();
    final String appBarTitle = _news?.summarizedTitle.toString() ?? '';
    final double bodyFontSize = 17.0 * _fontScaleSteps[_fontScaleIndex];
    const double contentMaxWidth = 720;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isScrolled
                ? theme.colorScheme.surface.withOpacity(0.98)
                : Colors.transparent,
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
            border: isScrolled
                ? Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.15),
                    ),
                  )
                : null,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Row(
                children: [
                  _buildIconButton(
                    Icons.arrow_back,
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    isScrolled: isScrolled,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: isScrolled ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          appBarTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextUtils.setTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                            color: theme.textTheme.titleMedium?.color,
                            themeData: theme,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        Icons.text_fields,
                        _cycleFontScale,
                        color: _fontScaleIndex == 1
                            ? null
                            : Colorscontainer.greenColor,
                        isScrolled: isScrolled,
                      ),
                      SizedBox(width: 12.w),
                      _buildIconButton(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        _toggleBookmark,
                        color: isBookmarked ? Colorscontainer.greenColor : null,
                        isScrolled: isScrolled,
                      ),
                      SizedBox(width: 12.w),
                      _buildIconButton(
                        Icons.share_outlined,
                        () => Share.share(
                          '${_news?.summarizedTitle} \n\n${DemoLocalizations.Read_more_at}: https://testa.et/news/${_news?.id} ${localLanguageNotifier.value != 'en' ? '?lang=${localLanguageNotifier.value}' : ''}',
                        ),
                        isScrolled: isScrolled,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 280.h,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImages)
                            PageView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageCount,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final image = _news?.mainImages[index];
                                return GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Save Image'),
                                          content: const Text(
                                              'Do you want to save this image?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _saveImage(_news!
                                                    .mainImages[index].url);
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: image!.url,
                                    width: MediaQuery.of(context).size.width,
                                    height: 280.h,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/testa_testa.png'),
                                  ),
                                );
                              },
                            )
                          else
                            Image.asset(
                              'assets/testa_testa.png',
                              fit: BoxFit.cover,
                            ),
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.45),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          if (caption.isNotEmpty)
                            Positioned(
                              bottom: 12.h,
                              left: 16.w,
                              right: 16.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.photo_camera,
                                          size: 14.sp,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            caption,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextUtils.setTextStyle(
                                              fontSize: 12.5.sp,
                                              color: Colors.white,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (imageCount > 1)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageCount,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 12.w : 6.w,
                              height: 6.w,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colorscontainer.greenColor
                                    : Colors.grey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 110.h),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: contentMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _news!.summarizedTitle.toString(),
                                style: TextUtils.setTextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                  color: theme.textTheme.titleLarge?.color,
                                  themeData: theme,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                padding:
                                    EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color:
                                          theme.dividerColor.withOpacity(0.2),
                                    ),
                                    bottom: BorderSide(
                                      color:
                                          theme.dividerColor.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                child: _buildSourceInfo(),
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                _news!.summarized.toString(),
                                textAlign: TextAlign.start,
                                style: TextUtils.setTextStyle(
                                  fontSize: bodyFontSize.sp,
                                  height: 1.75,
                                  color: theme.textTheme.bodyLarge?.color
                                          ?.withOpacity(0.9) ??
                                      Colors.black87,
                                  themeData: theme,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10.h,
            right: 20.w,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 20.h, right: 10.w),
              child: _buildAudioFAB(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    bool isScrolled = false,
  }) {
    final theme = Theme.of(context);
    final Color backgroundColor = isScrolled
        ? theme.colorScheme.surface.withOpacity(0.9)
        : Colors.black.withOpacity(0.35);
    final Color iconColor = color ??
        (isScrolled ? theme.colorScheme.onSurface : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: isScrolled
                ? Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18.sp,
            shadows: isScrolled
                ? null
                : [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceInfo() {
    final theme = Theme.of(context);
    final String author = (_news?.author ?? '').trim();
    final String time = formatTimeForNews(_news!.publishedDate ?? '');
    final List<String> metaParts = [
      if (author.isNotEmpty) author,
      if (time.isNotEmpty) time,
    ];
    final String metaText = metaParts.join(' \u2022 ');
    final Color metaColor =
        theme.textTheme.bodySmall?.color?.withOpacity(0.75) ?? Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 36.w,
          height: 36.w,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
            ),
            child: ClipOval(
              child:
                  _news?.sourceimage != null && _news!.sourceimage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _news!.sourceimage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(strokeWidth: 1),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.business,
                            size: 18,
                            color: Colors.grey,
                          ),
                        )
                      : Image.asset('assets/testa_logo.png',
                          fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _news?.sourcename ?? '',
                style: TextUtils.setTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                  themeData: theme,
                ),
              ),
              if (metaText.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  metaText,
                  style: TextUtils.setTextStyle(
                    fontSize: 12.sp,
                    color: metaColor,
                    themeData: theme,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colorscontainer.greenColor,
            Colorscontainer.greenColor.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colorscontainer.greenColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: togglePlayPause,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: isAudioLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 25.sp,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(String imageUrl) async {
    try {
      final String fileName =
          '${_news?.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String? savedPath = await downloadAndSaveImage(imageUrl, fileName);

      if (savedPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save image'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class ScrollingFigCaption extends StatefulWidget {
  final String caption;
  final double width;

  const ScrollingFigCaption({
    super.key,
    required this.caption,
    required this.width,
  });

  @override
  State<ScrollingFigCaption> createState() => _ScrollingFigCaptionState();
}

class _ScrollingFigCaptionState extends State<ScrollingFigCaption>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent > 0) {
        setState(() => _needsScroll = true);
        _startScrollingAnimation();
      }
    });
  }

  void _startScrollingAnimation() {
    if (!_needsScroll) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController
          .animateTo(
        maxScroll,
        duration: Duration(seconds: (maxScroll ~/ 30) + 3),
        curve: Curves.easeInOut,
      )
          .then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          _scrollController
              .animateTo(
                0,
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOut,
              )
              .then((_) => _startScrollingAnimation());
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 28.h,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Icon(
                Icons.photo_camera,
                size: 14.sp,
                color: Colors.white70,
              ),
              SizedBox(width: 8.w),
              Text(
                widget.caption,
                style: TextUtils.setTextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
