abstract class StandingsFailure {}

class NetworkFailure implements StandingsFailure {
  NetworkFailure({this.message = 'Network error'});
  final String message;
}

class AuthenticationFailure implements StandingsFailure {
  AuthenticationFailure({this.message = ''});
  final String message;
}

class ServerFailure implements StandingsFailure {
  ServerFailure({this.message = ''});
  final String message;
}
