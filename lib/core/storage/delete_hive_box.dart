import 'package:hive/hive.dart';

Future<void> deleteHiveBox<T>(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<T>(boxName).close();
    }

    if (await Hive.boxExists(boxName)) {
      await Hive.deleteBoxFromDisk(boxName);
    }
  } catch (e) {
    print('Error deleting Hive box "$boxName": $e');
  }
}
