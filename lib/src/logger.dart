// ignore_for_file: avoid_print
// ignore_for_file: constant_identifier_names
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dart_log/dart_log.dart';
import 'package:dart_log/src/util/util.dart';

const _MAX_CHARS = 2000;
const _DEFAULT_FILE_LINK_LEVEL = 3;

abstract class ILogger {
  /// method d
  d(dynamic message,
      {String? prefix, int? maxChars, bool isJson = false, int? fileLinkLevel});

  /// method e
  e(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel});

  /// method i
  i(dynamic message,
      {String? prefix, int? maxChars, bool isJson = false, int? fileLinkLevel});

  /// method w
  w(dynamic message,
      {String? prefix, int? maxChars, bool isJson = false, int? fileLinkLevel});

  /// method trace
  trace(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel});

  /// method prod
  prod(Object? message, {bool isJson = false});

  /// method withTag
  ILogger withTag(String prefix);
}

class _LoggerDeveloper {
  /// method log
  void log(String message,
      {DateTime? time,
      String tag = '',
      Object? error,
      StackTrace? stackTrace,
      required int level,
      int? fileLinkLevel}) {
    const verbose = String.fromEnvironment('dart_log_verbose');
    if (verbose == 'true') {
      print('[F] ${_getFilePath(fileLinkLevel)}');
      print('[$tag] $message $error');
    } else {
      dev.log(_getFilePath(fileLinkLevel), name: 'F');
      dev.log(message,
          time: time,
          name: tag,
          error: error,
          stackTrace: stackTrace,
          level: level);
    }
  }

  String _getFilePath([int? fileLinkLevel]) {
    try {
      fileLinkLevel ??= _DEFAULT_FILE_LINK_LEVEL;
      final trace = StackTrace.current.toString();
      final filePath = trace
          .split("\n")[fileLinkLevel]
          .split("(")[1]
          .replaceFirst(')', '')
          .trim();
      return 'file: $filePath';
    } catch (_) {
      return '';
    }
  }
}

/// Logger implementation
class Logger implements ILogger {
  static String prefix = 'DLOG';
  static final List<LogInterceptor> interceptors = <LogInterceptor>[];
  late final String _prefix;

  final _logger = _LoggerDeveloper();

  Logger({String? prefix}) : _prefix = prefix ?? Logger.prefix;

  /// method d
  @override
  d(dynamic message,
      {String? prefix,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel}) {
    try {
      final formattedMessage = _formatMessage(
          isJson ? jsonFormat(message) : message,
          prefix ?? _prefix,
          maxChars,
          isJson);

      intercept(formattedMessage, LogType.debug);

      _logger.log(formattedMessage,
          tag: 'D', level: _Level.debug, fileLinkLevel: fileLinkLevel);
    } catch (_) {}
  }

  /// method e
  @override
  e(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel}) {
    try {
      final formattedMessage = _formatMessage(
          isJson ? jsonFormat(message) : message,
          prefix ?? _prefix,
          maxChars,
          isJson);

      intercept('$formattedMessage' '\n${error ?? ''}' '\n${stackTrace ?? ''}',
          LogType.error);

      _logger.log(formattedMessage,
          tag: 'E',
          error: error,
          stackTrace: stackTrace,
          level: _Level.error,
          fileLinkLevel: fileLinkLevel);
    } catch (_) {}
  }

  /// method i
  @override
  i(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel}) {
    try {
      final formattedMessage = _formatMessage(
          isJson ? jsonFormat(message) : message,
          prefix ?? _prefix,
          maxChars,
          isJson);

      intercept(formattedMessage, LogType.info);

      _logger.log(formattedMessage,
          tag: 'I', level: _Level.info, fileLinkLevel: fileLinkLevel);
    } catch (_) {}
  }

  /// method w
  @override
  w(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel}) {
    try {
      final formattedMessage = _formatMessage(
          isJson ? jsonFormat(message) : message,
          prefix ?? _prefix,
          maxChars,
          isJson);

      intercept(formattedMessage, LogType.warn);

      _logger.log(formattedMessage,
          tag: 'W', level: _Level.warn, fileLinkLevel: fileLinkLevel);
    } catch (_) {}
  }

  /// method trace
  @override
  trace(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false,
      int? fileLinkLevel}) {
    try {
      final formattedMessage = _formatMessage(
          isJson ? jsonFormat(message) : message,
          prefix ?? _prefix,
          maxChars,
          isJson);

      intercept('$formattedMessage\n${stackTrace ?? StackTrace.current}',
          LogType.trace);

      _logger.log(formattedMessage,
          tag: 'TRACE',
          stackTrace: stackTrace ?? StackTrace.current,
          level: _Level.trace,
          fileLinkLevel: fileLinkLevel);
    } catch (_) {}
  }

  /// This will be logged in production environment (Use carefully)
  @override
  prod(dynamic message, {bool isJson = false}) {
    final formattedMessage = isJson ? jsonFormat(message) : message;
    intercept(formattedMessage, LogType.prod);
    print(formattedMessage);
  }

  _formatMessage(dynamic message,
      [String? prefix, int? maxChars, bool isJson = false]) {
    String tagPrefix = prefix ?? _prefix;
    if (tagPrefix.isNotEmpty) {
      if (isJson) {
        tagPrefix = '[$tagPrefix]:\n';
      } else {
        tagPrefix = '[$tagPrefix]:';
      }
    }
    var messageToPrint = '$tagPrefix $message';
    messageToPrint = messageToPrint.substring(
        0, min(messageToPrint.length, maxChars ?? _MAX_CHARS));
    return messageToPrint;
  }

  /// withTag
  @override
  ILogger withTag(String prefix) {
    return Logger(prefix: prefix);
  }

  void intercept(Object? message, LogType logType) {
    for (var interceptor in interceptors) {
      interceptor.log(message, logType);
    }
  }
}

class _Level {
  static const int trace = 500;
  static const int debug = 700;
  static const int info = 800;
  static const int warn = 900;
  static const int error = 1000;
}

// Global instance
final ILogger logger = Logger();
