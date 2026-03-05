import 'package:ethiopian_calendar_plus/converters.dart';
import 'package:ethiopian_calendar_plus/ethiopian_date.dart';

void main() {
  DateTime now = DateTime(2026, 3, 6);
  EthiopianDate ethiopianDate = EthiopianDateConverter.gregorianToEthiopian(now);
  print('Date: ${now.year}-${now.month}-${now.day}');
  print('Ethiopian Date: ${ethiopianDate.year}-${ethiopianDate.month}-${ethiopianDate.day}');
}
