import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../localization/demo_localization.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/text_utils.dart';

class ChapaPaymentPage extends StatefulWidget {
  final String selectedPlanId;
  final String selectedPlanTitle;
  final double selectedPlanPrice;

  const ChapaPaymentPage({
    super.key,
    required this.selectedPlanId,
    required this.selectedPlanTitle,
    required this.selectedPlanPrice,
  });

  @override
  _ChapaPaymentPageState createState() => _ChapaPaymentPageState();
}

class _ChapaPaymentPageState extends State<ChapaPaymentPage> {
  String? _paymentUrl;
  bool _isLoading = true;
  late WebViewController _webViewController;
  String? _txRef;

  @override
  void initState() {
    super.initState();
    _initializePayment();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
            _checkPaymentStatus(url);
          },
        ),
      );
  }

  Future<void> _initializePayment() async {
    setState(() {
      _isLoading = true;
    });

    String url = BaseUrl().url;
    String token = await getAccessToken();

    print('Sending payment initialization request:');
    print('URL: $url/api/paymentroute/process-payment');
    print('Headers: {Content-Type: application/json, accesstoken: $token}');
    print('Body: ${jsonEncode({
          'amount': widget.selectedPlanPrice.toString(),
        })}');

    try {
      final response = await http.post(
        Uri.parse('$url/api/paymentroute/process-payment'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': token,
        },
        body: jsonEncode({
          'amount': widget.selectedPlanPrice,
        }),
      );

      print('Received payment initialization response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded response data: $data');
        if (data.containsKey('checkout_url') && data.containsKey('tx_ref')) {
          setState(() {
            _paymentUrl = data['checkout_url'];
            _txRef = data['tx_ref'];
            _isLoading = false;
          });
          _webViewController.loadRequest(Uri.parse(_paymentUrl!));
          print('Payment URL: $_paymentUrl');
          print('Transaction Reference: $_txRef');
        } else {
          print(
              'Error: Payment URL or Transaction Reference not found in the response');
          throw Exception(
              'Payment URL or Transaction Reference not found in the response');
        }
      } else {
        print(
            'Error: Failed to initialize payment. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to initialize payment. Status code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      print('Error initializing payment: $error');
    }
  }

  Future<void> _checkPaymentStatus(String url) async {
    if (url.contains('success') && _txRef != null) {
      // Payment might be successful, verify with the server
      await _verifyPayment();
    } else if (url.contains('cancel') || url.contains('error')) {
      // Payment was cancelled or failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment was cancelled or failed')),
      );
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  Future<void> _verifyPayment() async {
    setState(() {
      _isLoading = true;
    });

    String url = BaseUrl().url;
    String token = await getAccessToken();

    print('Sending payment verification request:');
    print('URL: $url/api/paymentroute/verify-payment/$_txRef');
    print('Headers: {Content-Type: application/json, accesstoken: $token}');

    try {
      final response = await http.get(
        Uri.parse('$url/api/paymentroute/verify-payment/$_txRef'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': token,
        },
      );

      print('Received payment verification response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded verification response data: $data');
        if (data['success'] == true) {
          // Payment verified successfully
          print('Payment verified successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          // TODO: Update user's subscription status here
          Navigator.of(context).pop(); // Return to previous screen
        } else {
          print('Payment verification failed: ${data['message']}');
          throw Exception('Payment verification failed: ${data['message']}');
        }
      } else {
        print('Failed to verify payment. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to verify payment. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error verifying payment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying payment: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DemoLocalizations.chapaPayments,
          style: TextUtils.setTextStyle(),
        ),
      ),
      body: Stack(
        children: [
          if (_paymentUrl != null)
            WebViewWidget(controller: _webViewController),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_paymentUrl == null && !_isLoading)
            Center(child: Text(DemoLocalizations.subscriptionUpdateFailed)),
        ],
      ),
    );
  }
}
