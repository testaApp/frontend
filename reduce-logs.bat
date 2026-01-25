@echo off
adb logcat -c
adb shell setprop log.tag.ViewRootImpl ERROR
adb shell setprop log.tag.InsetsController ERROR
adb shell setprop log.tag.VRI ERROR
adb shell setprop log.tag.AAudio ERROR
adb shell setprop log.tag.BufferPoolAccessor2.0 ERROR
echo Logs filtered!