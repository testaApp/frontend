import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      if (widget.news != null) {
        _news = widget.news;
      } else if (widget.id != null) {
        _news = await api.getNewsById(widget.id!, localLanguageNotifier.value);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _checkIfBookmarked();
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

  ImageProvider _getSourceImage() {
    final sourceName = _news?.sourcename ?? '';
    final assetPath = sourceImageMap[sourceName];

    if (assetPath != null) {
      return AssetImage(assetPath);
    }
    return const AssetImage('assets/default_source.png');
  }

  String _getLocalizedCaption() {
    final currentLanguage = localLanguageNotifier.value;
    return _news?.figCaption ?? '';
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

    final appBarOpacity = (_scrollOffset / 200).clamp(0.0, 0.85);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON — now away from the edge
                  _buildIconButton(
                    Icons.arrow_back,
                    () => context.pop(),
                  ),

                  Row(
                    children: [
                      // BOOKMARK BUTTON
                      _buildIconButton(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        _toggleBookmark,
                        color: isBookmarked ? Colors.yellow : null,
                      ),

                      SizedBox(width: 12.w), // proper spacing

                      // SHARE BUTTON
                      _buildIconButton(
                        Icons.share_outlined,
                        () => Share.share(
                          '${_news?.summarizedTitle} \n\nRead more at: https://testa.et/news/${_news?.id}',
                        ),
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
                    // Image Container
                    SizedBox(
                      height: 250.h,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _news?.mainImages.length ?? 0,
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
                                              _saveImage(
                                                  _news!.mainImages[index].url);
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
                                  height: 250.h,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/testa_testa.png'),
                                ),
                              );
                            },
                          ),

                          // FigCaption Overlay
                          if (_news?.figCaption?.isNotEmpty ?? false)
                            Positioned(
                              bottom: 2.h,
                              left: 12.w,
                              right: 12.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.photo_camera,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        _getLocalizedCaption(),
                                        style: TextUtils.setTextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white,
                                          height: 1.2,
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

                    // Page Indicators
                    if ((_news?.mainImages.length ?? 0) > 1)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _news?.mainImages.length ?? 0,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 10.w : 6.w,
                              height: _currentPage == index ? 10.w : 6.w,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colorscontainer.greenColor
                                    : Colors.grey.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Content Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _news!.summarizedTitle.toString(),
                            style: TextUtils.setTextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                              themeData: Theme.of(context),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Source Card
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildSourceInfo(),
                          ),
                          SizedBox(height: 20.h),

                          // News Content
                          Text(
                            _news!.summarized.toString(),
                            textAlign: TextAlign.justify,
                            style: TextUtils.setTextStyle(
                              fontSize: 16.sp,
                              height: 1.6,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              themeData: Theme.of(context),
                            ),
                          ),
                          SizedBox(height: 100.h),
                        ],
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color ?? Colors.white, // <-- USE CUSTOM COLOR
            size: 18.sp,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black.withOpacity(0.7),
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LOGO WITH FIXED SIZE (NO BACKGROUND, NO CIRCLE)
        SizedBox(
          width: 40.w,
          height: 24.h,
          child: Image(
            image: _getSourceImage(),
            fit: BoxFit.contain, // keep original proportions
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
                  themeData: Theme.of(context),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.person, size: 12.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _news?.author ?? '',
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        themeData: Theme.of(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      formatTimeForNews(_news!.time),
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        themeData: Theme.of(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
                    size: 20.sp,
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

final Map<String, String> sourceImageMap = {
  '90minNews': 'assets/90mins_logo.png',
  'hatrick sport': 'assets/hatricknews_logo.png',
  'Soccer Ethiopia': 'assets/soccerEt_logo.png',
  'transfer market': 'assets/transfer_logo.png',
  'athletic news': 'assets/theathletic_logo.png',
};

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
