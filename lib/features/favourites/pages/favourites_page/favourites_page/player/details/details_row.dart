import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

/// Used for personal info (Name, Age, Height, Weight, Country, etc.)
class PlayerDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const PlayerDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final String displayValue =
        value.trim() == 'null' || value.isEmpty ? '-' : value;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface.withOpacity(0.95),
            scheme.surfaceVariant.withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            displayValue,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextUtils.setTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextUtils.setTextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative style: Value on top, label below (used in key stats)
class Player_league_performanceDetailRow1 extends StatelessWidget {
  final String label;
  final String value;

  const Player_league_performanceDetailRow1({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final String displayValue =
        value.trim() == 'null' || value.isEmpty ? '-' : value;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: scheme.surface.withOpacity(0.9),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayValue,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextUtils.setTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            style: TextUtils.setTextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Used in detailed stats list with progress bars
class Player_stat_lists_DetailColumn extends StatelessWidget {
  final String label;
  final String value;
  final double? normalizedValue;

  const Player_stat_lists_DetailColumn({
    super.key,
    required this.label,
    required this.value,
    this.normalizedValue,
  });

  Color getProgressBarColor(double? value) {
    if (value == null) return Colors.grey.shade400;
    if (value >= 0.8) return Colors.green.shade600;
    if (value >= 0.6) return Colors.lightGreen.shade700;
    if (value >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final String displayValue =
        value.trim() == 'null' || value.isEmpty ? '-' : value;

    final bool hasProgress = normalizedValue != null;
    final double progress = (normalizedValue ?? 0).clamp(0.0, 1.0);
    final Color progressColor = getProgressBarColor(normalizedValue);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Label
          Expanded(
            flex: 4,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextUtils.setTextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),

          /// Value
          SizedBox(
            width: 64.w,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextUtils.setTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          /// Progress bar
          if (hasProgress) ...[
            SizedBox(width: 12.w),
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: progressColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            progressColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  if (progress > 0.35)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              color: Colors.black45,
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
