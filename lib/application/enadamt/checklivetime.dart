// import 'package:intl/intl.dart';

// bool isThePodcastLive(dynamic liveTimes) {
//   if (liveTimes == null || liveTimes.isEmpty) return false;

//   final now = DateTime.now();
//   final weekdayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday

//   final dayData = liveTimes[weekdayIndex];
//   if (dayData == null || dayData is! Map) return false;

//   final startH = dayData['start-hour']   as int?;
//   final startM = dayData['start-minute'] as int? ?? 0;
//   final endH   = dayData['end-hour']     as int?;
//   final endM   = dayData['end-minute']   as int? ?? 0;

//   if (startH == null || endH == null) return false;

//   final start = DateTime(now.year, now.month, now.day, startH, startM);
//   var end   = DateTime(now.year, now.month, now.day, endH,   endM);

//   // Handle overnight schedules if needed (end < start)
//   if (end.isBefore(start)) {
//     end = end.add(const Duration(days: 1));
//   }

//   return now.isAfter(start) && now.isBefore(end);
// }

// //podcast notfier

// bool isTheProgramLive(currentDaySchedule) {
//   final DateTime currentTime = DateTime.now();
//   final String currentDay = DateFormat('EEEE').format(currentTime);

//   // List<Map<String, int?>>

//   int? startHour = currentDaySchedule[0]['start-hour'];
//   int? startMinute = currentDaySchedule[1]['start-minute'];
//   int? endHour = currentDaySchedule[2]['end-hour'];
//   int? endMinute = currentDaySchedule[3]['end-minute'];
//   if (startHour != null && endHour != null) {
//     final DateTime startingTime = DateTime(currentTime.year, currentTime.month,
//         currentTime.day, startHour, startMinute ?? 00);
//     final DateTime endTime = DateTime(currentTime.year, currentTime.month,
//         currentTime.day, endHour, endMinute ?? 00);

//     if (currentTime.isAfter(startingTime) && currentTime.isBefore(endTime)) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   return false;
// }
