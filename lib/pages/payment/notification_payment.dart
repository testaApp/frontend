import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../components/routenames.dart';
import '../../localization/demo_localization.dart';
import '../constants/colors.dart';
import '../constants/text_utils.dart';
import 'payment_page.dart';

class PaymentReminderDialog extends StatelessWidget {
  final bool freetrialExpired;
  final bool subscriptionExpired;
  final VoidCallback onSubscribe;
  final VoidCallback onDismiss;

  const PaymentReminderDialog({
    super.key,
    required this.freetrialExpired,
    required this.subscriptionExpired,
    required this.onSubscribe,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFullScreen = freetrialExpired || subscriptionExpired;
    final String title = subscriptionExpired
        ? DemoLocalizations.subscriptionExpired
        : freetrialExpired
            ? DemoLocalizations.freeTrialEnded
            : DemoLocalizations.Subscribe;
    final String message = subscriptionExpired
        ? DemoLocalizations.subscriptionExpiredMessage
        : freetrialExpired
            ? DemoLocalizations.freeTrialEndedMessage
            : DemoLocalizations.subscriptionExpiredMessage;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h),
        Icon(
          subscriptionExpired || freetrialExpired
              ? Icons.access_time
              : Icons.star,
          size: 60.sp,
          color: Colorscontainer.greenColor,
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextUtils.setTextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextUtils.setTextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 30.h),
        ElevatedButton(
          onPressed: () {
            onSubscribe();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PaymentPage(title: 'payment'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colorscontainer.greenColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            elevation: 0,
          ),
          child: Text(
            DemoLocalizations.Subscribe,
            style: TextUtils.setTextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        if (!isFullScreen) ...[
          SizedBox(height: 15.h),
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              DemoLocalizations.dismiss,
              style: TextUtils.setTextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        context.goNamed(RouteNames.entrypage);
      },
      child: isFullScreen
          ? Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: content,
                    ),
                  ),
                ),
              ),
            )
          : Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                child: content,
              ),
            ),
    );
  }
}
