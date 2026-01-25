import 'package:hive/hive.dart';

Future<void> deleteHiveBox(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
      await box.close();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (await Hive.boxExists(boxName)) {
      await Hive.deleteBoxFromDisk(boxName);
    }
  } catch (e) {
    print('Error deleting Hive box: $e');
    try {
      await Hive.box(boxName).close();
    } catch (_) {}
  }
}
