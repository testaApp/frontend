abstract class AuthEvent {}

class RequestOtpEvent extends AuthEvent {
  final String phoneNumber;
  RequestOtpEvent({required this.phoneNumber});
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;
  final String phoneNumber;
  final String name;
  final Map<String, dynamic>? deviceInfo;

  VerifyOtpEvent({
    this.otp = '',
    this.phoneNumber = '',
    this.name = '',
    this.deviceInfo,
  });
}

class LogoutRequested extends AuthEvent {}

class initLocationRequested extends AuthEvent {}
