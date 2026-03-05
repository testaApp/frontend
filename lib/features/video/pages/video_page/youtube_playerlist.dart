// import 'dart:async'; // Import the dart:async library for Timer

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import '../../../components/timeFormatter.dart';
// import '../../../models/video.dart';
// import '../../constants/colors.dart';
// import 'custom_youtube_controls.dart';

// class YouTube extends StatefulWidget {
//   final List<VideosModel> highlights;
//   final int videoindex;
//   final String category;
//   final String date;

//   const YouTube({
//     super.key,
//     required this.highlights,
//     required this.videoindex,
//     required this.category,
//     required this.date,
//   });

//   @override
//   State<YouTube> createState() => _YouTubeState();
// }

// class _YouTubeState extends State<YouTube> {
//   late YoutubePlayerController _controller;
//   VideosModel? _currentVideo;
//   int? _selectedVideoIndex;
//   bool _isFullScreen = false;
//   bool _canPlayVideo = true;
//   bool _controlsVisible = true; // Track visibility of controls
//   bool _isLoading = true; // Track loading state
//   Timer? _hideControlsTimer; // Timer to hide controls

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//     _selectedVideoIndex = widget.videoindex;
//     _startHideControlsTimer(); // Start timer to hide controls
//   }

//   void _initializePlayer() {
//     _currentVideo = widget.highlights[widget.videoindex];
//     _controller = YoutubePlayerController(
//       initialVideoId: _currentVideo!.youtubeHighlightVid,
//       flags: const YoutubePlayerFlags(
//         mute: false,
//         autoPlay: true,
//         disableDragSeek: true, // Disable seeking
//         hideControls: true, // Hide default controls
//       ),
//     )..addListener(_listener);

//     _canPlayVideo = true;
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_listener);
//     _controller.dispose();
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.white,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ));
//     _hideControlsTimer?.cancel(); // Cancel the timer
//     super.dispose();
//   }

//   void _listener() {
//     if (_controller.value.errorCode != 0) {
//       setState(() {
//         _canPlayVideo = false;
//         _isLoading = false; // Stop buffering indicator when there's an error
//       });
//     }

//     if (_controller.value.isFullScreen != _isFullScreen) {
//       setState(() {
//         _isFullScreen = _controller.value.isFullScreen;
//       });
//     }

//     if (_controller.value.playerState == PlayerState.buffering ||
//         _controller.value.playerState == PlayerState.unknown) {
//       setState(() {
//         _isLoading = true;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }

//     setState(() {}); // Rebuild to reflect changes
//   }

//   void _setSelectedVideo(int index) {
//     if (index != _selectedVideoIndex) {
//       setState(() {
//         _selectedVideoIndex = index;
//         _currentVideo = widget.highlights[index];
//         _controller.load(_currentVideo!.youtubeHighlightVid);
//         _canPlayVideo = true;
//         _isLoading = true; // Assume loading when a new video is loaded
//       });
//     }
//   }

//   Future<void> _onPopInvoked(bool didPop) async {
//     if (didPop) return;

//     if (_isFullScreen) {
//       _controller.toggleFullScreenMode();
//       return;
//     }

//     Navigator.of(context).pop();
//   }

//   Future<void> _redirectToYouTube(String videoId) async {
//     final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   void _startHideControlsTimer() {
//     _hideControlsTimer?.cancel();
//     _hideControlsTimer = Timer(const Duration(seconds: 3), () {
//       setState(() {
//         _controlsVisible = false;
//       });
//     });
//   }

