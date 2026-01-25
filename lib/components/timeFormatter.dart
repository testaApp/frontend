import '../localization/demo_localization.dart';
import '../main.dart'; // Assuming navigatorKey is defined in main.dart

String formatTime(String timeString) {
  DateTime currentTime = DateTime.now();

  try {
    DateTime time = DateTime.parse(timeString);
    Duration difference = currentTime.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}yr';
    }
  } catch (e) {
    return '';
  }
}

String formatTimeForNews(String timeString) {
  DateTime currentTime = DateTime.now();

  try {
    //print(timeString);
    DateTime time = DateTime.parse(timeString);

    Duration difference = currentTime.difference(time);

    if (difference.inSeconds < 60) {
      // return 'ከ${difference.inSeconds} ሰከንድ በፊት';
      return getLocalizedSeconds(difference.inSeconds);
    } else if (difference.inMinutes < 60) {
      // return 'ከ${difference.inMinutes} ደቂቃ በፊት';
      return getLocalizedMinutes(difference.inMinutes);
    } else if (difference.inDays < 1) {
      // return 'ከ${difference.inHours} ሰዓት በፊት';
      return getLocalizedHours(difference.inHours);
    } else if (difference.inDays < 7) {
      // return 'ከ${difference.inDays} ቀን በፊት';
      return getLocalizedDays(difference.inDays);
    } else if (difference.inDays < 30) {
      // return 'ከ${(difference.inDays / 7).floor()} ሳምንት በፊት';
      return getLocalizedWeeks((difference.inDays / 7).floor());
    } else if (difference.inDays < 365) {
      // return 'ከ${(difference.inDays / 30).floor()} ወር በፊት';
      return getLocalizedMonth((difference.inDays / 30).floor());
    } else {
      // return 'ከ${(difference.inDays / 365).floor()} አመት በፊት';
      return getLocalizedYears((difference.inDays / 365).floor());
    }
  } catch (e) {
    //print(e);
    return '';
  }
}

String convertDateFormat(String inputDate) {
  // Split the inputDate into date and time parts
  List<String> parts = inputDate.split(' ');
  if (parts.length != 2) {
    // Invalid input format
    return inputDate;
  }

  // Split the date part into day, month, and year
  List<String> dateParts = parts[0].split('/');
  if (dateParts.length != 3) {
    // Invalid date format
    return inputDate;
  }

  // Extract day, month, and year
  int day = int.tryParse(dateParts[0]) ?? 0;
  int month = int.tryParse(dateParts[1]) ?? 0;
  int year = int.tryParse(dateParts[2]) ?? 0;

  // Create a DateTime object
  DateTime dateTime = DateTime(year, month, day);

  // Format the DateTime object to the desired format
  String formattedDate =
      "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${parts[1]}";

  return formattedDate;
}

String extractTimeFromIso(String dateTimeString) {
  // Regular expression to match ISO 8601 date-time strings like "2023-05-20T11:30:00+00:00"
  RegExp regex =
      RegExp(r'^\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):\d{2}[+-]\d{2}:\d{2}$');

  if (!regex.hasMatch(dateTimeString)) {
    throw const FormatException('Invalid date-time format');
  }

  var matches = regex.firstMatch(dateTimeString);
  var hour = int.parse(matches!.group(1)!);
  var minute = int.parse(matches.group(2)!);

  // Convert UTC to local time by adding 3 hours
  hour -= 3;

// Handle overflow into the next day
  if (hour < 0) {
    hour += 24;
  }

// Convert to 12-hour format with AM/PM
  String period;
  if (hour >= 0 && hour < 6) {
    period = DemoLocalizations.morning;
  } else if (hour >= 6 && hour < 12) {
    period = DemoLocalizations.day;
  } else if (hour >= 12 && hour < 17) {
    period = DemoLocalizations.evening;
  } else {
    period = DemoLocalizations.night;
  }

  if (hour > 12) hour -= 12;
  if (hour == 0) hour = 12;

  // Return formatted time
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
}

