part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class Paysubscription extends PaymentEvent {
  final String planId;
  const Paysubscription({required this.planId});

  @override
  List<Object> get props => [planId];
}

class PaymentSuccessful extends PaymentEvent {}
