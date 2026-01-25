import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../localization/demo_localization.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/colors.dart';
import 'countdown.dart';

class PhoneNumberPage extends StatefulWidget {
  final String id;
  final String title;
  final String price;

  const PhoneNumberPage({
    super.key,
    required this.id,
    required this.title,
    required this.price,
  });

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with SingleTickerProviderStateMixin {
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _validateAndProceed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulating a short delay before proceeding
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // Show confirmation dialog
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(DemoLocalizations.sms_confirmation,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(DemoLocalizations.sms_redirect_message),
            actions: [
              TextButton(
                child: Text(DemoLocalizations.continueText,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchSmsApp();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _launchSmsApp() async {
    String url = BaseUrl().url;
    String token = await getAccessToken();
    String userPhoneNumber = _phoneNumberController.text;

    try {
      // Make API call to fetch shortcode and message from the backend
      final response = await http.get(
        Uri.parse('$url/api/paymentroute/sendShortcode'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String shortcode = data['shortcode'].toString(); // From backend
        final String message = data['message'];

        // Launch the SMS app with the shortcode and user-entered phone number
        final Uri smsLaunchUri =
            Uri.parse('sms:$shortcode?body=${Uri.encodeComponent(message)}');

        final bool launched = await launchUrl(
          smsLaunchUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );

        if (launched) {
          // Navigate to CountdownPage and pass the user phone number
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CountdownPage(
                  phoneNumber: userPhoneNumber,
                  planId: widget.id // Pass the user phone number
                  ),
            ),
          );
        } else {
          throw 'Could not launch SMS app';
        }
      } else {
        throw 'Failed to load SMS data from backend';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open SMS app: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colorscontainer.greenShade, Colorscontainer.greenColor],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/images/phone_illustration.svg',
                                  height: constraints.maxHeight * 0.3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                DemoLocalizations.enter_your_phone_number,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneNumberController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: DemoLocalizations.phoneNumber,
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  prefixIcon: const Icon(Icons.phone,
                                      color: Colors.white70),
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return DemoLocalizations
                                        .enter_your_phone_number;
                                  } else if (value.length < 10) {
                                    return DemoLocalizations
                                        .enter_valid_phone_number;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _validateAndProceed,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.blue.shade800)
                                      : Text(DemoLocalizations.continueText,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue.shade800)),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
