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
  RequestStatus requestStatus;
  VerificationStatus? verificationStatus;
  AuthState(
      {this.status = authStatus.unknown,
      this.requestStatus = RequestStatus.initial,
      this.verificationStatus = VerificationStatus.initial});

  AuthState copyWith(
          {authStatus? status,
          RequestStatus? requestStatus,
          VerificationStatus? verificationStatus}) =>
      AuthState(
          status: status ?? this.status,
          requestStatus: requestStatus ?? this.requestStatus,
          verificationStatus: verificationStatus ?? this.verificationStatus);
}
