// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/match_page_state.dart';
// import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_bloc.dart';
// import '../../../../../../../bloc/mirchaweche/teams/previous&next_matchs/matches_page_event.dart';
// import '../../../../../../../components/getAmharicDay.dart';
// import '../../../../../../../main.dart';
// import '../../../../../../constants/colors.dart';
// import '../../../../../../constants/text_utils.dart';

// class FixituresWidget extends StatefulWidget {
//   final String? TeamId;

//   const FixituresWidget({super.key, required this.TeamId, String? leagueId});

//   @override
//   _FixituresWidgetState createState() => _FixituresWidgetState();
// }

// class _FixituresWidgetState extends State<FixituresWidget> {
//   final ScrollController _scrollController = ScrollController();
//   late Future<List<dynamic>> futureMatches;

//   @override
//   void initState() {
//     super.initState();

//     context
//         .read<MatchesPageBloc>()
//         .add(TeamNextMatchesRequested(widget.TeamId));
//     context.read<MatchesPageBloc>().state.pageCounter = 1;
//   }

//   String _sanitizeMediaUrl(String? url) {
//     if (url == null || url.isEmpty) return '';
//     // Replace any old media subdomain with the current one
//     return url.replaceAll(
//         RegExp(r'media-\d+\.api-sports\.io'), 'media.api-sports.io');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MatchesPageBloc, MatchPageState>(
//         builder: (context, state) {
//       if ((state.status == matchpageStatus.initial ||
//               state.status == matchpageStatus.requested) ||
//           state.matchs.isEmpty) {
//         return Center(child: buildShimmerEffect());
//       } else if (state.status == matchpageStatus.requestSuccess) {
//         final highlights = state.matchs;

//         return ListView.builder(
//           controller: _scrollController,
//           physics: const BouncingScrollPhysics(),
//           itemCount: highlights.length + 1,
//           padding: EdgeInsets.only(bottom: 50.h, top: 10.h, left: 10.w),
//           itemBuilder: (context, index) {
//             if (index == highlights.length) {
//               return const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.grey,
//                   strokeWidth: 0,
//                 ),
//               );
//             }

//             final highlight = highlights[index];
//             String home = '';
//             if (localLanguageNotifier.value == 'am') {
//               home = highlight.homeTeam_am;
//             } else if (localLanguageNotifier.value == 'or') {
//               home = highlight.homeTeam_or;
//             } else if (localLanguageNotifier.value == 'so') {
//               home = highlight.homeTeam_so;
//             } else if (localLanguageNotifier.value == 'tr') {
//               home = highlight.homeTeam_ti;
//             } else {
//               home = highlight.homeTeam;
//             }

//             String away = '';
//             if (localLanguageNotifier.value == 'am') {
//               away = highlight.awayTeam_am;
//             } else if (localLanguageNotifier.value == 'or') {
//               away = highlight.awayTeam_or;
//             } else if (localLanguageNotifier.value == 'so') {
//               away = highlight.awayTeam_so;
//             } else if (localLanguageNotifier.value == 'tr') {
//               away = highlight.awayTeam_ti;
//             } else {
//               away = highlight.awayTeam;
//             }

//             String dateTimeString = highlight.date.toString();
//             String monthDay = getAmharicMonthName(
//                 dateTimeString); // Localized date formatting
//             return Padding(
//               padding: const EdgeInsets.only(left: 0, right: 10, bottom: 10),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5.0),
//                   color: Theme.of(context).colorScheme.surface,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Theme.of(context).colorScheme.shadow,
//                       spreadRadius: 0,
//                       blurRadius: 4,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Text(
//                             monthDay,
//                             textAlign: TextAlign.left,
//                             style: TextUtils.setTextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                               fontSize: 13.0,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Column(
//                             children: [
//                               CachedNetworkImage(
//                                 height: 20,
//                                 width: 20,
//                                 imageUrl: _sanitizeMediaUrl(
//                                     highlight.hometeamlogo.toString()),
//                                 placeholder: (context, url) =>
//                                     const CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     const Icon(Icons.error),
//                               ),
//                               SizedBox(height: 5.h),
//                               CachedNetworkImage(
//                                 height: 20,
//                                 width: 20,
//                                 imageUrl: _sanitizeMediaUrl(
//                                     highlight.awayteamlogo.toString()),
//                                 placeholder: (context, url) =>
//                                     const CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     const Icon(Icons.error),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     home,
//                                     textAlign: TextAlign.left,
//                                     style: TextUtils.setTextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onSurface,
//                                       fontSize: 14.0,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 5.h),
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Text(
//                                     away,
//                                     textAlign: TextAlign.left,
//                                     style: TextUtils.setTextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onSurface,
//                                       fontSize: 14.0,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 highlight.scoreHome.toString(),
//                                 textAlign: TextAlign.left,
//                                 style: TextUtils.setTextStyle(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                   fontSize: 13.0,
//                                 ),
//                               ),
//                               SizedBox(height: 5.h),
//                               Text(
//                                 highlight.scoreAway.toString(),
//                                 textAlign: TextAlign.left,
//                                 style: TextUtils.setTextStyle(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                   fontSize: 13.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 highlight.status,
//                                 textAlign: TextAlign.left,
//                                 style: TextUtils.setTextStyle(
//                                   color:
//                                       Theme.of(context).colorScheme.onSurface,
//                                   fontSize: 13.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4.h),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }
//       return Container();
//     });
//   }

//   Widget buildShimmerEffect() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey,
//       highlightColor: const Color.fromARGB(255, 194, 193, 193),
//       child: ListView.builder(
//         itemCount: 12, // Total number of shimmering items
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.all(Radius.circular(5)),
//                 color: Colorscontainer.greyShade,
//               ),
//               height: 50,
//               width: double.infinity,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
