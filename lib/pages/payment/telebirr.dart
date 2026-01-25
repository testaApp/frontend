import 'package:flutter/material.dart';
import '../../localization/demo_localization.dart';

class TelebirrPaymentPage extends StatefulWidget {
  final String selectedPlanId;
  final String selectedPlanTitle;
  final double selectedPlanPrice;

  const TelebirrPaymentPage({
    super.key,
    required this.selectedPlanId,
    required this.selectedPlanTitle,
    required this.selectedPlanPrice,
  });

  @override
  _TelebirrPaymentPageState createState() => _TelebirrPaymentPageState();
}

class _TelebirrPaymentPageState extends State<TelebirrPaymentPage> {
  final _phoneNumberController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.telebirrPayment),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the selected plan details
            Text(
              'Selected Plan: ${widget.selectedPlanTitle} (${widget.selectedPlanPrice.toStringAsFixed(2)} ${DemoLocalizations.money})',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: DemoLocalizations.phoneNumber,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle OTP sending
                print('Sending OTP to ${_phoneNumberController.text}');
              },
              child: Text(DemoLocalizations.getOTP),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: DemoLocalizations.enterOTP,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle Telebirr payment verification and completion
                print(
                    'Verifying OTP and paying ${widget.selectedPlanPrice} ETB for ${widget.selectedPlanTitle}');
              },
              child: Text(DemoLocalizations.verifyAndPay),
            ),
          ],
        ),
      ),
    );
  }
}
