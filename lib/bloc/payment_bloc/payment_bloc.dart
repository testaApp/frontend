import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<PaymentEvent>((event, emit) {});
    on<PaymentSuccessful>((event, emit) {
      emit(PaymentSuccess());
    });
    on<Paysubscription>((event, emit) async {
      final baseUrl = BaseUrl().url;
      String accessToken = await getAccessToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'accesstoken': accessToken
      };

      // Now send the `planId` to the backend
      final msg = jsonEncode({'planId': event.planId});

      emit(PaymentLoading());
      try {
        final url = '$baseUrl/api/user/payment/order';
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: msg,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonResponse = jsonDecode(response.body);
          emit(PaymentNavigate(paymentUrl: jsonResponse['paymentUrl']));
        } else {
          emit(PaymentFailure(
              errorMessage:
                  'Error: ${response.statusCode} ${response.reasonPhrase}'));
        }
      } catch (e) {
        emit(PaymentFailure(errorMessage: e.toString()));
      }
    });
  }
}
