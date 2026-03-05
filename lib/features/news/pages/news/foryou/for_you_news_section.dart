// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:blogapp/localization/demo_localization.dart';
// import 'package:blogapp/models/news.dart';
// import 'package:blogapp/shared/constants/text_utils.dart';
// import 'horizontal_scroll_for_you.dart';

// class NewsCategorySection extends StatelessWidget {
//   static const int initialNewsCount = 3;

//   final String title;
//   final String? imageUrl;
//   final Widget Function(String imageUrl)? imageBuilder;
//   final int newsCount;
//   final bool isExpanded;
//   final bool hasMore;
//   final VoidCallback onExpandTap;
//   final List<News> newsList;

//   const NewsCategorySection({
//     super.key,
//     required this.title,
//     this.imageUrl,
//     this.imageBuilder,
//     required this.newsCount,
//     required this.isExpanded,
//     required this.hasMore,
//     required this.onExpandTap,
//     required this.newsList,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 if (imageUrl != null)
//                   imageBuilder?.call(imageUrl!) ??
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(2),
//                         child: CachedNetworkImage(
//                           imageUrl: imageUrl!,
//                           width: 24,
//                           height: 24,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Container(
//                             color: Colors.grey[200],
//                           ),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.error),
//                         ),
//                       ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextUtils.setTextStyle(
//                           themeData: Theme.of(context),
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         '$newsCount ${DemoLocalizations.news}', // Updated to use DemoLocalizations
//                         style: TextUtils.setTextStyle(
//                           themeData: Theme.of(context),
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // News List
//           SizedBox(
//             height: 350,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               itemCount: newsList.length + (hasMore && !isExpanded ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == newsList.length) {
//                   return _buildShowMoreCard(context);
//                 }
//                 return SizedBox(
//                   width: 300,
//                   child: HorizontalNewsCard(
//                     news: newsList[index],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShowMoreCard(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       child: InkWell(
//         onTap: onExpandTap,
//         child: Center(
//           child: CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.arrow_forward,
//               size: 20,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
