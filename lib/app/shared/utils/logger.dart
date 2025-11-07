import 'package:intl/intl.dart';

/// Simple logger utility for the Daymark app
class AppLogger {
  static const String _appName = 'Daymark';
  
  /// Log levels
  static const Level debug = Level.debug;
  static const Level info = Level.info;
  static const Level warning = Level.warning;
  static const Level error = Level.error;
  
  /// Log a message with specified level
  static void log(Level level, String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final tagText = tag != null ? '[$tag]' : '';
    final errorText = error != null ? ' | Error: $error' : '';
    final stackText = stackTrace != null ? ' | Stack: $stackTrace' : '';
    
    final logMessage = '[$timestamp] $_appName${level.emoji} $tagText $message$errorText$stackText';
    
    // Print to console (in production, this could be sent to a logging service)
    print(logMessage);
  }
  
  /// Debug level logging
  static void d(String message, {String? tag}) {
    log(debug, message, tag: tag);
  }
  
  /// Info level logging
  static void i(String message, {String? tag}) {
    log(info, message, tag: tag);
  }
  
  /// Warning level logging
  static void w(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    log(warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Error level logging
  static void e(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    log(error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
}

/// Log levels with emojis for better visual distinction
enum Level {
  debug('🐛', 'DEBUG'),
  info('ℹ️', 'INFO'),
  warning('⚠️', 'WARNING'),
  error('❌', 'ERROR');
  
  const Level(this.emoji, this.name);
  final String emoji;
  final String name;
}