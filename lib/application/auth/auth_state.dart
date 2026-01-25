enum authStatus { unAuthenticated, signedIn, loggedIn, unknown }

enum RequestStatus {
  initial,
  requesting,
  success,
  failed,
  internalServerError,
  numberNotFound
}

enum VerificationStatus {
  initial,
  requested,
  success,
  networkFailure,
  internalServerError,
  otpError,
  found,
  otpExpired,
}

enum loginStatus { initial, loggedIn, loggedOut }

class AuthState {
  authStatus status;
  String? accessToken;
  RequestStatus requestStatus;
  VerificationStatus? verificationStatus;
  AuthState(
      {this.status = authStatus.unknown,
      this.accessToken,
      this.requestStatus = RequestStatus.initial,
      this.verificationStatus = VerificationStatus.initial});

  AuthState copyWith(
          {authStatus? status,
          String? accessToken,
          RequestStatus? requestStatus,
          VerificationStatus? verificationStatus}) =>
      AuthState(
          status: status ?? this.status,
          accessToken: accessToken ?? this.accessToken,
          requestStatus: requestStatus ?? this.requestStatus,
          verificationStatus: verificationStatus ?? this.verificationStatus);
}
