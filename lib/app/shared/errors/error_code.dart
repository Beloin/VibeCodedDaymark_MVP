import 'app_error.dart';

/// Error codes for consistent error handling
class ErrorCode {
  final String code;
  final String message;

  const ErrorCode(this.code, this.message);

  // Network errors
  static const networkTimeout = ErrorCode('NETWORK_TIMEOUT', 'Request timed out');
  static const networkNoConnection = ErrorCode('NETWORK_NO_CONNECTION', 'No internet connection');
  static const networkServerError = ErrorCode('NETWORK_SERVER_ERROR', 'Server error occurred');
  static const networkBadRequest = ErrorCode('NETWORK_BAD_REQUEST', 'Invalid request');
  static const networkUnauthorized = ErrorCode('NETWORK_UNAUTHORIZED', 'Authentication required');
  static const networkForbidden = ErrorCode('NETWORK_FORBIDDEN', 'Access forbidden');
  static const networkNotFound = ErrorCode('NETWORK_NOT_FOUND', 'Resource not found');

  // Storage errors
  static const storageReadError = ErrorCode('STORAGE_READ_ERROR', 'Failed to read from storage');
  static const storageWriteError = ErrorCode('STORAGE_WRITE_ERROR', 'Failed to write to storage');
  static const storageDeleteError = ErrorCode('STORAGE_DELETE_ERROR', 'Failed to delete from storage');
  static const storageNotFound = ErrorCode('STORAGE_NOT_FOUND', 'Storage item not found');
  static const storageCorrupted = ErrorCode('STORAGE_CORRUPTED', 'Storage data corrupted');

  // Data errors
  static const dataNotFound = ErrorCode('DATA_NOT_FOUND', 'Requested data not found');
  static const dataInvalid = ErrorCode('DATA_INVALID', 'Invalid data format');
  static const dataDuplicate = ErrorCode('DATA_DUPLICATE', 'Duplicate data found');
  static const dataValidation = ErrorCode('DATA_VALIDATION', 'Data validation failed');

  // Business logic errors
  static const habitNotFound = ErrorCode('HABIT_NOT_FOUND', 'Habit not found');
  static const habitEntryNotFound = ErrorCode('HABIT_ENTRY_NOT_FOUND', 'Habit entry not found');
  static const habitAlreadyExists = ErrorCode('HABIT_ALREADY_EXISTS', 'Habit already exists');
  static const habitEntryAlreadyExists = ErrorCode('HABIT_ENTRY_ALREADY_EXISTS', 'Habit entry already exists');

  // Unknown errors
  static const unknown = ErrorCode('UNKNOWN_ERROR', 'An unknown error occurred');

  // Factory methods
  static ErrorCode fromString(String error, {String? message}) {
    return ErrorCode('API_ERROR', message ?? error);
  }

  static ErrorCode fromAppError(AppError error, {String? message}) {
    return switch (error) {
      NetworkError() => ErrorCode('NETWORK_ERROR', message ?? error.message),
      StorageError() => ErrorCode('STORAGE_ERROR', message ?? error.message),
      ParseError() => ErrorCode('PARSE_ERROR', message ?? error.message),
      _ => ErrorCode('UNKNOWN_ERROR', message ?? error.message),
    };
  }

  @override
  String toString() => '[$code] $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorCode && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}