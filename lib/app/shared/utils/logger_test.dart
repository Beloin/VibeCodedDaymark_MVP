import 'package:flutter_test/flutter_test.dart';
import 'logger.dart';

void main() {
  group('AppLogger', () {
    test('should log debug messages', () {
      expect(() => AppLogger.d('Test debug message', tag: 'Test'), returnsNormally);
    });

    test('should log info messages', () {
      expect(() => AppLogger.i('Test info message', tag: 'Test'), returnsNormally);
    });

    test('should log warning messages', () {
      expect(() => AppLogger.w('Test warning message', tag: 'Test'), returnsNormally);
    });

    test('should log error messages', () {
      expect(() => AppLogger.e('Test error message', tag: 'Test'), returnsNormally);
    });

    test('should log error messages with error object', () {
      expect(() => AppLogger.e(
        'Test error message', 
        tag: 'Test', 
        error: Exception('Test exception'),
      ), returnsNormally);
    });

    test('should log error messages with stack trace', () {
      expect(() => AppLogger.e(
        'Test error message', 
        tag: 'Test', 
        stackTrace: StackTrace.current,
      ), returnsNormally);
    });
  });
}