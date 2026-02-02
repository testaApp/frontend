# Keep basic Flutter stuff
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase (very important!)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# audio_service + just_audio (common freeze cause)
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**
-keep class com.google.android.exoplayer.** { *; }
-dontwarn com.google.android.exoplayer.**

# Hive
-keep class com.hive.** { *; }
-dontwarn com.hive.**

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Your original rule (keep it)
-dontwarn com.josephcrowell.flutter_open_app_settings.**
-keep class com.josephcrowell.flutter_open_app_settings.** { *; }