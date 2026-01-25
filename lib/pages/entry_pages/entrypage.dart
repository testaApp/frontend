import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import '../../components/routenames.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../notifications/notifier.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../payment/notification_payment.dart';
import '../payment/payment_page.dart';

class entrypage extends StatefulWidget {
  const entrypage({super.key});

  @override
  State<entrypage> createState() => entryPageState();
}

class entryPageState extends State<entrypage> {
  bool freeTrialExpired = false;
  bool subscriptionExpired = false;
  bool _isPaymentDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
    _initializeNotificationPlugin();
    fetchPaymentStatus();
    _navigateToNextPageAfterDelay();
  }

  Future<void> _initializeAsync() async {
    tz.initializeTimeZones();

    await Future.wait<void>([
      fetchLocalizationValues('am'),
      fetchLocalizationValues('en'),
      fetchLocalizationValues('tr'),
      fetchLocalizationValues('so'),
      fetchLocalizationValues('or'),
    ]);
  }

  Future<void> fetchPaymentStatus() async {
    String url = BaseUrl().url;
    String token = await getAccessToken();
    try {
      final response = await http.get(
        Uri.parse('$url/api/paymentroute/paymentnotify'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': token,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('the data $data');
        setState(() {
          freeTrialExpired = data['freeTrialExpired'] ?? false;
          subscriptionExpired = data['subscriptionExpired'] ?? false;
        });
        showPaymentReminderDialog();
      } else {
        throw Exception('Failed to load payment status');
      }
    } catch (e) {
      print('Error fetching payment status: $e');
    }
  }

  void showPaymentReminderDialog() {
    if (freeTrialExpired || subscriptionExpired) {
      setState(() {
        _isPaymentDialogShown = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PaymentReminderDialog(
          freetrialExpired: freeTrialExpired,
          subscriptionExpired: subscriptionExpired,
          onSubscribe: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const PaymentPage(
                        title: 'payment',
                      )),
            );
          },
          onDismiss: () {
            setState(() {
              _isPaymentDialogShown =
                  false; // Reset flag when dialog is dismissed
            });
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _navigateToNextPageAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isPaymentDialogShown) {
        print('Navigating to the home page');
        GoRouter.of(context).goNamed(RouteNames.home);
      }
    });
  }

  void _initializeNotificationPlugin() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('testaapp');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        child: Image.asset(
          'assets/Testa-intro.gif',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
