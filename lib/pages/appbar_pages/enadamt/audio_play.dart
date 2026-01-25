// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:palette_generator/palette_generator.dart';

// import '../../../application/testing/bloc/audio_bloc.dart';
// import '../../../application/testing/bloc/audio_state.dart';
// import '../../../application/volume_bloc/volume_bloc.dart';
// import '../../../application/volume_bloc/volume_event.dart';
// import '../../../application/volume_bloc/volume_state.dart';
// import '../../../services/page_manager.dart';
// import '../../../services/service_locator.dart';
// import '../../../util/baseUrl.dart';
// import '../../../widgets/artist.dart';
// import '../../../widgets/progressbar.dart';
// import '../../../widgets/title.dart';
// import '../../constants/colors.dart';
// import 'music_player.dart';

// class AudioPlaying extends StatefulWidget {
//   const AudioPlaying({super.key, this.avatar = '', this.journalist = ''});
//   final String avatar;
//   final String journalist;

//   @override
//   State<AudioPlaying> createState() => _AudioPlayingState();
// }

// class _AudioPlayingState extends State<AudioPlaying> {
//   Color? dominantColor;
//   String url = BaseUrl().url;

//   Future<void> _generateDominantColor() async {
//     final PaletteGenerator paletteGenerator =
//         await PaletteGenerator.fromImageProvider(
//             timeout: const Duration(seconds: 20),
//             CachedNetworkImageProvider(
//               widget.avatar,
//               errorListener: (error) => const CircleAvatar(
//                 backgroundColor: Colors.grey,
//                 child: Text('', overflow: TextOverflow.ellipsis),
//               ),
//             ),
//             size: const Size(100, 100));

//     setState(() {
//       dominantColor = paletteGenerator.dominantColor?.color;
//     });
//   }

//   @override
//   void initState() {
//     _generateDominantColor();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
//       child: Container(
//         height: 620.h,
//         child: BlocBuilder<AudioBloc, AudioState>(
//           builder: (context, state) {
//             return Container(
//               decoration: BoxDecoration(color: dominantColor),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(height: 12.h),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       height: 5,
//                       width: 50.w,
//                       decoration: BoxDecoration(
//                           color: Colors.grey,
//                           borderRadius: BorderRadius.circular(5)),
//                     ),
//                   ),
//                   SizedBox(height: 30.h),
//                   SizedBox(
//                     width: 240.sp,
//                     height: 260.sp,
//                     child: ValueListenableBuilder<String>(
//                       valueListenable: pageManager.currentSongAvatarNotifier,
//                       builder: (_, avatar, __) {
//                         return ClipRRect(
//                           borderRadius: BorderRadius.circular(25.w),
//                           child: CachedNetworkImage(
//                             imageUrl: '$avatar',
//                             fit: BoxFit.fitWidth,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 30.h),
//                   SizedBox(width: 280.w, child: const ArtistWidget()),
//                   SizedBox(width: 280.w, child: const TitleWidget()),
//                   SizedBox(height: 30.h),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 40.w),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const PlayButton(big: true),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 50.h),
//                   SizedBox(
//                     width: 280.w,
//                     child: BlocBuilder<VolumeBloc, VolumeState>(
//                       builder: (context, state) {
//                         return Row(
//                           children: [],
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
