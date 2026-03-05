import 'package:get_it/get_it.dart';

import 'page_manager.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register page manager
  if (!getIt.isRegistered<PageManager>()) {
    getIt.registerLazySingleton<PageManager>(() => PageManager());
  }
}
