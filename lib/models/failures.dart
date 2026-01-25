abstract class GeneralFailure {}

class NetworkFailure implements GeneralFailure {
  NetworkFailure({this.message = ''});
  final String message;
}

class AuthenticationFailure implements GeneralFailure {
  AuthenticationFailure({this.message = ''});
  final String message;
}

class ServerFailure implements GeneralFailure {
  ServerFailure({this.message = ''});
  final String message;
}
