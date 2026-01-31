// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart'; // to access globalRouter

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  String? _pendingRoute;
  Map<String, dynamic>? _pendingExtra;

  void setPendingNavigation(String route, {Map<String, dynamic>? extra}) {
    _pendingRoute = route;
    _pendingExtra = extra;
    debugPrint('📌 NavigationService: Stored pending → $route');
    if (extra != null) debugPrint('   extra: $extra');
  }

  void clearPending() {
    _pendingRoute = null;
    _pendingExtra = null;
  }

  void executePendingIfAny() {
    if (_pendingRoute == null) return;

    debugPrint('🔄 NavigationService: Executing pending navigation');
    debugPrint('   Route: $_pendingRoute');

    try {
      if (_pendingExtra != null && _pendingExtra!.isNotEmpty) {
        globalRouter.go(_pendingRoute!, extra: _pendingExtra);
      } else {
        globalRouter.go(_pendingRoute!);
      }
    } catch (e, st) {
      debugPrint('❌ Pending navigation failed: $e');
      debugPrint(st as String?);
      globalRouter.go('/home');
    }

    clearPending();
  }
}