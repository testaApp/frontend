// import 'dart:math';
// import 'notifier.dart';

// final NotificationService notificationService = NotificationService();
// Future<void> scheduleNotificationAfterDelay(
//     {String title = '',
//     required String body,
//     required String imageUrl,
//     required String type,
//     int? fixtureId}) async {
//   int idNumber = generateNotificationId(fixtureId, type);
//   await notificationService.showNotification(
//       id: idNumber,
//       title: title,
//       body: body,
//       rightSideImageUrl: imageUrl,
//       type: type,
//       fixtureId: fixtureId);
// }

// int generateUniqueId() {
//   return Random().nextInt(1000000) +
//       1; // Generates a number between 1 and 1000000
// }

// int generateNotificationId(int? fixtureId, String type) {
//   if (fixtureId != null) {
//     int hash = fixtureId.hashCode ^ type.hashCode;
//     return hash.abs();
//   }
//   int hash = type.hashCode;
//   return generateUniqueId() ^ hash.abs();
// }
