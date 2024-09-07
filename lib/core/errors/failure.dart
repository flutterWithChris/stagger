class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class StorageFailure extends Failure {
  StorageFailure(super.message);
}

class PermissionFailure extends Failure {
  PermissionFailure(super.message);
}

class LocationFailure extends Failure {
  LocationFailure(super.message);
}

class ConnectivityFailure extends Failure {
  ConnectivityFailure(super.message);
}

class UnknownFailure extends Failure {
  UnknownFailure(super.message);
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure(super.message);
}

class SubscriptionFailure extends Failure {
  SubscriptionFailure(super.message);
}
