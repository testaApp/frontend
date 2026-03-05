// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../../bloc/availableSeasons/available_seasons_bloc.dart';
// import '../../bloc/knockout/Knock_out_event.dart';
// import '../../bloc/knockout/Knock_out_state.dart';
// import '../../bloc/knockout/Knockout_bloc.dart';
// import '../../domain/player/playerProfile.dart';
// import 'package:blogapp/localization/demo_localization.dart';
// import '../bottom_navigation/standing/leagues_page/knockout/final.dart';
// import '../bottom_navigation/standing/leagues_page/pagedown/quarterfinal.dart';
// import '../bottom_navigation/standing/leagues_page/pagedown/round16.dart';
// import '../bottom_navigation/standing/leagues_page/pagedown/semi_final.dart';
// import '../bottom_navigation/standing/leagues_page/pagedown/thirdplace.dart';
// import '../bottom_navigation/standing/leagues_page/pageup/quarter_final.dart';
// import '../bottom_navigation/standing/leagues_page/pageup/round_16.dart';
// import '../bottom_navigation/standing/leagues_page/pageup/semi_final.dart';
// import 'package:blogapp/shared/constants/colors.dart';
// import 'package:blogapp/shared/constants/text_utils.dart';

// String generateImageFromId(dynamic id) {
//   return 'https://media.api-sports.io/football/teams/39.png';
// }

// class KnockoutPage extends StatelessWidget {
//   final int leagueId;

//   KnockoutPage({required this.leagueId});

//   @override
//   Widget build(BuildContext context) {
//     // Fetch the current season from AvailableSeasonsBloc
//     String? currentSeasonString =
//         context.read<AvailableSeasonsBloc>().state.currentSeason;
//     int? season =
//         currentSeasonString != null ? int.tryParse(currentSeasonString) : null;

//     return BlocProvider(
//       create: (context) =>
//           KnockoutBloc()..add(KnockoutRequested(leagueId, season ?? 2024)),
//       child: Scaffold(
//         body: BlocBuilder<KnockoutBloc, KnockoutState>(
//           builder: (context, state) {
//             if (state.status == KnockoutStatus.requestInProgress) {
//               return Center(child: CircularProgressIndicator());
//             } else if (state.status == KnockoutStatus.requestFailure) {
//               return Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: 85.h),
//                     Image.asset('assets/404.gif',
//                         height: 200.h,
//                         fit: BoxFit.fitHeight,
//                         width: 300.w,
//                         color: Colorscontainer.greenColor),
//                     Text(
//                       DemoLocalizations.networkProblem,
//                       style: TextUtils.setTextStyle(
//                         color: Colorscontainer.greenColor,
//                         fontSize: 15.sp,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context)
//                             .colorScheme
//                             .secondary, // Background color
//                         foregroundColor: Colors.white, // Text color
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 6), // Padding
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(20), // Rounded corners
//                         ),
//                       ),
//                       child: Text(
//                         DemoLocalizations.tryAgain,
//                         style: TextUtils.setTextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary, // Text color
//                           fontSize: 13.sp, // Font size
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 56,
//                     )
//                   ],
//                 ),
//               );
//             } else if (state.status == KnockoutStatus.requestSuccess) {
//               var championsLeague = state.championsLeague;