String getLocalizedMonth(int month) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'ji`a',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ወር በፊት',
    'tr': 'ወርሒ',
    'so': 'bil',
    'or': 'dura',
    'en': ' months ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$month${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]}$month ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedMinutes(int minutes) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'sekondii',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ደቂቃ በፊት',
    'tr': 'ደቒቕ',
    'so': 'daqiiqo',
    'or': 'dura',
    'en': ' minutes ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$minutes${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]} $minutes ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedSeconds(int seconds) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'sekondii',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ሰከንድ በፊት',
    'tr': 'ሰከንድ',
    'so': 'ilbiriqsi',
    'or': 'dura',
    'en': ' seconds ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$seconds${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]} $seconds ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedHours(int hours) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': "sa'aatii",
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ሰዓት በፊት',
    'tr': 'ሰዓት',
    'so': 'saac',
    'or': 'dura',
    'en': ' hours ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$hours${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]} $hours ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedYears(int years) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'waggaa',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ዓመት በፊት',
    'tr': 'ዓመት',
    'so': 'sano',
    'or': 'dura',
    'en': ' years ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$years${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]} $years ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedWeeks(int weeks) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'torban',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ሳምንት በፊት',
    'tr': 'ሰሙን',
    'so': 'usbuuc',
    'or': 'dura',
    'en': ' weeks ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$weeks${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]} $weeks ${befit[localLanguageNotifier.value]}';
  }
}

String getLocalizedDays(int days) {
  Map<String, String> ke = {
    'am': 'ከ',
    'tr': 'ቅድሚ',
    'so': 'ka hor',
    'or': 'guyyaa',
    'en': ''
  };

  Map<String, String> befit = {
    'am': 'ቀን በፊት',
    'tr': 'መዓልቲ',
    'so': 'maalin',
    'or': 'dura',
    'en': ' days ago'
  };

  if (localLanguageNotifier.value == 'en') {
    return '$days${befit['en']}';
  } else {
    return '${ke[localLanguageNotifier.value]}$days ${befit[localLanguageNotifier.value]}';
  }
}

// Add this new function to the timeFormatter.dart file

String formatMatchTime(String dateTimeString) {
  DateTime now = DateTime.now();
  DateTime matchTime = DateTime.parse(dateTimeString).toLocal();
  Duration difference = matchTime.difference(now);

  if (difference.inSeconds.abs() < 60) {
    // Use a different approach to get the localized 'now' string
    return getLocalizedNow();
  } else if (difference.isNegative) {
    // Past times
    return formatTimeForNews(dateTimeString);
  } else {
    // Future times
    if (difference.inHours < 1) {
      return getLocalizedFutureMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return getLocalizedFutureHours(difference.inHours);
    } else if (difference.inDays < 7) {
      return getLocalizedFutureDays(difference.inDays);
    } else {
      return extractTimeFromIso(dateTimeString);
    }
  }
}

String getLocalizedNow() {
  Map<String, String> now = {
    'am': 'አሁን እየተካሄደ',
    'tr': 'ሕጂ',
    'so': 'Hadda',
    'or': 'Amma',
    'en': 'Now'
  };

  return now[localLanguageNotifier.value] ?? 'Now';
}

String getLocalizedFutureMinutes(int minutes) {
  Map<String, String> prefix = {
    'am': 'በ',
    'tr': 'ኣብ',
    'so': 'gudaha',
    'or': 'keessatti',
    'en': 'In '
  };

  Map<String, String> time = {
    'am': 'ደቂቃዎች በኋላ',
    'tr': 'ደቒቕ',
    'so': 'daqiiqo',
    'or': 'daqiiqaa',
    'en': ' minutes'
  };

  if (localLanguageNotifier.value == 'en') {
    return '${prefix['en']}$minutes${time['en']}';
  } else {
    return '${prefix[localLanguageNotifier.value]}$minutes ${time[localLanguageNotifier.value]}';
  }
}

String getLocalizedFutureHours(int hours) {
  Map<String, String> prefix = {
    'am': 'ከ',
    'tr': 'ኣብ',
    'so': 'gudaha',
    'or': 'keessatti',
    'en': 'In '
  };

  Map<String, String> time = {
    'am': 'ሰዓታት በኋላ',
    'tr': 'ሰዓት',
    'so': 'saac',
    'or': "sa'aatii",
    'en': ' hours'
  };

  if (localLanguageNotifier.value == 'en') {
    return '${prefix['en']}$hours${time['en']}';
  } else {
    return '${prefix[localLanguageNotifier.value]}$hours ${time[localLanguageNotifier.value]}';
  }
}

String getLocalizedFutureDays(int days) {
  Map<String, String> prefix = {
    'am': 'ከ',
    'tr': 'ኣብ',
    'so': 'gudaha',
    'or': 'keessatti',
    'en': 'In '
  };

  Map<String, String> time = {
    'am': 'ቀን በዃላ',
    'tr': 'መዓልቲ',
    'so': 'maalin',
    'or': 'guyyaa',
    'en': ' days'
  };

  if (localLanguageNotifier.value == 'en') {
    return '${prefix['en']}$days${time['en']}';
  } else {
    return '${prefix[localLanguageNotifier.value]}$days ${time[localLanguageNotifier.value]}';
  }
}
