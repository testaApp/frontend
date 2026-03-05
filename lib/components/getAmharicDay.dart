import 'package:abushakir/abushakir.dart';
import '../localization/demo_localization.dart';

Map<String, dynamic> getAmharicDayFromGC(String dateTime) {
  try {
    DateTime date = DateTime.parse(dateTime);
    // Use midday timestamp to ensure the conversion reflects the Gregorian local day correctly
    // and avoids edge cases near midnight or timezone boundaries.
    EtDatetime ethiopianDate = EtDatetime.fromMillisecondsSinceEpoch(
      date.add(const Duration(hours: 12)).millisecondsSinceEpoch,
    );

    Map<String, dynamic> value = {
      'year': ethiopianDate.year,
      'month': ethiopianDate.month,
      'day': ethiopianDate.day,
    };

    String getTodayName() {
      switch (date.weekday) {
        case DateTime.monday: return DemoLocalizations.monday;
        case DateTime.tuesday: return DemoLocalizations.tuesday;
        case DateTime.wednesday: return DemoLocalizations.wednesday;
        case DateTime.thursday: return DemoLocalizations.thursday;
        case DateTime.friday: return DemoLocalizations.friday;
        case DateTime.saturday: return DemoLocalizations.saturday;
        case DateTime.sunday: return DemoLocalizations.sunday;
        default: return '';
      }
    }

    String todayName = getTodayName();
    return {...value, 'dayName': todayName};
  } catch (e) {
    return {};
  }
}

// Actual Ethiopian month names in Amharic
const List<String> ethiopianMonthNames = [
  'መስከረም', 'ጥቅምት', 'ህዳር', 'ታህሳስ', 'ጥር', 'የካቲት', 'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ'
];

String getAmharicMonthName(String dateTime) {
  try {
    DateTime date = DateTime.parse(dateTime);
    // Use midday timestamp to ensure the conversion reflects the Gregorian local day correctly
    EtDatetime ethiopianDate = EtDatetime.fromMillisecondsSinceEpoch(
      date.add(const Duration(hours: 12)).millisecondsSinceEpoch,
    );

    String month = ethiopianMonthNames[ethiopianDate.month - 1];
    // Shorten to first 2 characters for better fit in horizontal list (e.g., መስከረም -> መስ, የካቲት -> የካ)
    String monthShort = month.length > 2 ? month.substring(0, 2) : month;
    
    return "$monthShort ${ethiopianDate.day}";
  } catch (e) {
    return '';
  }
}

// Use this for your other string displays
String getAmharicStringDay(String dateTime) {
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);
  if (dateData.isEmpty) return '';

  String dayName = dateData['dayName'].toString();
  // Shorten day name (e.g., ሰኞ -> ሰኞ, ማክሰኞ -> ማክ)
  if (dayName.length > 2) dayName = dayName.substring(0, 2);

  String monthAndDate = getAmharicMonthName(dateTime);
  return '$dayName $monthAndDate';
}

// Fixed version of getAmharicSubstDate
String getAmharicSubstDate(String dateTime) {
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);
  if (dateData.isEmpty) return '';

  try {
    String m = ethiopianMonthNames[dateData['month'] - 1];
    String mShort = m.length > 2 ? m.substring(0, 2) : m;

    return "$mShort ${dateData['day']}";
  } catch (e) {
    return '';
  }
}