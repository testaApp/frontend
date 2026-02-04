import 'package:app_settings/app_settings.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../application/following/following_bloc.dart';
import '../../../application/following/following_event.dart';
import '../../../application/following/following_state.dart';
import '../../../application/persistent_player/persistent_player_bloc.dart';
import '../../../application/persistent_player/persistent_player_event.dart';
import '../../../models/playlist/playlist_model.dart';
import '../../../services/analytics_service.dart';
import '../../../services/service_locator.dart';
import '../../constants/colors.dart';
import '../../constants/text_utils.dart';

// ignore: must_be_immutable
class Program extends StatefulWidget {
  Program({
    super.key,
    required this.id,
    required this.avatar,
    required this.name,
    required this.program,
    required this.rssLink,
    this.description,
    required this.time,
    required this.liveLink,
    required this.station,
    required this.isProgram,
    required this.programId, // ✨ ADD THIS

  });

  final String avatar;
  final String name;
  final String program;
  final String id;
  final String station;
  final String liveLink;
  final String programId; // ✨ ADD THIS
  final List<String> rssLink;
  final bool isProgram;
  List<dynamic> time;
  final String? description;

  @override
  State<Program> createState() => _ProgramState();
}

class _ProgramState extends State<Program> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  Color? dominantColor;
  final AudioHandler audioHandler = getIt<AudioHandler>();
  bool isExpanded = false;
  bool isLive = false;
  OverlayEntry? overlayEntry;

  final FollowingAnalyticsService _analyticsService = FollowingAnalyticsService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Only check this specific podcast's following status
    context
        .read<FollowingBloc>()
        .add(CheckFollowingPodcast(podcastId: widget.id));

    // ✨ ADD THIS - Track podcast view
    _analyticsService.logEvent(
      name: 'podcast_viewed',
      parameters: {
        'podcast_id': widget.id,
        'podcast_name': widget.name,
        'program_id': widget.programId,
        'is_live': widget.isProgram,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    _generateDominantColor();
    if (widget.time.isNotEmpty) {
      isLive = widget.isProgram;
    }
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    _animationController.dispose();
    super.dispose();
  }

  PlaylistModel fetchMedia() {
    return PlaylistModel(
      title: widget.name,
      audioUrl: widget.liveLink,
      id: widget.id,
      avatar: widget.avatar,
      station: widget.station,
      journalist: widget.program,
    );
  }

  Future<void> _generateDominantColor() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.avatar),
        size: const Size(100, 100),
      );
      if (mounted) {
        setState(() {
          dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;
        });
      }
    } catch (e) {
      debugPrint('Error generating dominant color: $e');
    }
  }

  @override
  Widget build(BuildContext context) {


    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor:
            dominantColor?.withOpacity(0.95) ?? Colors.black,
      ),
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      dominantColor?.withOpacity(0.8) ?? Colors.black,
                      Colors.black,
                    ],
                  ),
                ),
              ),

              // Main content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 300.h,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(),
                    ),
                    leading: Container(
                      margin: EdgeInsets.only(left: 13.w, top: 10.h),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22.r,
                        ),
onPressed: () {
  if (context.canPop()) {
    // If there is a history (app was already open), just go back
    context.pop();
  } else {
    // If opened from terminated state, the stack is empty.
    // Force navigation to the Enadamt list page.
    context.go('/home'); 
  }
},                      ),
                    ),
                    actions: [
                      _buildFollowButton(),
                    ],
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.description != null) ...[
                            _buildDescriptionSection(),
                            SizedBox(height: 20.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: widget.avatar,
              child: Stack(
                children: [
                  Container(
                    width: 250.r,
                    height: 250.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.avatar,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[850],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colorscontainer.greenColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[850],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  if (isLive || widget.isProgram)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<PersistentPlayerBloc>()
                              .add(ShowPersistentPlayer(
                                avatar: widget.avatar,
                                name: widget.name,
                                station: widget.station,
                                program: widget.program,
                                liveLink: widget.liveLink,
                              ));
                        },
                        child: Container(
                          height: 60.r,
                          width: 60.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colorscontainer.greenColor,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colorscontainer.greenColor.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Lottie.asset(
                            'assets/play_button.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isLive)
          Positioned(
            top: 20.h,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'LIVE',
                    style: TextUtils.setTextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

 Widget _buildFollowButton() {
  return Padding(
    padding: EdgeInsets.only(right: 16.w),
    child: BlocBuilder<FollowingBloc, FollowingState>(
      builder: (context, state) {
        bool isFollowing = state.status == Status.following ||
            state.status == Status.followRequested;

        return LikeButton(
          size: 42, // better tap target
          isLiked: isFollowing,
          circleColor: CircleColor(
            start: Colors.white,
            end: Colorscontainer.greenColor,
          ),
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.white,
            dotSecondaryColor: Colorscontainer.greenColor,
          ),
          onTap: (isLiked) async =>
              _handleNotificationPermission(isLiked, context),
          likeBuilder: (isLiked) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.25),
                border: Border.all(
                  color: isLiked
                      ? Colors.white // ✅ white stroke when active
                      : Colors.white.withOpacity(0.25),
                  width: isLiked ? 2 : 1.2,
                ),
                boxShadow: [
                  if (isLiked)
                    BoxShadow(
                      color: Colorscontainer.greenColor.withOpacity(0.6),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                CupertinoIcons.bell_fill,
                color: isLiked
                    ? Colorscontainer.greenColor
                    : Colors.white.withOpacity(0.9),
                size: 22.r,
              ),
            );
          },
        );
      },
    ),
  );
}

  // 4. UPDATE _handleNotificationPermission to pass programId and add analytics:
  Future<bool> _handleNotificationPermission(
      bool isLiked, BuildContext context) async {
    var status = await Permission.notification.status;
    
    if (!status.isGranted) {
      // ✨ ADD THIS - Track permission request
      await _analyticsService.logNotificationPermissionRequested('podcast_follow');
      
      final requestStatus = await Permission.notification.request();
      
      // ✨ ADD THIS - Track permission result
      if (requestStatus.isGranted) {
        await _analyticsService.logNotificationPermissionGranted('podcast_follow');
      } else {
        await _analyticsService.logNotificationPermissionDenied('podcast_follow');
      }
      
      if (requestStatus.isPermanentlyDenied) {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
      
      // Update status after request
      status = await Permission.notification.status;
    }

    if (status.isGranted) {
      if (isLiked) {
        // ✨ UPDATED - Add programId and podcastName for analytics
        context.read<FollowingBloc>().add(
              RemoveFollowingPodcast(
                podcastId: widget.id,
                programId: widget.programId,
                podcastName: widget.name, // ✨ ADD THIS
              ),
            );
      } else {
        // ✨ UPDATED - Add programId and podcastName for analytics
        context.read<FollowingBloc>().add(
              FollowPodcastRequested(
                podcastId: widget.id,
                programId: widget.programId,
                podcastName: widget.name, // ✨ ADD THIS
              ),
            );
      }
      return !isLiked;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is required to follow podcasts.'),
          duration: Duration(seconds: 3),
        ),
      );
      return isLiked;
    }
  }
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description!,
          style: TextUtils.setTextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
