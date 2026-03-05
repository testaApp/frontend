import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/components/getAmharicDay.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class MatchTimerWidget extends StatefulWidget {
  final String matchStatus;
  final int? extraTime;
  final String startTimeString; // The start time in string format
  final String? dateOnly;
  const MatchTimerWidget(
      {super.key,
      required this.matchStatus,
      this.extraTime,
      required this.startTimeString,
      this.dateOnly});

  @override
  _MatchTimerWidgetState createState() => _MatchTimerWidgetState();
}

class _MatchTimerWidgetState extends State<MatchTimerWidget> {
  Timer? _timer;
  final ValueNotifier<Duration> _timeElapsed = ValueNotifier(const Duration());
  late DateTime startTime; // The parsed start time

  @override
  void initState() {
    super.initState();
    startTime = DateTime.parse(widget.startTimeString)
        .toUtc(); // Parsing the start time
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now().toUtc();
      final difference = currentTime.difference(startTime);

      _timeElapsed.value = difference;
      _checkTimerLimits();
    });
  }

  void _checkTimerLimits() {
    int maxMinutes = 45; // Default for the first half
    if (widget.matchStatus == '2H') {
      maxMinutes = 90; // Second half
    } else if (widget.matchStatus == 'KO1') {
      maxMinutes = 105; // First half of extra time in knockout
    } else if (widget.matchStatus == 'KO2') {
      maxMinutes = 120; // Second half of extra time in knockout
    }

    // Adjust for extra time
    if (widget.extraTime != null) {
      maxMinutes += widget.extraTime!;
    }

    // Check if the current time elapsed exceeds the max time limit
    if (_timeElapsed.value.inMinutes >= maxMinutes) {
      _timer?.cancel(); // Stop the timer
      _timeElapsed.value = Duration(minutes: maxMinutes); // Set to max time
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _timeElapsed,
      builder: (context, value, child) {
        if (['FT', 'PST', 'AET', 'CANC', 'NS', 'ABD', 'AWD', 'WO']
            .contains(widget.matchStatus)) {
          return Text(
            widget.dateOnly != null
                ? getAmharicMonthName(widget.dateOnly!)
                : '',
            style: TextUtils.setTextStyle(fontSize: 15.sp, color: Colors.white),
          );
        }
        if (_timeElapsed.value.inMinutes > 90) {
          return Text("90'",
              style:
                  TextUtils.setTextStyle(color: Colors.grey, fontSize: 15.sp));
        }
        return Text(
          _formatMatchTime(value, widget.matchStatus),
          style: TextUtils.setTextStyle(color: Colors.white, fontSize: 15.sp),
        );
      },
    );
  }

  String _formatMatchTime(Duration duration, String status) {
    int baseMinutes = 0;

    // Adjust base minutes depending on the match status
    if (status == '2H') {
      baseMinutes = 45; // Add 45 minutes for the second half
    } else if (status == 'KO2') {
      baseMinutes = 105; // First half of extra time in knockout
    } else if (status.startsWith('KO')) {
      baseMinutes = 90; // Second half of extra time in knockout
    }

    // Calculate total time
    final minutesValue = baseMinutes + duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final minutes = minutesValue > 90 ? 90 : minutesValue;
    // Format the string to show the time
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
