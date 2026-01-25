// import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:text_scroll/text_scroll.dart';

// import '../../../application/testing/bloc/audio_bloc.dart';
// import '../../../application/testing/bloc/audio_event.dart';
// import '../../../application/testing/bloc/audio_state.dart';
// import '../../../services/notifiers/play_button_notifier.dart';
// import '../../../services/notifiers/progress_notifier.dart';
// import '../../../services/page_manager.dart';
// import '../../../services/service_locator.dart';
// import '../../constants/colors.dart';
// import 'audio_play.dart';

// class NowPlaying extends StatefulWidget {
//   const NowPlaying({super.key});

//   @override
//   State<NowPlaying> createState() => _NowPlayingState();
// }

// class _NowPlayingState extends State<NowPlaying>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   final pageManager = getIt<PageManager>();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AudioBloc, AudioState>(
//       builder: (context, state) {
//         return Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 10),
//                 Container(
//                   width: 360.w,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.8),
//                     border: const Border(
//                         top: BorderSide(width: 0.4, color: Colors.grey)),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       ValueListenableBuilder<String>(
//                           valueListenable:
//                               pageManager.currentSongAvatarNotifier,
//                           builder: (_, avatar, __) {
//                             return GestureDetector(
//                                 onTap: () {
//                                   Scaffold.of(context).showBottomSheet(
//                                       transitionAnimationController:
//                                           _controller,
//                                       backgroundColor: Colorscontainer
//                                           .greenColor, (context) {
//                                     return AudioPlaying(avatar: avatar);
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding: EdgeInsets.fromLTRB(5.w, 0, 0, 0),
//                                   child: SizedBox(
//                                     height: 50.w,
//                                     width: 50.w,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(10),
//                                       child: CachedNetworkImage(
//                                         imageUrl: avatar,
//                                         width: 54.w,
//                                         fit: BoxFit.contain,
//                                         errorWidget: (context, url, error) =>
//                                             const Icon(
//                                                 Icons.network_locked_rounded),
//                                         placeholder: (context, url) => Icon(
//                                           Icons.music_note_sharp,
//                                           color: Colorscontainer.greenColor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ));
//                           }),
//                       const Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Align(
//                               alignment: Alignment.centerLeft,
//                               child: TitleWgt()),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               AudioControlButtons(),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class TitleWgt extends StatelessWidget {
//   const TitleWgt({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<String>(
//       valueListenable: pageManager.currentSongTitleNotifier,
//       builder: (_, title, __) {
//         return SizedBox(
//             height: 15.h,
//             width: 275.w,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 // ),
//                 ValueListenableBuilder(
//                     valueListenable: pageManager.currentStationNotifier,
//                     builder: (_, station, __) {
//                       return Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 4.w),
//                         child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               station,
//                               style: TextStyle(
//                                   fontSize: 14.sp, color: Colors.white),
//                             )),
//                       );
//                     }),
//                 Expanded(
//                   child: TextScroll(
//                     title,
//                     velocity: const Velocity(pixelsPerSecond: Offset(13, 0)),
//                     style: TextStyle(fontSize: 14.sp, color: Colors.white),
//                     textAlign: TextAlign.right,
//                     selectable: true,
//                   ),
//                 ),
//               ],
//             ));
//       },
//     );
//   }
// }

// class AudioControlButtons extends StatelessWidget {
//   const AudioControlButtons({super.key, this.big = false});
//   final bool big;

//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return BlocBuilder<AudioBloc, AudioState>(
//       builder: (context, state) {
//         return SizedBox(
//           width: 240.w,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   width: 170.w,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       PlayButton(big: big),
//                     ],
//                   ),
//                 ),
//               ),
//               big == true
//                   ? const SizedBox.shrink()
//                   : IconButton(
//                       onPressed: () async {
//                         pageManager.pause();
//                         pageManager.stop();
//                         context.read<AudioBloc>().add(setStopped());
//                       },
//                       icon: Align(
//                           alignment: Alignment.centerRight,
//                           child: Image.asset(
//                             'assets/stop.png',
//                             color: Colors.grey,
//                             width: 22.r,
//                           )))
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class PlayButton extends StatelessWidget {
//   const PlayButton({super.key, this.big = false});
//   final bool big;

//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<ButtonState>(
//       valueListenable: pageManager.playButtonNotifier,
//       builder: (_, value, __) {
//         switch (value) {
//           case ButtonState.loading:
//             return SizedBox(
//               width: big == true ? 55.r : 30.r,
//               height: big == true ? 42.r : 30.r,
//               child: big
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : SizedBox(
//                       width: 24.w,
//                       height: 24.w,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       )),
//             );
//           case ButtonState.paused:
//             return GestureDetector(
//               onTap: pageManager.play,
//               child: SizedBox(
//                 width: big == true ? 75.0.w : 30.w,
//                 child: Image.asset(
//                   'assets/playmusic.png',
//                   color: Colors.white,
//                 ),
//               ),
//             );
//           case ButtonState.playing:
//             return GestureDetector(
//               onTap: pageManager.pause,
//               child: SizedBox(
//                 width: big == true ? 75.0.w : 30.w,
//                 child: Image.asset(
//                   'assets/pause.png',
//                   color: Colors.white,
//                 ),
//               ),
//             );
//           case ButtonState.stopped:
//             return GestureDetector(
//               onTap: pageManager.play,
//               child: SizedBox(
//                 width: big == true ? 75.0.w : 30.w,
//                 child: Image.asset(
//                   'assets/playmusic.png',
//                   color: Colors.white,
//                 ),
//               ),
//             );
//         }
//       },
//     );
//   }
// }
