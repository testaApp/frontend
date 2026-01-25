import 'package:intl/intl.dart';

class DateLogic {
  static List<String> getDateData({String? DateData = ''}) {
    List<String> dateList = [];

    DateTime now = DateTime.now();
    DateTime currentDate = DateData != ''
        ? DateTime.parse(DateData!)
        : DateTime(now.year, now.month, now.day);

    for (int i = 7; i >= 1; i--) {
      DateTime previousDate = currentDate.subtract(Duration(days: i));
      dateList.add(DateFormat('yyyy-MM-dd').format(previousDate));
    }

    dateList.add(DateFormat('yyyy-MM-dd').format(currentDate));

    for (int i = 1; i <= 7; i++) {
      DateTime nextDate = currentDate.add(Duration(days: i));
      dateList.add(DateFormat('yyyy-MM-dd').format(nextDate));
    }

    return dateList;
  }

  static List<String> getUpdatedList({required DateData}) {
    List<String> dateList = [];

//print("DATE DATA IS ........ $DateData");
    DateTime currentDate = DateTime.parse(DateData!);

    for (int i = 7; i >= 1; i--) {
      DateTime previousDate = currentDate.subtract(Duration(days: i));
      dateList.add(DateFormat('yyyy-MM-dd').format(previousDate));
    }

    dateList.add(DateFormat('yyyy-MM-dd').format(currentDate));

    for (int i = 1; i <= 7; i++) {
      DateTime nextDate = currentDate.add(Duration(days: i));
      dateList.add(DateFormat('yyyy-MM-dd').format(nextDate));
    }

    return dateList;
  }
}

class GetToday {
  static String getDateData() {
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    return currentDate.toString().substring(0, 10);
  }
}
