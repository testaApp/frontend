// // ignore: prefer_relative_imports
// import 'package:blogapp/bloc/payment_bloc/payment_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:go_router/go_router.dart';

// class PaymentPageWebView extends StatefulWidget {
//   final String paymentUrl;
//   const PaymentPageWebView({Key? key, required this.paymentUrl})
//       : super(key: key);

//   @override
//   State<PaymentPageWebView> createState() => _PaymentPageWebViewState();
// }

// class _PaymentPageWebViewState extends State<PaymentPageWebView> {
//   late InAppWebViewController webViewController;
//   bool isLoading = true;

//   Future<void> delay() async {
//     await Future.delayed(const Duration(seconds: 2));
//   }

//   void _showSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: <Widget>[
//             InAppWebView(
//               initialUrlRequest:
//                   URLRequest(url: WebUri.uri(Uri.parse(widget.paymentUrl))),
//               onWebViewCreated: (controller) {
//                 setState(() {
//                   webViewController = controller;
//                 });
//                 controller.addJavaScriptHandler(
//                     handlerName: "buttonState",
//                     callback: (args) async {
//                       webViewController = controller;

//                       if (args[2][1] == 'CancelbuttonClicked') {
//                         _showSnackbar(context, 'Payment Cancelled');
//                         context.pop();
//                       }

//                       return args.reduce((curr, next) => curr + next);
//                     });
//               },
//               onLoadStart: (controller, url) {
//                 setState(() {
//                   isLoading = true;
//                 });
//               },
//               onLoadStop: (controller, url) {
//                 setState(() {
//                   isLoading = false;
//                 });
//               },
//               onUpdateVisitedHistory: (InAppWebViewController controller,
//                   WebUri? uri, androidIsReload) async {
//                 if (uri?.toString() == 'https://chapa.co') {
//                   _showSnackbar(context, 'Payment Successful');
//                   context.read<PaymentBloc>().add(PaymentSuccessful());
//                   context.pop();
//                 } else if (uri
//                     ?.toString()
//                     .contains('checkout/test-payment-receipt/')) {
//                   _showSnackbar(context, 'Payment Successful');

//                   await delay();
//                   if (mounted) {
//                     context.read<PaymentBloc>().add(PaymentSuccessful());
//                     context.pop();
//                   }
//                 }
//                 controller.addJavaScriptHandler(
//                     handlerName: "handlerFooWithArgs",
//                     callback: (args) async {
//                       webViewController = controller;

//                       if (args[2][1] == 'failed') {
//                         await delay();
//                         if (mounted) {
//                           context.pop();
//                         }
//                       }
//                       if (args[2][1] == 'success') {
//                         if (mounted) {
//                           _showSnackbar(context, 'Payment Successful');
//                         }
//                         await delay();
//                         if (mounted) {
//                           context.read<PaymentBloc>().add(PaymentSuccessful());
//                           context.pop();
//                         }
//                       }
//                       return args.reduce((curr, next) => curr + next);
//                     });

//                 controller.addJavaScriptHandler(
//                     handlerName: "buttonState",
//                     callback: (args) async {
//                       webViewController = controller;

//                       if (args[2][1] == 'CancelbuttonClicked') {
//                         _showSnackbar(context, 'Payment Cancelled');
//                         context.pop();
//                       }

//                       return args.reduce((curr, next) => curr + next);
//                     });
//               },
//             ),
//             if (isLoading)
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 20),
//                     Text('Loading payment page...'),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
