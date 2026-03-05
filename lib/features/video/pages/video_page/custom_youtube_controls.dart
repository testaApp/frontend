// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import '../../constants/text_utils.dart';

// class CustomYoutubeControls extends StatefulWidget {
//   final YoutubePlayerController controller;
//   final bool controlsVisible;

//   const CustomYoutubeControls(this.controller, this.controlsVisible,
//       {super.key});

//   @override
//   _CustomYoutubeControlsState createState() => _CustomYoutubeControlsState();
// }

// class _CustomYoutubeControlsState extends State<CustomYoutubeControls> {
//   bool _isDragging = false;

//   @override
//   Widget build(BuildContext context) {
//     final videoPosition = widget.controller.value.position.inSeconds.toDouble();
//     final videoDuration =
//         widget.controller.value.metaData.duration.inSeconds.toDouble();

//     return widget.controlsVisible
//         ? Stack(
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (widget.controller.value.isPlaying) {
//                         widget.controller.pause();
//                       } else {
//                         widget.controller.play();
//                       }
//                     });
//                   },
//                   child: Icon(
//                     widget.controller.value.isPlaying
//                         ? Icons.pause_rounded
//                         : Icons.play_arrow_rounded,
//                     size: 80,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             _formatDuration(widget.controller.value.position),
//                             style: TextUtils.setTextStyle(color: Colors.white),
//                           ),
//                           Expanded(
//                             child: videoDuration > 0
//                                 ? Slider(
//                                     activeColor: Colors.red,
//                                     inactiveColor: Colors.white30,
//                                     value: videoPosition,
//                                     min: 0.0,
//                                     max: videoDuration,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         _isDragging = true;
//                                         widget.controller.seekTo(
//                                             Duration(seconds: value.toInt()));
//                                       });
//                                     },
//                                     onChangeEnd: (value) {
//                                       setState(() {
//                                         _isDragging = false;
//                                       });
//                                     },
//                                   )
//                                 : Container(), // Show an empty container if video duration is zero
//                           ),
//                           Text(
//                             _formatDuration(
//                                 widget.controller.value.metaData.duration -
//                                     widget.controller.value.position),
//                             style: TextUtils.setTextStyle(color: Colors.white),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               widget.controller.value.isFullScreen
//                                   ? Icons.fullscreen_exit
//                                   : Icons.fullscreen,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               widget.controller.toggleFullScreenMode();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         : const SizedBox.shrink();
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$twoDigitMinutes:$twoDigitSeconds';
//   }
// }
