part of 'payment_bloc.dart';

enum PaymentStatus { initial, loading, loaded, success, error }

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentSuccess extends PaymentState {}

final class PaymentNavigate extends PaymentState {
  final String paymentUrl;
  const PaymentNavigate({required this.paymentUrl});
  @override
  List<Object> get props => [paymentUrl];
}

final class PaymentFailure extends PaymentState {
  final String errorMessage;
  const PaymentFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
