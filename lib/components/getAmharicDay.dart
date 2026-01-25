import 'package:abushakir/abushakir.dart';
import 'package:ethiopian_calendar/ethiopian_date_converter.dart';
import 'package:ethiopian_calendar/ethiopian_date_formatter.dart';
import 'package:ethiopian_calendar/model/ethiopian_date.dart';
import '../localization/demo_localization.dart';

Map<String, dynamic> getAmharicDayFromGC(String dateTime) {
  try {
    // DateTime date = DateFormat('yyyy-mm-dd').parse(dateTime);
    DateTime date = DateTime.parse(dateTime);
    // DateTime date = DateTime.parse(dateTime.substring(0 ,10 ));
    //  date = date.add(Duration(days: 1));
    EtDatetime etDateTime =
        EtDatetime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);

    Map<String, dynamic> value = etDateTime.date;

    String getTodayName() {
      // final now = DateTime.now();

      switch (date.weekday) {
        case DateTime.monday:
          return DemoLocalizations.monday;
        case DateTime.tuesday:
          return DemoLocalizations.tuesday;
        case DateTime.wednesday:
          return DemoLocalizations.wednesday;
        case DateTime.thursday:
          return DemoLocalizations.thursday;
        case DateTime.friday:
          return DemoLocalizations.friday;
        case DateTime.saturday:
          return DemoLocalizations.saturday;
        case DateTime.sunday:
          return DemoLocalizations.sunday;
        default:
          return '';
      }
    }

//  String todayKey = getTodayName();
    String todayName = getTodayName();
//  _localizedValues[localLanguageNotifier.value]![todayKey]!;
    Map<String, String> dayName = {
      'dayName': todayName
      // ETC(year: etDateTime.date['year']! , month: etDateTime.date['month']! ).monthDays(weekDayName: true ).toList()[etDateTime.date['day']!-1][3]
    };

    return {...value, ...dayName};
  } catch (e) {}
  return {};
}

String getAmharicStringDay(String dateTime) {
  DateTime date = DateTime.parse(dateTime);

  List<String> ethiopianMonths = [
    DemoLocalizations.january,
    DemoLocalizations.february,
    DemoLocalizations.march,
    DemoLocalizations.april,
    DemoLocalizations.may,
    DemoLocalizations.june,
    DemoLocalizations.july,
    DemoLocalizations.august,
    DemoLocalizations.september,
    DemoLocalizations.october,
    DemoLocalizations.november,
    DemoLocalizations.december,
    DemoLocalizations.pagume,
  ];
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);
  String dayName = dateData['dayName'].toString().length > 3
      ? dateData['dayName'].toString().substring(0, 3)
      : dateData['dayName'].toString();
  String monthName = '';
  if (dateData['day'] == 30) {
    monthName = ethiopianMonths[dateData['month']].length > 3
        ? ethiopianMonths[dateData['month']].substring(0, 3)
        : ethiopianMonths[dateData['month']];
  } else {
    monthName = ethiopianMonths[dateData['month'] - 1].length > 3
        ? ethiopianMonths[dateData['month'] - 1].substring(0, 3)
        : ethiopianMonths[dateData['month'] - 1];
  }

  int dayNumber =
      (dateData['day'] + 1) % 30 == 0 ? 30 : (dateData['day'] + 1) % 30;

  String monthAndDate = getAmharicMonthName(dateTime);
  return '$dayName $monthAndDate';
}

String getAmhariccMonthName(String dateTime) {
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);

  try {
    List<String> Months = [
      DemoLocalizations.january,
      DemoLocalizations.february,
      DemoLocalizations.march,
      DemoLocalizations.april,
      DemoLocalizations.may,
      DemoLocalizations.june,
      DemoLocalizations.july,
      DemoLocalizations.august,
      DemoLocalizations.september,
      DemoLocalizations.october,
      DemoLocalizations.november,
      DemoLocalizations.december,
      DemoLocalizations.pagume,
    ];
    String month = (dateData['day'] + 1) % 30 == 0
        ? Months[dateData['month'] + 1]
        : Months[dateData['month'] - 1];

    String monthName = month.length > 3 ? month.substring(0, 3) : month;
    return "$monthName ${(dateData['day'] + 1) % 30 == 0 ? 30 : (dateData['day'] + 1) % 30} ";
  } catch (e) {
    //print(e);
    return '';
  }
}

String getAmharicSubstDate(String dateTime) {
  Map<String, dynamic> dateData = getAmharicDayFromGC(dateTime);

  try {
    List<String> Months = [
      DemoLocalizations.january,
      DemoLocalizations.february,
      DemoLocalizations.march,
      DemoLocalizations.april,
      DemoLocalizations.may,
      DemoLocalizations.june,
      DemoLocalizations.july,
      DemoLocalizations.august,
      DemoLocalizations.pagume,
      DemoLocalizations.september,
      DemoLocalizations.october,
      DemoLocalizations.november,
      DemoLocalizations.december,
    ];

    return "${Months[dateData['month'] - 1].length > 2 ? Months[dateData['month'] - 1].substring(0, 2) : Months[dateData['month'] - 1]} ${dateData['day'] + 1} ";
  } catch (e) {
    //print(e);
    return '';
  }
}

String getAmharicMonthName(String dateTime) {
  DateTime date = DateTime.parse(dateTime);
  EthiopianDateTime ethiopianDateObject =
      EthiopianDateConverter.convertToEthiopianDate(date);

  List<String> Months = [
    DemoLocalizations.january,
    DemoLocalizations.february,
    DemoLocalizations.march,
    DemoLocalizations.april,
    DemoLocalizations.may,
    DemoLocalizations.june,
    DemoLocalizations.july,
    DemoLocalizations.august,
    DemoLocalizations.september,
    DemoLocalizations.october,
    DemoLocalizations.november,
    DemoLocalizations.december,
    DemoLocalizations.pagume,
  ];

  String day =
      EthiopianDateFormatter('yyyy-MM-dd', 'am').format(ethiopianDateObject);
  String monthName = Months[ethiopianDateObject.month - 1].length > 3
      ? Months[ethiopianDateObject.month - 1].substring(0, 3)
      : Months[ethiopianDateObject.month - 1];
  int dayNum = ethiopianDateObject.day;
  return '$monthName $dayNum';

  // return day;
}
