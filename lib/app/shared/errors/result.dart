import 'package:daymark/app/shared/errors/error_code.dart';
import 'app_error.dart';

/// Result pattern for error handling
sealed class Result<S, E> {
  const Result();

  T when<T>({
    required T Function(S success) success,
    required T Function(E error) failure,
  }) {
    return switch (this) {
      Success<S, E>(:final value) => success(value),
      Failure<S, E>(:final error) => failure(error),
    };
  }
}

typedef FutureResult<S, E> = Future<Result<S, E>>;

final class Success<S, E> extends Result<S, E> {
  const Success(this.value);
  final S value;

  @override
  String toString() {
    return 'Success: $value';
  }
}

final class Failure<S, E> extends Result<S, E> {
  const Failure(this.error);
  final E error;

  static Failure<T, ErrorCode> withAppError<T>(AppError err, {String? message}) {
    return Failure(ErrorCode.fromAppError(err, message: message));
  }

  static Failure<T, ErrorCode> withApiError<T>(String err, {String? message}) {
    return Failure(ErrorCode.fromString(err, message: message));
  }

  @override
  String toString() {
    return 'Failure: $error';
  }
}