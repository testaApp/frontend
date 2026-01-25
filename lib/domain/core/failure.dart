class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() {
    return 'Failure: $message';
  }
}

class ServerErrorFailure extends Failure {
  ServerErrorFailure() : super('Server error occurred');
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

class BadRequestFailure extends Failure {
  BadRequestFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(super.message);
}

class ForbiddenFailure extends Failure {
  ForbiddenFailure(super.message);
}
