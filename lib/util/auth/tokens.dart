import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> storeAccessToken(String token) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  await storage.write(key: 'accessToken', value: token);
}

Future<void> storeRefreshToken(String token) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  await storage.write(key: 'refreshToken', value: token);
}

Future<void> clearTokens() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  await storage.deleteAll();
}

Future<String> getAccessToken() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  String? accessToken = await storage.read(key: 'accessToken');
  if (accessToken == null) {
    throw Exception('Access token is null');
  }
  return accessToken;
}

Future<String?> getRefreshToken() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
  String? refreshToken = await storage.read(key: 'refreshToken');
  return refreshToken;
}