//   void _onScreenTap() {
//     setState(() {
//       _controlsVisible = !_controlsVisible;
//     });
//     if (_controlsVisible) {
//       _startHideControlsTimer(); // Restart timer to hide controls
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _onScreenTap, // Detect screen taps to show/hide controls
//       child: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle(
//           statusBarColor: Colors.black.withOpacity(0),
//           systemNavigationBarColor: Colors.black.withOpacity(0),
//         ),
//         child: PopScope(
//           canPop: false,
//           onPopInvoked: _onPopInvoked,
//           child: Scaffold(
//             body: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _isFullScreen
//                     ? Expanded(
//                         child: Stack(
//                           children: [
//                             YoutubePlayer(
//                               controller: _controller,
//                               showVideoProgressIndicator:
//                                   true, // Show buffering progress indicator
//                               aspectRatio: 4 / 3,
//                               bufferIndicator:
//                                   const CircularProgressIndicator(),
//                               onReady: () {
//                                 _controller.addListener(() {
//                                   if (_controller.value.isFullScreen) {
//                                     _controller.play();
//                                   }
//                                 });
//                               },
//                             ),
//                             if (!_canPlayVideo)
//                               Positioned.fill(
//                                 child: Container(
//                                   color: Colors.black.withOpacity(0.8),
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(height: 20.h),
//                                         ElevatedButton(
//                                           onPressed: () => _redirectToYouTube(
//                                               _currentVideo!
//                                                   .youtubeHighlightVid),
//                                           child: const Text('Play on YouTube'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             if (_isLoading && _canPlayVideo)
//                               const Positioned.fill(
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               ),
//                             if (!_isLoading)
//                               Positioned.fill(
//                                 child: CustomYoutubeControls(
//                                   _controller,
//                                   _controlsVisible,
//                                 ), // Use custom controls
//                               ),
//                           ],
//                         ),
//                       )
//                     : Stack(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Stack(
//                                 children: [
//                                   YoutubePlayer(
//                                     controller: _controller,
//                                     showVideoProgressIndicator: true,
//                                     aspectRatio: 16 / 9,
//                                     bufferIndicator:
//                                         const CircularProgressIndicator(),
//                                     onReady: () {
//                                       _controller.addListener(() {
//                                         if (_controller.value.isFullScreen) {
//                                           _controller.play();
//                                         }
//                                       });
//                                     },
//                                   ),
//                                   if (!_canPlayVideo)
//                                     Positioned.fill(
//                                       child: Container(
//                                         color: Colors.black.withOpacity(0.8),
//                                         child: Center(
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               SizedBox(height: 20.h),
//                                               ElevatedButton(
//                                                 onPressed: () =>
//                                                     _redirectToYouTube(
//                                                         _currentVideo!
//                                                             .youtubeHighlightVid),
//                                                 child: const Text(
//                                                     'Play on YouTube'),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   if (_isLoading && _canPlayVideo)
//                                     const Positioned.fill(
//                                       child: Center(
//                                         child: CircularProgressIndicator(),
//                                       ),
//                                     ),
//                                   if (!_isLoading)
//                                     Positioned.fill(
//                                       child: CustomYoutubeControls(
//                                         _controller,
//                                         _controlsVisible,
//                                       ), // Use custom controls
//                                     ),
//                                 ],
//                               ),
//                               if (_controller.value.isReady &&
//                                   _controller.metadata.duration !=
//                                       Duration.zero) // Check for valid duration
//                                 LinearProgressIndicator(
//                                   value: _controller.value.position.inSeconds /
//                                       _controller.metadata.duration.inSeconds,
//                                   backgroundColor: Colors.transparent,
//                                   valueColor:
//                                       const AlwaysStoppedAnimation<Color>(
//                                           Colors.transparent),
//                                 ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(15, 10, 5, 5),
//                                     child: Text(
//                                       _currentVideo?.youtubeHighlightVtitle ??
//                                           '',
//                                       style: const TextStyle(
//                                         fontSize: 16.0,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(15, 5, 5, 5),
//                                     child: Text(
//                                       _currentVideo?.youtubeHighlightDate
//                                                   .isNotEmpty ??
//                                               false
//                                           ? formatTimeForNews(_currentVideo!
//                                               .youtubeHighlightDate)
//                                           : '',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Positioned(
//                             top: 25.h,
//                             left: 13.w,
//                             child: CircleAvatar(
//                               radius: 15.sp,
//                               backgroundColor:
//                                   Colorscontainer.greyShade.withOpacity(0.4),
//                               child: Align(
//                                 alignment: Alignment.center,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     context.pop();
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4),
//                                     child: Icon(
//                                       Icons.arrow_back,
//                                       color: Colorscontainer.greenColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                 if (!_isFullScreen)
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(vertical: 5),
//                       itemCount: widget.highlights.length,
//                       itemBuilder: (context, index) {
//                         if (index == _selectedVideoIndex) return Container();
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             GestureDetector(
//                               onTap: () => _setSelectedVideo(index),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   widget.highlights[index]
//                                       .youtubeHighlightThumbnail,
//                                   fit: BoxFit.fill,
//                                   width: double.infinity,
//                                   height: 200.h,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: double.infinity,
//                                       height: 200.h,
//                                       color: Colors.white,
//                                       child: Center(
//                                         child: Image.asset(
//                                           'assets/youtube.png', // Make sure this path is correct
//                                           width:
//                                               50.w, // Adjust the size as needed
//                                           height: 50.h,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(15, 10, 5, 5),
//                               child: Text(
//                                 widget.highlights[index].youtubeHighlightVtitle,
//                                 style: const TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
//                               child: Text(
//                                 widget.highlights[index].youtubeHighlightDate
//                                         .isNotEmpty
//                                     ? formatTimeForNews(widget
//                                         .highlights[index].youtubeHighlightDate)
//                                     : '',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
