/// Base class for application errors
abstract class AppError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppError(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Network related errors
class NetworkError extends AppError {
  const NetworkError(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Local storage related errors
class StorageError extends AppError {
  const StorageError(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Data parsing errors
class ParseError extends AppError {
  const ParseError(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}