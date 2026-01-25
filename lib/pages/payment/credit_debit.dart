// import 'package:flutter/material.dart';
// import 'package:flutter_credit_card/credit_card_brand.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';

// class CreditCardPaymentPage extends StatefulWidget {
//   CreditCardPaymentPage(
//       {required String selectedPlanId,
//       required String selectedPlanTitle,
//       required double selectedPlanPrice});

//   @override
//   _CreditCardPaymentPageState createState() => _CreditCardPaymentPageState();
// }

// class _CreditCardPaymentPageState extends State<CreditCardPaymentPage> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   String cardNumber = '';
//   String expiryDate = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   bool isCvvFocused = false;
//   bool useGlassMorphism = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue[600],
//         ),
//         child: SafeArea(
//           child: Column(
//             children: <Widget>[
//               const SizedBox(
//                 height: 30,
//               ),
//               CreditCardWidget(
//                 glassmorphismConfig:
//                     useGlassMorphism ? Glassmorphism.defaultConfig() : null,
//                 cardNumber: cardNumber,
//                 expiryDate: expiryDate,
//                 cardHolderName: cardHolderName,
//                 cvvCode: cvvCode,
//                 showBackView: isCvvFocused,
//                 obscureCardNumber: true,
//                 obscureCardCvv: true,
//                 isHolderNameVisible: true,
//                 cardBgColor: Colors.red,
//                 backgroundImage: useGlassMorphism ? 'assets/boa.png' : null,
//                 isSwipeGestureEnabled: true,
//                 onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
//                 customCardTypeIcons: <CustomCardTypeIcon>[
//                   CustomCardTypeIcon(
//                     cardType: CardType.mastercard,
//                     cardImage: Image.asset(
//                       'assets/awash.png',
//                       height: 48,
//                       width: 48,
//                     ),
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: <Widget>[
//                       CreditCardForm(
//                         formKey: formKey,
//                         obscureCvv: true,
//                         obscureNumber: true,
//                         cardNumber: cardNumber,
//                         cvvCode: cvvCode,
//                         isHolderNameVisible: true,
//                         isCardNumberVisible: true,
//                         isExpiryDateVisible: true,
//                         cardHolderName: cardHolderName,
//                         expiryDate: expiryDate,
//                         themeColor: Colors.blue,
//                         textColor: Colors.white,
//                         cardNumberDecoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Number',
//                           hintText: 'XXXX XXXX XXXX XXXX',
//                         ),
//                         expiryDateDecoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Expired Date',
//                           hintText: 'XX/XX',
//                         ),
//                         cvvCodeDecoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'CVV',
//                           hintText: 'XXX',
//                         ),
//                         cardHolderDecoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Card Holder',
//                         ),
//                         onCreditCardModelChange: onCreditCardModelChange,
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           backgroundColor: const Color(0xff1b447b),
//                         ),
//                         child: Container(
//                           margin: const EdgeInsets.all(12),
//                           child: const Text(
//                             'Pay Now',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontFamily: 'halter',
//                               fontSize: 14,
//                               package: 'flutter_credit_card',
//                             ),
//                           ),
//                         ),
//                         onPressed: () {
//                           if (formKey.currentState!.validate()) {
//                             // Form is valid, proceed with payment logic
//                             // Implement payment logic here
//                           } else {
//                             // Form is not valid, show an error message or handle accordingly
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void onCreditCardModelChange(CreditCardModel creditCardModel) {
//     setState(() {
//       cardNumber = creditCardModel.cardNumber;
//       expiryDate = creditCardModel.expiryDate;
//       cardHolderName = creditCardModel.cardHolderName;
//       cvvCode = creditCardModel.cvvCode;
//       isCvvFocused = creditCardModel.isCvvFocused;
//     });
//   }
// }
