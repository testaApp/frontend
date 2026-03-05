import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:blogapp/state/application/persistent_player/persistent_player_bloc.dart';
import 'package:blogapp/state/application/persistent_player/persistent_player_event.dart';
import 'package:blogapp/models/playlist/playlist_model.dart';
import 'package:blogapp/services/page_manager.dart';
import 'package:blogapp/services/service_locator.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/enadamt/pages/enadamt/program_detail_page.dart';

class PodcastCard extends StatefulWidget {
  const PodcastCard({
    super.key,
    required this.name,
    required this.station,
    required this.avatar,
    required this.program,
    required this.liveLink,
    required this.isLive,
    this.failure = false,
    required this.rssLink,
    this.description,
    required this.id,
    required this.programId,
  });

  final String name;
  final String station;
  final String avatar;
  final String program;
  final String liveLink;
  final bool isLive;
  final bool failure;
  final List<String> rssLink;
  final String? description;
  final String id;
  final String programId;

  @override
  _PodcastCardState createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final PageManager pageManager;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    pageManager = getIt<PageManager>();
    pageManager.init();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: widget.failure
                  ? null
                  : () {Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Program(
      avatar: widget.avatar,
      name: widget.name,
      program: widget.program,
      rssLink: widget.rssLink,
      description: widget.description,
      id: widget.id,
      time: const [],
      liveLink: widget.liveLink,
      station: widget.station,          // ← you have this field now
      isProgram: widget.isLive,
      programId: widget.programId,             // or better: add programId field to PodcastCard
    ),
  ),
);
                    },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Image
                    Hero(
                      tag: widget.avatar,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: CachedNetworkImage(
                          imageUrl: widget.avatar,
                          height: 170.r,
                          width: 180.r,
                          fit: BoxFit.fill,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colorscontainer.greenColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),

                    // Live Indicator & Play Button
                    if (widget.isLive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (widget.isLive)
                      Positioned(
                        left: 10.w,
                        bottom: 10.h,
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
                            height: 45.r,
                            width: 45.r,
                            decoration: BoxDecoration(
                              color: Colorscontainer.greenColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colorscontainer.greenColor
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Lottie.asset(
                              'assets/play_button.json',
                              height: 45.r,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                    if (widget.isLive)
                      Positioned(
                        right: 10.w,
                        top: 10.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 6.r,
                                width: 6.r,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'LIVE',
                                style: TextUtils.setTextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Title and Program Info
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Column(
                children: [
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.program,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextUtils.setTextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
