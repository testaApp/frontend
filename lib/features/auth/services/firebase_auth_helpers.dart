import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blogapp/core/notifiers/username_notifier.dart';
import 'package:blogapp/features/auth/services/firebase_auth_service.dart';
import 'package:blogapp/features/auth/services/store_info.dart';

Future<User?> ensureFirebaseUser() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await FirebaseAuthService.initializeAnonymousAuth();
  }
  return auth.currentUser;
}

Future<String?> getFirebaseIdToken({bool forceRefresh = false}) async {
  final user = await ensureFirebaseUser();
  if (user == null) return null;
  return user.getIdToken(forceRefresh);
}

Future<Map<String, String>> buildAuthHeaders(
    {bool includeJson = true}) async {
  final headers = <String, String>{};
  if (includeJson) {
    headers['Content-Type'] = 'application/json';
  }
  final token = await getFirebaseIdToken();
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}

Future<void> cacheUserInfo({String? name, String? phone}) async {
  final prefs = await SharedPreferences.getInstance();

  if (name != null && name.trim().isNotEmpty) {
    await prefs.setString('name', name);
    await storeInformation(key: 'name', value: name);
    userNameNotifier.value = name;
  }

  if (phone != null && phone.trim().isNotEmpty) {
    await prefs.setString('phoneNumber', phone);
    await storeInformation(key: 'phoneNumber', value: phone);
    phonenumberNotifier.value = phone;
  }
}

Future<void> signOutToAnonymous() async {
  await FirebaseAuth.instance.signOut();
  await FirebaseAuthService.initializeAnonymousAuth();
}