//               return SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 physics: const BouncingScrollPhysics(),
//                 child: Stack(
//                   children: [
//                     CustomPaint(
//                       painter: QuarterFinalToThirdPlacePainter(),
//                       size: Size(MediaQuery.of(context).size.width,
//                           MediaQuery.of(context).size.height),
//                     ),
//                     Column(
//                       children: [
//                         SizedBox(height: 15.h),
//                         if (championsLeague['round_of_16'] != null)
//                           Round16(
//                             TeamOne: _mapTeamData(
//                                 championsLeague['round_of_16'][0]['team_1']),
//                             TeamTwo: _mapTeamData(
//                                 championsLeague['round_of_16'][0]['team_2']),
//                             TeamThree: _mapTeamData(
//                                 championsLeague['round_of_16'][1]['team_1']),
//                             TeamFour: _mapTeamData(
//                                 championsLeague['round_of_16'][1]['team_2']),
//                             TeamFive: _mapTeamData(
//                                 championsLeague['round_of_16'][2]['team_1']),
//                             TeamSix: _mapTeamData(
//                                 championsLeague['round_of_16'][2]['team_2']),
//                             TeamSeven: _mapTeamData(
//                                 championsLeague['round_of_16'][3]['team_1']),
//                             TeamEight: _mapTeamData(
//                                 championsLeague['round_of_16'][3]['team_2']),
//                           ),
//                         SizedBox(
//                           height: 9.h,
//                         ),
//                         if (championsLeague['semi_finals'] != null)
//                           SemifinalPageUp(
//                             TeamOne: _mapTeamData(
//                                 championsLeague['semi_finals'][0]['team_1']),
//                             TeamTwo: _mapTeamData(
//                                 championsLeague['semi_finals'][0]['team_2']),
//                             TeamThree: _mapTeamData(
//                                 championsLeague['semi_finals'][1]['team_1']),
//                             TeamFour: _mapTeamData(
//                                 championsLeague['semi_finals'][1]['team_2']),
//                           ),
//                         SizedBox(
//                           height: 6.h,
//                         ),
//                         if (championsLeague['quarter_finals'] != null)
//                           QuarterFinalPageUp(
//                             TeamOne: _mapTeamData(
//                                 championsLeague['quarter_finals'][0]['team_1']),
//                             TeamTwo: _mapTeamData(
//                                 championsLeague['quarter_finals'][0]['team_2']),
//                           ),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 10,
//                             ),
//                             if (championsLeague['third_place'] != null)
//                               ThirdPlaceMatch(
//                                 TeamOne: _mapTeamData(
//                                     championsLeague['third_place']['team_1']),
//                                 TeamTwo: _mapTeamData(
//                                     championsLeague['third_place']['team_2']),
//                               ),
//                             if (championsLeague['final'] != null)
//                               FinalMatch(
//                                 TeamOne: _mapTeamData(
//                                     championsLeague['final']['team_1']),
//                                 TeamTwo: _mapTeamData(
//                                     championsLeague['final']['team_2']),
//                               ),
//                             Column(
//                               children: [
//                                 Container(
//                                   height: 100,
//                                   width: 150,
//                                   child: SvgPicture.asset(
//                                     'assets/trophy.svg',
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                                 if (championsLeague['final'] != null)
//                                   Text(
//                                     championsLeague['winner'],
//                                     maxLines: 2,
//                                     textAlign: TextAlign.center,
//                                     style: TextUtils.setTextStyle(
//                                         fontSize: 15.sp, color: Colors.white),
//                                   )
//                               ],
//                             ),
//                           ],
//                         ),
//                         if (championsLeague['semi_finals'] != null)
//                           QuarterFinalPageDown(
//                             TeamOne: _mapTeamData(
//                                 championsLeague['semi_finals'][1]['team_1']),
//                             TeamTwo: _mapTeamData(
//                                 championsLeague['semi_finals'][1]['team_2']),
//                           ),
//                         if (championsLeague['quarter_finals'] != null)
//                           SemifinalPageDown(
//                             TeamOne: _mapTeamData(
//                                 championsLeague['quarter_finals'][2]['team_1']),
//                             TeamTwo: _mapTeamData(
//                                 championsLeague['quarter_finals'][2]['team_2']),
//                             TeamThree: _mapTeamData(
//                                 championsLeague['quarter_finals'][3]['team_1']),
//                             TeamFour: _mapTeamData(
//                                 championsLeague['quarter_finals'][3]['team_2']),
//                           ),
//                         if (championsLeague['round_of_16'] != null)
//                           SizedBox(
//                             height: 9.h,
//                           ),
//                         Round16PageDown(
//                           TeamOne: _mapTeamData(
//                               championsLeague['round_of_16'][4]['team_1']),
//                           TeamTwo: _mapTeamData(
//                               championsLeague['round_of_16'][4]['team_2']),
//                           TeamThree: _mapTeamData(
//                               championsLeague['round_of_16'][5]['team_1']),
//                           TeamFour: _mapTeamData(
//                               championsLeague['round_of_16'][5]['team_2']),
//                           TeamFive: _mapTeamData(
//                               championsLeague['round_of_16'][6]['team_1']),
//                           TeamSix: _mapTeamData(
//                               championsLeague['round_of_16'][6]['team_2']),
//                           TeamSeven: _mapTeamData(
//                               championsLeague['round_of_16'][7]['team_1']),
//                           TeamEight: _mapTeamData(
//                               championsLeague['round_of_16'][7]['team_2']),
//                         ),
//                         SizedBox(height: 60.h),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return Center(child: Text('No data available'));
//           },
//         ),
//       ),
//     );
//   }

//   Team _mapTeamData(Map<String, dynamic>? teamData) {
//     if (teamData == null) {
//       return Team(name: 'Unknown', shortName: 'UNK', logo: '', id: 0);
//     }

//     int id = teamData['id'] is String
//         ? int.tryParse(teamData['id']) ?? 0
//         : teamData['id'] ?? 0;
//     String name = teamData['name'] ?? 'Unknown';

//     return Team(
//       name: name,
//       shortName: name.length > 3 ? name.substring(0, 3) : name,
//       logo: generateImageFromId(teamData['id'] ?? 0),
//       id: id,
//     );
//   }
// }

// class QuarterFinalToThirdPlacePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2;

//     // Center the canvas and rotate it to point right
//     canvas.save();
//     canvas.translate(size.width / 2, size.height / 2);
//     canvas.rotate(3.14159 / 2); // Rotate 90 degrees clockwise
//     canvas.translate(-size.width / 2 - size.width / 4, -size.height / 2);

//     final centerX = size.width / 2;
//     final lineWidth = 176.w;
//     final spacing = 14.w;
//     final totalWidth = 2 * lineWidth + spacing;

//     // Increase these values to push the lines to the right
//     final leftFirstX = centerX - totalWidth / 2 + lineWidth / 2 + 42.w;
//     final leftSecondX = leftFirstX + lineWidth + spacing;

//     final topY = size.height / 2 + 30.h; // Push down the starting point
//     final midY = topY + 20.h; // Shorter vertical lines
//     final bottomY = midY + 60.h; // Adjust the bottom point

//     canvas.drawLine(Offset(leftFirstX, topY), Offset(leftFirstX, midY), paint);
//     canvas.drawLine(
//         Offset(leftSecondX, topY), Offset(leftSecondX, midY), paint);
//     canvas.drawLine(Offset(leftFirstX, midY), Offset(leftSecondX, midY), paint);

//     final leftMidX = (leftFirstX + leftSecondX) / 2;

//     canvas.drawLine(Offset(leftMidX, midY), Offset(leftMidX, bottomY), paint);

//     canvas.restore();
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
