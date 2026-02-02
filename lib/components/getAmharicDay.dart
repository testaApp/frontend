// Update your imports
import 'package:ethiopian_calendar_plus/converters.dart';
import 'package:ethiopian_calendar_plus/ethiopian_date.dart';
import '../localization/demo_localization.dart';

Map<String, dynamic> getAmharicDayFromGC(String dateTime) {
  try {
    DateTime date = DateTime.parse(dateTime);
    
    // 1. Convert using the new package method
    EthiopianDate ethiopianDate = EthiopianDateConverter.gregorianToEthiopian(date);

    // 2. Map the result to your existing structure
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

String getAmharicMonthName(String dateTime) {
  try {
    DateTime date = DateTime.parse(dateTime);
    EthiopianDate ethiopianDate = EthiopianDateConverter.gregorianToEthiopian(date);

    List<String> months = [
      DemoLocalizations.september, // Meskerem
      DemoLocalizations.october,   // Tikimt
      DemoLocalizations.november,  // Hidar
      DemoLocalizations.december,  // Tahsas
      DemoLocalizations.january,   // Ter
      DemoLocalizations.february,  // Yekatit
      DemoLocalizations.march,     // Megabit
      DemoLocalizations.april,     // Miyazia
      DemoLocalizations.may,       // Ginbot
      DemoLocalizations.june,      // Sene
      DemoLocalizations.july,      // Hamle
      DemoLocalizations.august,    // Nehase
      DemoLocalizations.pagume,    // Pagume
    ];

    String month = months[ethiopianDate.month - 1];
    String monthShort = month.length > 3 ? month.substring(0, 3) : month;
    
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
  if (dayName.length > 3) dayName = dayName.substring(0, 3);

  String monthAndDate = getAmharicMonthName(dateTime);
  return '$dayName $monthAndDate';
}
// Fixed version of getAmharicSubstDate
String getAmharicSubstDate(String dateTime) {
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);
  if (dateData.isEmpty) return '';

  try {
    List<String> months = [
      DemoLocalizations.september, // Ethiopian Year starts in Meskerem
      DemoLocalizations.october,
      DemoLocalizations.november,
      DemoLocalizations.december,
      DemoLocalizations.january,
      DemoLocalizations.february,
      DemoLocalizations.march,
      DemoLocalizations.april,
      DemoLocalizations.may,
      DemoLocalizations.june,
      DemoLocalizations.july,
      DemoLocalizations.august,
      DemoLocalizations.pagume,
    ];

    String m = months[dateData['month'] - 1];
    String mShort = m.length > 2 ? m.substring(0, 2) : m;

    return "$mShort ${dateData['day']}";
  } catch (e) {
    return '';
  }
}