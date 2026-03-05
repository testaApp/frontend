# lib structure

- core/ contains cross-cutting infrastructure.
- core/network holds `BaseUrl` and `ApiManager`.
- core/notifiers holds app-wide `ValueNotifier`s.
- core/storage holds shared persistence helpers.
- data/ contains data providers and repositories.
- shared/ holds shared UI widgets, constants, and styles.
- state/ holds app-wide BLoC/Application state management code.
- features/ holds feature-first code.
- features/auth/services contains auth-related services (Firebase, social sign-in, device id).
- features/auth/pages contains login and profile-related screens.
- features/onboarding/pages contains entry flow pages.
- features/payment/pages contains payment flows.
- features/navigation/pages contains navigation and quiz flows.
- features/news/pages contains news flows.
- features/enadamt/pages contains audio/podcast flows.
- features/favourites/pages contains favourites flows.
- features/matches/pages contains match flows.
- features/standing/pages contains standings/leagues flows.
- features/leagues/pages contains league-specific pages.
- features/tv/pages contains live TV/highlights flows.
- features/video/pages contains video highlight flows.
- features/commerce/pages contains commerce pages.
- legacy/ holds deprecated or unused files kept for reference only.

Compatibility stubs:
- lib/pages/entry_pages/*.dart export their new locations.
- lib/pages/login/*.dart export their new locations.
- lib/pages/payment/*.dart export their new locations.
- lib/pages/navigation/**/*.dart export their new locations.
- lib/pages/appbar_pages/**/*.dart export their new locations.
- lib/pages/bottom_navigation/**/*.dart export their new locations.
- lib/pages/leagues_page/*.dart export their new locations.
- lib/pages/testa_gebeya/*.dart export their new locations.
- lib/pages/functions/*.dart export their new locations.
- lib/pages/styles/*.dart export their new locations.
- lib/pages/constants/*.dart export their new locations.
- lib/bloc/**/*.dart export their new locations.
- lib/application/**/*.dart export their new locations.
- lib/Infrastructure/*.dart export their new locations.
- lib/repository/*.dart export their new locations.
- lib/constants/*.dart export their new locations.
- lib/widgets/**/*.dart export their new locations.
- lib/util/auth/*.dart export their new locations.
- lib/util/baseUrl.dart exports the new location.
- lib/util/api_manager/api_manager.dart exports the new location.
- lib/util/notifiers/*.dart export their new locations.
- lib/util/add_to_hive.dart exports the new location.
- lib/util/delete_hive_box.dart exports the new location.

When touching files, prefer package imports (package:blogapp/...) to keep paths stable.
