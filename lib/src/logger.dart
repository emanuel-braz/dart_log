// ignore_for_file: avoid_print
import 'dart:developer' as dev;
import 'dart:math';
import 'package:dart_log/src/util/util.dart';

// ignore: constant_identifier_names
const _MAX_CHARS = 2000;

abstract class ILogger {
  d(dynamic message, {String? prefix, int? maxChars, bool isJson = false});
  e(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false});
  i(dynamic message, {String? prefix, int? maxChars, bool isJson = false});
  w(dynamic message, {String? prefix, int? maxChars, bool isJson = false});
  trace(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false});
  prod(Object? message, {bool isJson = false});
  ILogger withTag(String prefix);
}

class _LoggerDeveloper {
  void log(String message,
      {DateTime? time,
      String tag = '',
      Object? error,
      StackTrace? stackTrace,
      required int level}) {
    const verbose = String.fromEnvironment('d_log_verbose');
    if (verbose == 'true') {
      print('[F] ${_getFilePath()}');
      print('[$tag] $message $error');
    } else {
      dev.log(_getFilePath(), name: 'F');
      dev.log(message,
          time: time,
          name: tag,
          error: error,
          stackTrace: stackTrace,
          level: level);
    }
  }

  String _getFilePath() {
    try {
      final trace = StackTrace.current.toString();
      final filePath =
          trace.split("\n")[3].split("(")[1].replaceFirst(')', '').trim();
      return 'file: $filePath';
    } catch (_) {
      return '';
    }
  }
}

class Logger implements ILogger {
  static String prefix = 'DLOG';
  late final String _prefix;

  final _logger = _LoggerDeveloper();

  Logger({String? prefix}) : _prefix = prefix ?? Logger.prefix;

  @override
  d(dynamic message, {String? prefix, int? maxChars, bool isJson = false}) {
    try {
      _logger.log(
          _formatMessage(isJson ? jsonFormat(message) : message,
              prefix ?? _prefix, maxChars, isJson),
          tag: 'D',
          level: _Level.debug);
    } catch (_) {}
  }

  @override
  e(dynamic message,
      {dynamic error,
      String? prefix,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false}) {
    try {
      _logger.log(
          _formatMessage(isJson ? jsonFormat(message) : message,
              prefix ?? _prefix, maxChars, isJson),
          tag: 'E',
          error: error,
          stackTrace: stackTrace,
          level: _Level.error);
    } catch (_) {}
  }

  @override
  i(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false}) {
    try {
      _logger.log(
          _formatMessage(isJson ? jsonFormat(message) : message,
              prefix ?? _prefix, maxChars, isJson),
          tag: 'I',
          level: _Level.info);
    } catch (_) {}
  }

  @override
  w(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false}) {
    try {
      _logger.log(
          _formatMessage(isJson ? jsonFormat(message) : message,
              prefix ?? _prefix, maxChars, isJson),
          tag: 'W',
          level: _Level.warn);
    } catch (_) {}
  }

  @override
  trace(dynamic message,
      {String? prefix,
      dynamic error,
      StackTrace? stackTrace,
      int? maxChars,
      bool isJson = false}) {
    try {
      _logger.log(
        _formatMessage(isJson ? jsonFormat(message) : message,
            prefix ?? _prefix, maxChars, isJson),
        tag: 'TRACE',
        stackTrace: stackTrace ?? StackTrace.current,
        level: _Level.trace,
      );
    } catch (_) {}
  }

  /// This will be logged in production environment (Use carefully)
  @override
  prod(dynamic message, {bool isJson = false}) =>
      print(isJson ? jsonFormat(message) : message);

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

  @override
  ILogger withTag(String prefix) {
    return Logger(prefix: prefix);
  }
}

class _Level {
  static const int trace = 500;
  static const int debug = 700;
  static const int info = 800;
  static const int warn = 900;
  static const int error = 1000;
}

final ILogger logger = Logger();
