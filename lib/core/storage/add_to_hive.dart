import 'package:hive/hive.dart';

Future<void> saveListToHiveBox(List<int> list, String boxName) async {
  var box = await Hive.openBox(boxName); // No type specified
  await box.put('list', list);
  await box.close();
}

@HiveType(typeId: 0)
class LocalizationData extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String value;

  LocalizationData({required this.key, required this.value});
}

class LocalizationDataAdapter extends TypeAdapter<LocalizationData> {
  @override
  final int typeId = 0;

  @override
  LocalizationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalizationData(
      key: fields[0] as String,
      value: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalizationData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
