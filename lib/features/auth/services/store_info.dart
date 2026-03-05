import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> storeInformation(
    {required String key, required String value}) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  await storage.write(key: key, value: value);
}

Future<String?> getInformation({required String key}) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  final value = await storage.read(key: key);
  return value;
}
