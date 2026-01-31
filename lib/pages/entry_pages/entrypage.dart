import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/routenames.dart';
import 'package:http/http.dart' as http;
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
    _initializeEntryPage();
  }

  // ✅ SIMPLIFIED: Just fetch payment status and set up auto-navigation
  Future<void> _initializeEntryPage() async {
    await fetchPaymentStatus();
    _navigateToNextPageAfterDelay();
  }

  // ❌ REMOVE _checkForNotification() completely - main.dart handles it now

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
        debugPrint('Payment status: $data');
        setState(() {
          freeTrialExpired = data['freeTrialExpired'] ?? false;
          subscriptionExpired = data['subscriptionExpired'] ?? false;
        });
        showPaymentReminderDialog();
      } else {
        throw Exception('Failed to load payment status');
      }
    } catch (e) {
      debugPrint('Error fetching payment status: $e');
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
                builder: (context) => const PaymentPage(title: 'payment'),
              ),
            );
          },
          onDismiss: () {
            setState(() {
              _isPaymentDialogShown = false;
            });
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

void _navigateToNextPageAfterDelay() {
  Future.delayed(const Duration(seconds: 5), () {
    if (!mounted) return;

    // ✅ CHECK: Get the current path. 
    // If it's not '/entrypage', a notification already navigated us.
    final String currentPath = GoRouterState.of(context).uri.path;
    
    if (currentPath != '/entrypage') {
      debugPrint('🚫 Notification navigation active. Cancelling auto-home redirect.');
      return; 
    }

    if (!_isPaymentDialogShown) {
      debugPrint('✅ No notification, proceeding to home.');
      context.goNamed(RouteNames.home);
    }
  });
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