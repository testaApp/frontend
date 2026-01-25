@echo off
echo Filtering Android logs...
adb logcat -c
adb shell setprop log.tag.ViewRootImpl ERROR
adb shell setprop log.tag.InsetsController ERROR
adb shell setprop log.tag.VRI ERROR
adb shell setprop log.tag.BLASTBufferQueue_Java ERROR
adb shell setprop log.tag.SurfaceView ERROR
adb shell setprop log.tag.Choreographer ERROR
adb shell setprop log.tag.ExoPlayerImpl ERROR
adb shell setprop log.tag.ProfileInstaller ERROR
echo Logs filtered!
echo Starting Flutter app...
flutter run