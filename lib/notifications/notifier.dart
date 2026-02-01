// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// import '../application/testing/bloc/audio_bloc.dart';
// import '../application/testing/bloc/audio_event.dart';
// import '../components/routenames.dart';
// import '../functions/download_and_save_image.dart';
// import '../functions/translate_type.dart';
// import '../localization/demo_localization.dart';
// import '../main.dart';

// import '../models/news.dart';
// import '../models/playlist/playlist_model.dart';
// import '../pages/appbar_pages/news/main_news/news_detail.dart';
// import '../services/page_manager.dart';
// import '../services/service_locator.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// late final PageManager pageManager;
// final AudioBloc audioBloc = getIt<AudioBloc>();

// Future<bool> getSettingValue(String key) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getBool(key) ?? true; // Return false if the key doesn't exist
// }

// Future<void> handleBackgroundNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   print('Notification tap detected handleBackgroundNotificationResponse');
//   pageManager = getIt<PageManager>();
//   await pageManager.init();
//   if (notificationResponse.notificationResponseType ==
//       NotificationResponseType.selectedNotification) {
//     if (notificationResponse.payload != null &&
//         notificationResponse.payload!.trim() != '') {
//       final Map<String, dynamic> payloadMap =
//           jsonDecode(notificationResponse.payload!);

//       final String type = payloadMap['type'] ?? '';
//       print('the type is $type');
//       if (type == 'podcast') {
//         PlaylistModel fetchMedia() {
//           return PlaylistModel(
//             title: payloadMap['name'],
//             audioUrl: payloadMap['link'],
//             id: payloadMap['id'],
//             avatar: payloadMap['avatar'],
//             station: payloadMap['station'],
//             journalist: payloadMap['program'],
//           );
//         }

//         String avatar = payloadMap['avatar'];

//         audioBloc.add(setLivePlaying(avatar: avatar));
//         try {
//           await pageManager.playMediaItem(fetchMedia());
//         } catch (e) {}
//       } else {
//         GoRouter.of(navigatorKey.currentContext!).goNamed(
//           RouteNames.matchDetail,
//           queryParameters: {'fixtureId': notificationResponse.payload!},
//         );
//       }
//     } else {
//       GoRouter.of(navigatorKey.currentContext!).goNamed(RouteNames.news);
//     }
//   }
// }

// Future<void> handleReceiveNotificationResponse(
//     BuildContext context, NotificationResponse notificationResponse) async {
//   pageManager = getIt<PageManager>();
//   await pageManager.init();
//   if (notificationResponse.notificationResponseType ==
//       NotificationResponseType.selectedNotification) {
//     if (notificationResponse.payload != null &&
//         notificationResponse.payload!.trim() != '') {
//       final Map<String, dynamic> payloadMap =
//           jsonDecode(notificationResponse.payload!);

//       final String type = payloadMap['type'] ?? '';
//       print('type is $type');

//       if (type == 'podcast') {
//         PlaylistModel fetchMedia() {
//           return PlaylistModel(
//             title: payloadMap['name'],
//             audioUrl: payloadMap['link'],
//             id: payloadMap['id'],
//             avatar: payloadMap['avatar'],
//             station: payloadMap['station'],
//             journalist: payloadMap['program'],
//           );
//         }

//         String avatar = payloadMap['avatar'];

//         context.read<AudioBloc>().add(setLivePlaying(avatar: avatar));
//         try {
//           await pageManager.playMediaItem(fetchMedia());
//         } catch (e) {}
//       } else if (type == 'breakingNews') {
//         final String id = payloadMap['newsId'] ?? '';

//         final String summarized = payloadMap['summarized'] ?? '';

//         final String mainImageUrl = payloadMap['imageUrl'] ?? '';
//         final Map<String, dynamic> routeArguments =
//             payloadMap['routeArguments'] ?? {};

//         final String figCaption = routeArguments['figCaption'] ?? '';

//         final String summarizedTitle = routeArguments['summarizedTitle'] ?? '';
//         final String publishedDate = routeArguments['publishedDate'] ?? '';

//         final String author = routeArguments['author'] ?? '';

