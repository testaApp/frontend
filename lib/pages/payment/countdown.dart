import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../components/routenames.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/colors.dart';

class CountdownPage extends StatefulWidget {
  final String phoneNumber;
  final String planId;

  const CountdownPage({
    super.key,
    required this.phoneNumber,
    required this.planId,
  });

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _statusCheckTimer;
  int _remainingTime = 300; // 5 minutes countdown
  String? _transactionId;
  String _paymentStatus = 'pending'; // 'pending', 'failed', or 'success'

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 300),
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _startCountdown();
    _createPaymentOrder();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _handleCountdownFinished();
      }
    });
  }

  void _handleCountdownFinished() {
    if (_paymentStatus == 'failed') {
      _showDialog(
          'Payment Failed', 'The payment process has failed. Please try again.',
          isError: true);
    } else if (_paymentStatus == 'pending') {
      _showDialog('Timeout',
          'The payment could not be confirmed. Please check your payment status.',
          isError: true);
    }
  }

  Future<void> _createPaymentOrder() async {
    final baseUrl = BaseUrl().url;
    final accessToken = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'accesstoken': accessToken,
    };

    final requestBody = jsonEncode({
      'planId': widget.planId,
      'phoneNumber': widget.phoneNumber,
    });

    try {
      final url = '$baseUrl/api/user/payment/sms-order';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        setState(() {
          _transactionId = data['transactionId'];
        });
        _startPollingStatus();
      } else {
        _showDialog(
            'Error', 'Failed to create payment order. Please try again.',
            isError: true);
      }
    } catch (e) {
      _showDialog('Network Error',
          'Please check your internet connection and try again.',
          isError: true);
    }
  }

  void _startPollingStatus() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_transactionId == null) return;

    final baseUrl = BaseUrl().url;
    final accessToken = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'accesstoken': accessToken,
    };

    final requestBody = jsonEncode({
      'transactionId': _transactionId,
    });

    try {
      final url = '$baseUrl/api/user/payment/sms-order';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        switch (data['status']) {
          case 'success':
            _statusCheckTimer?.cancel();
            _controller.stop();
            setState(() {
              _paymentStatus = 'success';
            });
            _showDialog('Success',
                'Your SMS subscription has been created successfully.',
                isSuccess: true);
            break;
          case 'pending':
            // Continue polling
            break;
          case 'failed':
            _statusCheckTimer?.cancel();
            _controller.stop();
            setState(() {
              _paymentStatus = 'failed';
            });
            _showDialog('Payment Failed',
                'The payment process has failed. Please try again.',
                isError: true);
            break;
          default:
            _showDialog('Unknown Status',
                'An unknown payment status was received. Please contact support.',
                isError: true);
        }
      } else {
        _showDialog(
            'Error', 'Failed to check payment status. Please try again.',
            isError: true);
      }
    } catch (e) {
      _showDialog('Network Error',
          'Please check your internet connection and try again.',
          isError: true);
    }
  }

  void _showDialog(String title, String message,
      {bool isError = false, bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isError
              ? Colors.red[50]
              : (isSuccess ? Colors.green[50] : Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: TextStyle(
              color: isError
                  ? Colors.red
                  : (isSuccess ? Colors.green : Colors.black),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.goNamed(RouteNames.entrypage);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: isError
                      ? Colors.red
                      : (isSuccess ? Colors.green : Colors.blue),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colorscontainer.greenColor,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Processing Payment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colorscontainer.greenColor,
                      ),
                    ),
                  ),
                  Text(
                    '${(_remainingTime / 60).floor()}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Status: ${_paymentStatus.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _paymentStatus == 'success'
                      ? Colors.green
                      : (_paymentStatus == 'failed'
                          ? Colors.red
                          : Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please wait while we process your payment.\nDo not close this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
