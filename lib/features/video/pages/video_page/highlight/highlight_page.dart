// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../main.dart';
// import '../highlights.dart';

// class HighlightsMainPage extends StatelessWidget {
//   const HighlightsMainPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: AnnotatedRegion(
//         value: const SystemUiOverlayStyle(
//           statusBarBrightness: Brightness.dark,
//         ),
//         child: Scaffold(
//           body: ValueListenableBuilder(
//             valueListenable: localLanguageNotifier,
//             builder: (context, language, child) {
//               return Column(
//                 children: [
//                   Container(
//                     color: Theme.of(context).colorScheme.surface,
//                     child: Column(
//                       children: [
//                         SizedBox(height: 5.h),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 15.w),
//                                 child: Image.asset(
//                                   'assets/testa_appbar.png',
//                                   height: 30.h,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: HighlightsNewsPage(
//                       key: ValueKey(language),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
