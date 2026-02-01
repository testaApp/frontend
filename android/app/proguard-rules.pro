# 1. Stop R8 from reporting warnings about this plugin
-dontwarn com.josephcrowell.flutter_open_app_settings.**

# 2. Tell R8 to NOT delete or rename this plugin's code
-keep class com.josephcrowell.flutter_open_app_settings.** { *; }