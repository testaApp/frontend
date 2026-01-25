import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// To launch URLs
import '../../bloc/payment_bloc/payment_bloc.dart'; // PaymentBloc and events
import '../../localization/demo_localization.dart';
import '../constants/text_utils.dart';
import 'telebirr.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // For showing success dialogs
import '../../components/routenames.dart'; // Import route names

class PaymentChoicePage extends StatelessWidget {
  final String id;
  final String title;
  final double price;

  const PaymentChoicePage({
    super.key,
    required this.id,
    required this.title,
    required this.price,
  });

  // Reusable method to create payment buttons
  Widget buildPaymentButton({
    required BuildContext context,
    required String assetPath,
    required String labelText,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, height: 24),
          const SizedBox(width: 8),
          Text(
            labelText,
            style: TextUtils.setTextStyle(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ));
        } else if (state is PaymentNavigate) {
          // Navigate to the route that opens the payment URL
          context.pushNamed(
            RouteNames.paymentRouteName,
            queryParameters: {
              'paymentUrl': state.paymentUrl
            }, // Pass payment URL to the new route
          );
        } else if (state is PaymentNavigate) {
          // Show a loading indicator while navigating to the payment route
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          // Navigate to the route that opens the payment URL
          Future.delayed(const Duration(milliseconds: 500), () {
            context.pushNamed(
              RouteNames.paymentRouteName,
              queryParameters: {'paymentUrl': state.paymentUrl},
            );
          });
        } else if (state is PaymentSuccess) {
          AwesomeDialog(
            dialogBorderRadius: BorderRadius.circular(15),
            dismissOnTouchOutside: false,
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: DemoLocalizations.payment_successful,
            btnOkOnPress: () {
              context.goNamed(RouteNames.entrypage);
            },
          ).show();

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You have successfully subscribed to the plan'),
            backgroundColor: Colors.green,
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            DemoLocalizations.selectPaymentMethod,
            style: TextUtils.setTextStyle(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Telebirr Payment Button
              buildPaymentButton(
                context: context,
                assetPath: 'assets/TeleBirr-Logo.png',
                labelText: DemoLocalizations.telebirr,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelebirrPaymentPage(
                        selectedPlanId: id,
                        selectedPlanTitle: title,
                        selectedPlanPrice: price,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Chapa Payment Button
              buildPaymentButton(
                context: context,
                assetPath: 'assets/chapa.png',
                labelText: DemoLocalizations.chapaPayments,
                onPressed: () {
                  // Dispatch Paysubscription event with planId
                  context.read<PaymentBloc>().add(
                        Paysubscription(
                          planId:
                              id, // Send the selected plan id to the backend
                        ),
                      );
                },
              ),
              const SizedBox(height: 20),

              // Credit/Debit Card Payment Button
              ElevatedButton(
                onPressed: () {
                  context.read<PaymentBloc>().add(
                        Paysubscription(
                          planId:
                              id, // Send the selected plan id to the backend
                        ),
                      );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.credit_card),
                    const SizedBox(width: 8),
                    Text(
                      DemoLocalizations.creditDebitCard,
                      style: TextUtils.setTextStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
