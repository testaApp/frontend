import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/text_utils.dart';

class MatchStatusAndTime extends StatefulWidget {
  final String matchStatus;
  final int? extraTime;
  final String? startTimeString; // The start time in string format

  const MatchStatusAndTime({
    super.key,
    required this.matchStatus,
    this.extraTime,
    required this.startTimeString,
  });

  @override
  _MatchStatusAndTimeState createState() => _MatchStatusAndTimeState();
}

class _MatchStatusAndTimeState extends State<MatchStatusAndTime> {
  Timer? _timer;
  final ValueNotifier<Duration> _timeElapsed = ValueNotifier(Duration.zero);
  late DateTime startTime; // The parsed start time

  @override
  void initState() {
    super.initState();
    if (widget.startTimeString != null) {
      startTime = DateTime.parse(widget.startTimeString!);
      final currentTime = DateTime.now().toUtc();
      if (currentTime.isAfter(startTime)) {
        _timeElapsed.value = currentTime.difference(startTime);
        _checkTimerLimits();
      }
    } else {
      startTime = DateTime.now().toUtc();
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isMatchStillValid()) {
      return; // Don't start the timer if the match should be finished
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now().toUtc();

      if (currentTime.isAfter(startTime)) {
        final difference = currentTime.difference(startTime);
        _timeElapsed.value = difference;
      } else {
        _timeElapsed.value = Duration.zero;
      }

      _checkTimerLimits();
    });
  }

  bool _isMatchStillValid() {
    if (widget.startTimeString == null) return false;

    final now = DateTime.now().toUtc();
    final matchStart = DateTime.parse(widget.startTimeString!);

    // Calculate expected match end time (assuming 2 hours max for any match)
    final expectedEndTime = matchStart.add(const Duration(hours: 2));

    // If we're past the expected end time, the match should be finished
    return now.isBefore(expectedEndTime);
  }

  void _checkTimerLimits() {
    int maxMinutes = 45; // Default for the first half
    int baseMinutes = 0;

    switch (widget.matchStatus) {
      case '2H':
        maxMinutes = 90;
        baseMinutes = 45;
        break;
      case 'KO1':
        maxMinutes = 105;
        baseMinutes = 90;
        break;
      case 'KO2':
        maxMinutes = 120;
        baseMinutes = 105;
        break;
    }

    // Adjust for extra time
    if (widget.extraTime != null) {
      maxMinutes += widget.extraTime!;
    }

    // Calculate actual minutes elapsed since the start of current period
    final currentPeriodElapsed = _timeElapsed.value.inMinutes - baseMinutes;

    // Only show time beyond base minutes if we've actually reached that period
    if (_timeElapsed.value.inMinutes >= baseMinutes) {
      if (currentPeriodElapsed >= (maxMinutes - baseMinutes)) {
        _timer?.cancel();
        _timeElapsed.value = Duration(minutes: maxMinutes);
      }
    } else {
      // If we haven't reached the base minutes for this period, cap at previous period
      _timeElapsed.value = Duration(minutes: baseMinutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.startTimeString == null
        ? const SizedBox.shrink()
        : ValueListenableBuilder<Duration>(
            valueListenable: _timeElapsed,
            builder: (context, value, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16.w,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatMatchTime(value, widget.matchStatus),
                      style: TextUtils.setTextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "'",
                      style: TextUtils.setTextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  String _formatMatchTime(Duration duration, String status) {
    if (!_isMatchStillValid()) {
      return 'FT';
    }

    if (status == 'LIVE') {
      return 'LIVE';
    }

    int baseMinutes = 0;
    int currentMinutes = duration.inMinutes;

    switch (status) {
      case '2H':
        baseMinutes = 45;
        // Only add elapsed time if we're actually in second half
        if (currentMinutes < 45) currentMinutes = 45;
        break;
      case 'KO1':
        baseMinutes = 90;
        if (currentMinutes < 90) currentMinutes = 90;
        break;
      case 'KO2':
        baseMinutes = 105;
        if (currentMinutes < 105) currentMinutes = 105;
        break;
    }

    final displayMinutes = max(baseMinutes, currentMinutes);

    // Add extra time indicator if applicable
    if (['1H', '2H', 'KO1', 'KO2'].contains(status) &&
        widget.extraTime != null &&
        widget.extraTime! > 0) {
      return '$displayMinutes+${widget.extraTime}';
    }

    return displayMinutes.toString().padLeft(2, '0');
  }
}
