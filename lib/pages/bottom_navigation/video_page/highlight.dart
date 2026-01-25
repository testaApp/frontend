// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String? dateString;
//   final int? fixtureId;
//   final String? VideoId;
//   final String? VideoTitle;
//   final String? Thumbnail;
//   const VideoPlayerScreen({
//     super.key,
//     required this.dateString,
//     required this.fixtureId,
//     required this.VideoId,
//     required this.VideoTitle,
//     required this.Thumbnail,
//   });

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Image.network(
//             'https://img.youtube.com/vi/4EtwfQRjGqo/maxresdefault.jpg'),
//         IconButton(
//           icon:
//               const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     YouTubePlayerPage(videoId: widget.VideoId.toString()),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class YouTubePlayerPage extends StatefulWidget {
//   final String videoId;

//   const YouTubePlayerPage({super.key, required this.videoId});

//   @override
//   _YouTubePlayerPageState createState() => _YouTubePlayerPageState();
// }

// class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: ' https://www.youtube.com/watch?v=4EtwfQRjGqo',
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('YouTube Player'),
//       ),
//       body: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//       ),
//     );
//   }
// }
