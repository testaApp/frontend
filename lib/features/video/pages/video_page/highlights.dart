// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import '../../../bloc/video/videoEvent.dart';
// import '../../../bloc/video/videoState.dart';
// import '../../../bloc/video/video_bloc.dart';
// import '../../../localization/demo_localization.dart';
// import '../../constants/colors.dart';
// import '../../constants/text_utils.dart';

// import 'youtube_playerlist.dart';

// class HighlightsNewsPage extends StatefulWidget {
//   const HighlightsNewsPage({super.key});

//   @override
//   State<HighlightsNewsPage> createState() => _HighlightsNewsPageState();
// }

// class _HighlightsNewsPageState extends State<HighlightsNewsPage> {
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _scrollController1 = ScrollController();
//   final ScrollController _scrollController2 = ScrollController();

//   int currentTab = 0; // Set the initial tab to the first tab

//   void _onTabChanged(int index) {
//     setState(() {
//       currentTab = index;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     context.read<VideoBloc>().add(VideosRequested(category: ''));

//     _scrollController.addListener(_scrollListener);
//     _scrollController1.addListener(_scrollListener1);
//     _scrollController2.addListener(_scrollListener2);
//   }

//   void _pageRefresh() {
//     context.read<VideoBloc>().add(VideosRequested(category: ''));
//   }

//   void _scrollListener() {
//     final currentPosition = _scrollController.position.pixels;
//     final maxScrollExtent = _scrollController.position.maxScrollExtent;
//     final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100 &&
//         context.read<VideoBloc>().state.status != videoStatus.requested;

//     if (shouldLoadNextPage) {
//       // Implement pagination logic if needed
//     }
//   }

//   void _scrollListener1() {
//     final currentPosition = _scrollController1.position.pixels;
//     final maxScrollExtent = _scrollController1.position.maxScrollExtent;
//     final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100 &&
//         context.read<VideoBloc>().state.status != videoStatus.requested;

//     if (shouldLoadNextPage) {
//       // Implement pagination logic if needed
//     }
//   }

//   void _scrollListener2() {
//     final currentPosition = _scrollController2.position.pixels;
//     final maxScrollExtent = _scrollController2.position.maxScrollExtent;
//     final shouldLoadNextPage = currentPosition >= maxScrollExtent - 100 &&
//         context.read<VideoBloc>().state.status != videoStatus.requested;

//     if (shouldLoadNextPage) {
//       // Implement pagination logic if needed
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildCategorySection(
//                     context,
//                     'premier league',
//                     DemoLocalizations.premierLeagueShort,
//                     _scrollController1,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'champions league',
//                     DemoLocalizations.championsLeagueShort,
//                     _scrollController,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'ethiopia',
//                     DemoLocalizations.ethiopianPremierLeagueShort,
//                     _scrollController,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'laliga',
//                     DemoLocalizations.spainLaligaShort,
//                     _scrollController2,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'germen',
//                     DemoLocalizations.bundesLigaShort,
//                     _scrollController,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'italy',
//                     DemoLocalizations.italySerieAShort,
//                     _scrollController,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'saudi',
//                     DemoLocalizations.saudiProLeagueShort,
//                     _scrollController,
//                   ),
//                   _buildCategorySection(
//                     context,
//                     'other',
//                     DemoLocalizations.others,
//                     _scrollController,
//                   ),
//                   SizedBox(height: 40.h),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategorySection(BuildContext context, String category,
//       String title, ScrollController scrollController) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 3.0),
//           child: Text(
//             title,
//             style: TextUtils.setTextStyle(
//                 fontWeight: FontWeight.w300,
//                 color: Colorscontainer.greenColor,
//                 fontSize: 15.sp),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.only(left: 7),
//           height: 160.h,
//           child: BlocBuilder<VideoBloc, VideosState>(builder: (context, state) {
//             if ((state.status == videoStatus.initial ||
//                     state.status == videoStatus.requested) ||
//                 state.highlights.isEmpty) {
//               return Shimmer.fromColors(
//                 baseColor: Theme.of(context).colorScheme.secondary,
//                 highlightColor: Colors.grey[100]!,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 5, // Number of shimmer items
//                   itemBuilder: (context, index) {
//                     return Container(
//                       margin:
//                           EdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
//                       width: 220.h,
//                       height: 150.h,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.secondary,
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             } else if (state.status == videoStatus.requestSuccess) {
//               final highlights = category == 'other'
//                   ? state.highlights
//                       .where((video) => ![
//                             'premier league',
//                             'champions league',
//                             'laliga',
//                             'ethiopia',
//                             'germen'
//                           ].contains(video.catagory))
//                       .toList()
//                   : state.highlights
//                       .where((video) => video.catagory == category)
//                       .toList();

//               return RefreshIndicator(
//                 onRefresh: () async {
//                   _pageRefresh();
//                 },
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 160.h,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         controller: scrollController,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: highlights.length - 1,
//                         itemBuilder: (context, index) {
//                           if (index == highlights.length &&
//                               highlights.length != 1) {
//                             return const Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.grey,
//                                 strokeWidth: 5,
//                               ),
//                             );
//                           }

//                           final highlight = highlights[index];
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => YouTube(
//                                       highlights:
//                                           highlights, // Replace with your actual list of highlights
//                                       videoindex: index,
//                                       category: title,
//                                       date: DateTime.now().toString()),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10.0)),
//                               padding: EdgeInsets.symmetric(horizontal: 7.w),
//                               child: Column(
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0),
//                                         child: CachedNetworkImage(
//                                           imageUrl: YoutubePlayer.getThumbnail(
//                                             videoId:
//                                                 highlight.youtubeHighlightVid,
//                                           ),
//                                           width: 220.h,
//                                           height: 150.h,
//                                           fit: BoxFit.cover,
//                                           errorWidget:
//                                               (context, error, stackTrace) {
//                                             return Container(
//                                               width: double.infinity,
//                                               height: 200.h,
//                                               color: Colors.white,
//                                               child: Center(
//                                                 child: Image.asset(
//                                                   'assets/youtube.png', // Make sure this path is correct
//                                                   width: 50
//                                                       .w, // Adjust the size as needed
//                                                   height: 50.h,
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       Positioned(
//                                         bottom: 0,
//                                         left: 0,
//                                         right: 0,
//                                         child: Container(
//                                           padding: const EdgeInsets.all(8.0),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 const BorderRadius.only(
//                                               bottomLeft: Radius.circular(10.0),
//                                               bottomRight:
//                                                   Radius.circular(10.0),
//                                             ),
//                                             gradient: LinearGradient(
//                                               begin: Alignment.bottomLeft,
//                                               end: Alignment.topRight,
//                                               colors: [
//                                                 Colors.black.withOpacity(0.8),
//                                                 Colors.transparent,
//                                               ],
//                                             ),
//                                           ),
//                                           child: Text(
//                                             highlight.youtubeHighlightVtitle
//                                                 .toString(),
//                                             textAlign: TextAlign.left,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 15.0,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         right: 8,
//                                         bottom: 8,
//                                         child: Image.asset(
//                                           'assets/youtube.png',
//                                           width: 30.h,
//                                           height: 30.h,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 4.h),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return Container();
//           }),
//         ),
//       ],
//     );
//   }
// }
