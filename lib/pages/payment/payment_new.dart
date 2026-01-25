// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../localization/demo_localization.dart';
// import '../../newsHomepage.dart';
// import '../../util/auth/tokens.dart';
// import '../../util/baseUrl.dart';
// import '../constants/colors.dart';
// import '../constants/text_utils.dart';
// import 'payment_choice.dart';
// import 'phone_pay.dart';

// class SubscriptionPage extends StatefulWidget {
//   @override
//   _SubscriptionPageState createState() => _SubscriptionPageState();
// }

// class _SubscriptionPageState extends State<SubscriptionPage> {
//   String? selectedSubscription;
//   bool isLoading = false;
//   late Future<Map<String, SubscriptionPlan>> subscriptionOptionsFuture;

//   @override
//   void initState() {
//     super.initState();
//     subscriptionOptionsFuture = fetchSubscriptionPlans();
//   }

//   Future<Map<String, SubscriptionPlan>> fetchSubscriptionPlans() async {
//     String url = BaseUrl().url;
//     String token = await getAccessToken();

//     try {
//       final response = await http.get(
//         Uri.parse('$url/api/paymentroute/subscription-plans'),
//         headers: {
//           'Content-Type': 'application/json',
//           'accesstoken': token,
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> plansJson = json.decode(response.body);
//         return plansJson.map((key, value) => MapEntry(
//               key,
//               SubscriptionPlan(
//                 value['id'],
//                 value['title'],
//                 value['price'].toDouble(),
//               ),
//             ));
//       } else {
//         throw Exception('Failed to load subscription plans');
//       }
//     } catch (error) {
//       throw Exception('Error: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) async {
//         if (didPop) return;
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false, // This removes the back button
//           centerTitle: true, // This centers the title

//           title: Text(
//             DemoLocalizations.chooseYourSubscription,
//             style: TextUtils.setTextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: FutureBuilder<Map<String, SubscriptionPlan>>(
//           future: subscriptionOptionsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(
//                   child: Text('${DemoLocalizations.error}: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                   child: Text(DemoLocalizations.noSubscriptionPlansAvailable));
//             }

//             final subscriptionOptions = snapshot.data!;

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     DemoLocalizations.selectSubscriptionPlan,
//                     style: TextUtils.setTextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   ...subscriptionOptions.entries.map((entry) {
//                     return SubscriptionCard(
//                       plan: entry.value,
//                       isSelected: entry.key == selectedSubscription,
//                       onTap: () {
//                         setState(() {
//                           selectedSubscription = entry.key;
//                         });
//                       },
//                     );
//                   }).toList(),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             if (selectedSubscription == null) return;

//                             if (selectedSubscription == '4') {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => PhoneNumberPage()),
//                               );
//                             } else {
//                               final selectedPlan =
//                                   subscriptionOptions[selectedSubscription!];
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PaymentChoicePage(
//                                     selectedPlanId: selectedPlan!.id,
//                                     selectedPlanTitle: selectedPlan.title,
//                                     selectedPlanPrice: selectedPlan.price,
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                     child: isLoading
//                         ? CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white),
//                           )
//                         : Text(
//                             DemoLocalizations.continueText,
//                             style: TextUtils.setTextStyle(
//                               fontSize: 18, // Font size
//                               fontWeight: FontWeight.bold, // Font weight
//                               color: Colors.white, // Text color
//                             ),
//                           ),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: Colorscontainer.greenColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ), // Background color of the button
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class SubscriptionPlan {
//   final String id;
//   final String title;
//   final double price;

//   SubscriptionPlan(this.id, this.title, this.price);
// }

// class SubscriptionCard extends StatelessWidget {
//   final SubscriptionPlan plan;
//   final bool isSelected;
//   final VoidCallback onTap;

//   SubscriptionCard({
//     required this.plan,
//     required this.isSelected,
//     required this.onTap,
//   });

//   String _formatTitle(String title) {
//     if (title.contains(' Months')) {
//       final parts = title.split(' ');
//       return '${parts[0]} ${DemoLocalizations.months}';
//     } else if (title.contains(' Year')) {
//       final parts = title.split(' ');
//       return '${parts[0]} ${DemoLocalizations.year}';
//     } else if (title == 'Daily Pass') {
//       return DemoLocalizations.dailyPass;
//     }
//     return title;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[700] : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.4),
//                 spreadRadius: 5,
//                 blurRadius: 20,
//                 offset: Offset(0, 5),
//               ),
//           ],
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         padding: EdgeInsets.all(20),
//         margin: EdgeInsets.symmetric(vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   isSelected
//                       ? Icons.check_circle
//                       : Icons.radio_button_unchecked,
//                   color: isSelected ? Colors.white : Colors.grey,
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     _formatTitle(plan.title),
//                     style: TextUtils.setTextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: isSelected ? Colors.white : Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               '${plan.price.toStringAsFixed(2)} ${DemoLocalizations.money}',
//               style: TextUtils.setTextStyle(
//                 fontSize: 18,
//                 color: isSelected ? Colors.white : Colors.grey[600],
//               ),
//             ),
//             if (isSelected)
//               Padding(
//                 padding: const EdgeInsets.only(top: 12.0),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.star,
//                       color: Colors.yellow,
//                       size: 20,
//                     ),
//                     SizedBox(width: 5),
//                     Text(
//                       DemoLocalizations.bestValue,
//                       style: TextUtils.setTextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
