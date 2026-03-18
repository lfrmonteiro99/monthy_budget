/// Base exception for all app-specific errors.
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  const AppException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.originalError, super.stackTrace]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.originalError, super.stackTrace]);
}

class DataException extends AppException {
  const DataException(super.message, [super.originalError, super.stackTrace]);
}

class SubscriptionException extends AppException {
  const SubscriptionException(super.message,
      [super.originalError, super.stackTrace]);
}

class StorageException extends AppException {
  const StorageException(super.message,
      [super.originalError, super.stackTrace]);
}
