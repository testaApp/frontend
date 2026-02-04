import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  static Future<void> initializeAnonymousAuth() async {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      debugPrint('Already signed in → UID: ${auth.currentUser?.uid}');
      await FirebaseAnalytics.instance.setUserId(id: auth.currentUser!.uid);
      return;
    }

    try {
      final userCredential = await auth.signInAnonymously();
      final uid = userCredential.user?.uid;
      if (uid != null) {
        debugPrint('Anonymous sign-in successful → UID: $uid');
        await FirebaseAnalytics.instance.setUserId(id: uid);
      }
    } catch (e) {
      debugPrint('Anonymous sign-in error: $e');
    }
  }
}