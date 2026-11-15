/// Base application exception for TTMM.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => message;
}

/// Network or remote backend communication exception.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

/// Local storage read or write failure.
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.cause});
}

/// User authentication or authorization exception.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

/// User input validation exception.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.cause});
}