//         final String source = routeArguments['source'] ?? '';
//         final String sourcename = routeArguments['sourcename'] ?? '';
//         final String sourceimage = routeArguments['sourceimage'] ?? '';
//         List<ImageModel> mainImages = [
//           ImageModel(
//             url: mainImageUrl,
//             caption:
//                 figCaption, // Use figCaption as the image caption if available
//           ),
//         ];
//         News detail = News(
//           id: id,
//           figCaption: figCaption,
//           summarized: summarized,
//           summarizedTitle: summarizedTitle,
//           author: author,
//           source: source,
//           sourcename: sourcename,
//           sourceimage: sourceimage,
//           mainImages: mainImages,
//           publishedDate: publishedDate,
//           time: '1',
//         );

//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NewsDetailPage(news: detail),
//           ),
//         );
//       } else if (type == 'breakingTransfer') {
//         await context.pushNamed(RouteNames.transfer);
//       } else if (type == 'manynotifications') {
//         await context.pushNamed(RouteNames.home);
//       } else {
//         GoRouter.of(context).goNamed(
//           RouteNames.matchDetail,
//           queryParameters: {'fixtureId': notificationResponse.payload!},
//         );
//       }
//     } else {
//       GoRouter.of(context).goNamed(RouteNames.news);
//     }
//   }
// }

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification({
//     required BuildContext context,
//   }) async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('testaapp');

//     tz.initializeTimeZones();

//     var initializationSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: (id, title, body, payload) async {},
//     );

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (notificationResponse) =>
//           handleReceiveNotificationResponse(context, notificationResponse),
//       onDidReceiveBackgroundNotificationResponse:
//           handleBackgroundNotificationResponse,
//     );
//   }

//   Future showNotification({
//     required int id,
//     String? title,
//     String? body,
//     String? rightSideImageUrl,
//     String? type,
//     int? fixtureId,
//   }) async {
//     String? rightSideImageResource;
//     if (rightSideImageUrl != null && rightSideImageUrl != '') {
//       final String fileName = rightSideImageUrl.split('/').last;
//       rightSideImageResource =
//           await downloadAndSaveImage(rightSideImageUrl, fileName);
//     }
//     bool vibrationSetting = await getVibrationSetting();

//     final androidPlatformChannelSpecificsWithSound = AndroidNotificationDetails(
//       'unique_channel_idjhgerrtrr2___hfdfggggdfggggdfdfgdfffffdf__fgfggg_oooooooo__',
//       'Live notification with goal sound',
//       playSound: true,
//       importance: Importance.max,
//       icon: 'testaapp',
//       sound: const RawResourceAndroidNotificationSound('goal'),
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       vibrationPattern: vibrationSetting ? Int64List.fromList([0, 500]) : null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithNoSoundButVibration =
//         AndroidNotificationDetails(
//       'unique_chadgfnnel_id_rtr2_nooooo_sound_but__vibbbeyyrations____yyertfef____',
//       'Live notification with vibration and no sound',
//       importance: Importance.max,
//       playSound: false,
//       sound: null,
//       icon: 'testaapp',
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       enableVibration: true,
//       vibrationPattern: Int64List.fromList([0, 500]),
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithNoSoundNoViberation =
//         AndroidNotificationDetails(
//       'unique_channel_idgfd_no_sound_no_viberrrrrdfation_trrtdddfgeie_m___rrrt__',
//       'Live notification with no sound and no vibration _silent',
//       playSound: true,
//       importance: Importance.max,
//       icon: 'testaapp',
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       enableVibration: false,
//       vibrationPattern: null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithSoundButNoVibration =
//         AndroidNotificationDetails(
//       'unique_channel_id_2_nodg_sound_but_rrvirrrrrerrrwerrberation0089kkfgfgterdfr_fgfgg________',
//       'Live notification with sound but no vibration __',
//       playSound: true,
//       priority: Priority.high,
//       icon: 'testaapp',
//       sound: const RawResourceAndroidNotificationSound('goal'),
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       enableVibration: false,
//       vibrationPattern: null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithDefaultSoundButNoVibration =
//         AndroidNotificationDetails(
//       'uniquee_channel_id_2_no_soundfgdv_rrbrrut_viberfffffatio__n____ggfgfgtefvbgrdfrll_fgfgtit______',
//       'Live notification with sound but no vibration ___',
//       playSound: true,
//       icon: 'testaapp',
//       sound: const RawResourceAndroidNotificationSound('default_music'),
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       enableVibration: false,
//       vibrationPattern: null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithDefaultSound =
//         AndroidNotificationDetails(
//       'unique_channeldfd_idjhgert_ll_ysfdfgd_hfrtrdfdeggreretttyuiooiuytkferecvgertyudfg_',
//       'Live notification with sound and vibration  _',
//       playSound: true,
//       icon: 'testaapp',
//       priority: Priority.high,
//       sound: const RawResourceAndroidNotificationSound('default_music'),
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       vibrationPattern: vibrationSetting ? Int64List.fromList([0, 500]) : null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithThirdSoundButNoVibration =
//         AndroidNotificationDetails(
//       'unique_channel_id_2_nrtrtoadfgsssdsd_sound_but_vibergation0ee__t089fgfgtettrdfr_ffgfgtt________nn__',
//       'Live notification with sound but no vibration __',
//       playSound: true,
//       icon: 'testaapp',
//       importance: Importance.max,
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       enableVibration: false,
//       vibrationPattern: null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     final androidPlatformChannelSpecificsWithThirdDefaultSound =
//         AndroidNotificationDetails(
//       'unique_channel_idjhgertttt__rtrt_dfghfdfqwertydddudefffffffgffffffrtyuiooiuywerrtfgdfg____lllll',
//       'Live notification with sound and vibration  __ default sound',
//       playSound: true,
//       icon: 'testaapp',
//       importance: Importance.max,
//       largeIcon: rightSideImageResource != null
//           ? FilePathAndroidBitmap(rightSideImageResource)
//           : null,
//       vibrationPattern: vibrationSetting ? Int64List.fromList([0, 500]) : null,
//       styleInformation: BigTextStyleInformation(body ?? '',
//           contentTitle: title, summaryText: translateType(type)),
//     );

//     AndroidNotificationDetails getAndroidNotificationDetails(
//         String type, bool isSoundEnabled, bool isViberationEnabled) {
//       type = type.toLowerCase();
//       if (isSoundEnabled && isViberationEnabled) {
//         if (type == 'goal') {
//           return androidPlatformChannelSpecificsWithSound;
//         } else if (['ms', 'bt', 'ft', '1h', '2h', 'bn', 'ne', 'tn', 'on', 'en']
//             .contains(type)) {
//           return androidPlatformChannelSpecificsWithDefaultSound;
//         } else {
//           return androidPlatformChannelSpecificsWithThirdDefaultSound;
//         }
//       } else if (isSoundEnabled) {
//         if (type == 'goal') {
//           return androidPlatformChannelSpecificsWithSoundButNoVibration;
//         } else if (['ms', 'bt', 'ft', '1h', '2h', 'bn', 'ne', 'tn', 'on', 'en']
//             .contains(type)) {
//           return androidPlatformChannelSpecificsWithDefaultSoundButNoVibration;
//         } else {
//           return androidPlatformChannelSpecificsWithThirdSoundButNoVibration;
//         }
//       } else if (isViberationEnabled) {
//         return androidPlatformChannelSpecificsWithNoSoundButVibration;
//       }
//       return androidPlatformChannelSpecificsWithNoSoundNoViberation;
//     }

//     bool isSoundEnabled = await getSoundSetting();
//     bool isViberationEnabled = await getVibrationSetting();

//     final platformChannelSpecifics = NotificationDetails(
//         android: getAndroidNotificationDetails(
//             type ?? '', isSoundEnabled, isViberationEnabled),
//         iOS: DarwinNotificationDetails(
//           presentAlert: isViberationEnabled,
//           presentBadge: true,
//           presentSound: isSoundEnabled,
//         ));

//     await notificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: fixtureId?.toString(),
//     );
//   }
// }


// Future<bool> getSoundSetting() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getBool('Sound') ?? true; // ✅ Changed from false to true
// }

// Future<bool> getVibrationSetting() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getBool('Vibration') ?? true; // ✅ Changed from false to true
// }
