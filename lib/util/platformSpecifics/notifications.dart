//   import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final androidPlatformChannelSpecificsWithSound = AndroidNotificationDetails(
//       'unique_channel_idd',
//       'testa',
//       playSound: true,
//       sound:   RawResourceAndroidNotificationSound('goal') ,
//       icon: IconSelector( type),
//       largeIcon: rightSideImageResource != null ? FilePathAndroidBitmap(rightSideImageResource) : null ,
//       vibrationPattern: vibrationSetting ? Int64List.fromList([0, 500]) : null,
//       styleInformation:  BigTextStyleInformation(
//               body ??  '',
//               contentTitle: title,
//               summaryText: translateType(type)
//             ),
//     );
//     //no sound but vibration
//     final androidPlatformChannelSpecificsWithNoSound = AndroidNotificationDetails(
//       'unique_channel_id_2_no_sound_but_viberation',
//       'testa_no_sound',
//       playSound: false,
//       sound:   null ,
//       icon: IconSelector( type),
//       largeIcon: rightSideImageResource != null ? FilePathAndroidBitmap(rightSideImageResource) : null ,
//       enableVibration: vibrationSetting ,
//       vibrationPattern: vibrationSetting ? Int64List.fromList([0, 500]) : null,
//       styleInformation:  BigTextStyleInformation(
//               body ??  '',
//               contentTitle: title,
//               summaryText: translateType(type)
//             ),
//     );
//       //no sound no vibration
//       final androidPlatformChannelSpecificsWithNoSoundNoViberation = AndroidNotificationDetails(
//       'unique_channel_id_no_sound_no_viberation',
//       'testa_no_sound_no_viberation',
//       playSound: true,
//       sound:   RawResourceAndroidNotificationSound('goal') ,
//       icon: IconSelector( type),
//       largeIcon: rightSideImageResource != null ? FilePathAndroidBitmap(rightSideImageResource) : null ,
//       enableVibration: false,
//       vibrationPattern: null,
//       styleInformation:  BigTextStyleInformation(
//               body ??  '',
//               contentTitle: title,
//               summaryText: translateType(type)
//             ),
//     );
// //vibration but no sound

//     final androidPlatformChannelSpecificsWithViberationButNoSound = AndroidNotificationDetails(
//       'unique_channel_id_2_no_sound_but_viberation',
//       'testa_vib_but_no_sound',
//       playSound: false,
//       sound:   null ,
//       icon: IconSelector( type),
//       largeIcon: rightSideImageResource != null ? FilePathAndroidBitmap(rightSideImageResource) : null ,
//       enableVibration: true ,
//       vibrationPattern:Int64List.fromList([0, 500]) ,
//       styleInformation:  BigTextStyleInformation(
//               body ??  '',
//               contentTitle: title,
//               summaryText: translateType(type)
//             ),
//     );
