import 'package:intl/intl.dart';

String dateConverter({required dateString}) {
  try {
    DateTime date = DateTime.parse(dateString);
    DateFormat format = DateFormat('EEEE MMMM d, yyyy. h:mm a');
    String formattedDate = format.format(date);
    return formattedDate;
  } catch (e) {
    ////print(e);
    rethrow;
  }
}

String extractDate(String? dateString) {
  ////print(dateString);

  try {
    DateTime date = DateTime.parse(dateString!);

    // Format the date as "EEE yyyy"
    DateFormat dateFormat = DateFormat('EEE, MMM d yyyy');
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  } catch (e) {
    //print(e);
    return '';
  }
}

String extractTime(String? dateString) {
  try {
    DateTime date = DateTime.parse(dateString!);

    // Format the time as "hh:mm a"
    DateFormat timeFormat = DateFormat('hh:mm a');
    String formattedTime = timeFormat.format(date);

    return formattedTime;
  } catch (e) {
    //print(e);
    return '';
  }
}
