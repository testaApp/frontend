import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import '../../localization/demo_localization.dart';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';
import '../constants/text_utils.dart';
import 'phone_pay.dart';
import 'payment_choice.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.title});

  final String title;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  String? selectedId;
  late AnimationController _logoController;
  late AnimationController _cardsController;
  late Animation<double> _logoAnimation;
  late Animation<double> _cardsAnimation;
  late Future<List<SubscriptionPlan>> subscriptionPlansFuture;
  List<SubscriptionPlan> plans = [];

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _cardsController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _cardsAnimation =
        CurvedAnimation(parent: _cardsController, curve: Curves.easeOutBack);
    _logoController.forward();
    _cardsController.forward();

    subscriptionPlansFuture = fetchSubscriptionPlans();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  String getPlanPrice() {
    final plan = plans.firstWhere((plan) => plan.id == selectedId,
        orElse: () => SubscriptionPlan.empty());
    return plan.price;
  }

  String getPlanTitle() {
    final plan = plans.firstWhere((plan) => plan.id == selectedId,
        orElse: () => SubscriptionPlan.empty());
    return plan.title;
  }

  Widget planCard({
    required String id,
    required String title,
    required String duration,
    required String price,
    bool isPopular = false,
    required String paymentPeriod,
  }) {
    String localizedTitle =
        title == 'daily pass' ? DemoLocalizations.dailyPass : title;
    String localizedDuration = _getLocalizedDuration(duration);
    String localizedPrice = '$price ${DemoLocalizations.money}';

    return GestureDetector(
      onTap: () => setState(() => selectedId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selectedId == id
                ? [Colors.teal.shade300, Colors.teal.shade700]
                : [Colors.grey.shade300, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: selectedId == id
                  ? Colors.teal.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 30.h, left: 16.w, right: 16.w),
                    child: Center(
                      child: Text(
                        localizedTitle,
                        style: TextUtils.setTextStyle(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text(
                        localizedDuration,
                        style: TextUtils.setTextStyle(
                          fontSize: 20.sp,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h, left: 16.w),
                    child: Text(
                      localizedPrice,
                      style: TextUtils.setTextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isPopular)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DemoLocalizations.popular,
                      style: TextUtils.setTextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedDuration(String duration) {
    switch (duration) {
      case 'daily pass':
        return DemoLocalizations.dailyPass;
      case 'month':
        return DemoLocalizations.month;
      case 'months':
        return DemoLocalizations.months;
      case 'from card':
        return DemoLocalizations.fromCard;
      default:
        return duration;
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
            colors: [Colors.teal.shade700, Colors.teal.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              ScaleTransition(
                scale: _logoAnimation,
                child: Image.asset(
                  'assets/testa_logo.png',
                  height: 80.h,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: FutureBuilder<List<SubscriptionPlan>>(
                    future: subscriptionPlansFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No subscription plans available',
                                style: TextStyle(color: Colors.white)));
                      } else {
                        plans = snapshot.data!;
                        return AnimationLimiter(
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: plans.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                            ),
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  scale: 0.5,
                                  child: FadeInAnimation(
                                    child: planCard(
                                      id: plan.id,
                                      title: plan.title,
                                      duration: plan.duration,
                                      price: plan.price,
                                      isPopular: plan.isPopular,
                                      paymentPeriod: plan.paymentPeriod,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.h),
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => selectedId == '1day'
                              ? PhoneNumberPage(
                                  title: getPlanTitle(),
                                  price: getPlanPrice(),
                                  id: selectedId!,
                                )
                              : PaymentChoicePage(
                                  id: selectedId!,
                                  title: getPlanTitle(),
                                  price: double.parse(getPlanPrice()),
                                ),
                        ),
                      );
                    } else {
                      // Use ScaffoldMessenger with the current context to show the SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(DemoLocalizations.select_plan_to_continue),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16.0),
                          backgroundColor: Colors.teal.shade300,
                        ),
                      );
                    }

                    if (selectedId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => selectedId == '1day'
                              ? PhoneNumberPage(
                                  id: selectedId!,
                                  title: getPlanTitle(),
                                  price: getPlanPrice(),
                                )
                              : PaymentChoicePage(
                                  id: selectedId!,
                                  title: getPlanTitle(),
                                  price: double.parse(getPlanPrice()),
                                ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(DemoLocalizations.select_plan_to_continue),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16.0),
                          backgroundColor: Colors.teal.shade300,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.teal.shade700,
                    backgroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    DemoLocalizations.continueText,
                    style: TextUtils.setTextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextUtils.setTextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                          text: DemoLocalizations.terms_conditions_agreement),
                      TextSpan(
                        text: DemoLocalizations.read_them_here,
                        style: TextUtils.setTextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => launchUrlString('https://testa.et/terms'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 13.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<SubscriptionPlan>> fetchSubscriptionPlans() async {
    String url = BaseUrl().url;
    String token = await getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$url/api/paymentroute/subscription-plans'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseJson = json.decode(response.body);
        return responseJson
            .map((plan) => SubscriptionPlan.fromJson(plan))
            .toList();
      } else {
        throw Exception('Failed to load subscription plans');
      }
    } catch (error) {
      throw Exception('Error fetching subscription plans: $error');
    }
  }
}

class SubscriptionPlan {
  final String id;
  final String title;
  final String duration;
  final String price;
  final bool isPopular;
  final String paymentPeriod;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    required this.isPopular,
    required this.paymentPeriod,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      price: json['price'],
      isPopular: json['isPopular'],
      paymentPeriod: json['paymentPeriod'],
    );
  }

  static SubscriptionPlan empty() {
    return SubscriptionPlan(
      id: '',
      title: '',
      duration: '',
      price: '0',
      isPopular: false,
      paymentPeriod: '',
    );
  }
}
