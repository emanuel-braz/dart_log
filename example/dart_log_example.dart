import 'dart:developer';

import 'package:dart_log/dart_log.dart';

void main() async {
  Logger.prefix = '';
  Logger.interceptors.add(DefaultLogInterceptor((Object? data) {
    log('** Interceptor ($data) **');
  }));

  Logger.interceptors.add(DefaultLogInterceptor((Object? data) {
    print('\x1B[31mONLY ERROR: $data\x1B[0m');
  }, logTypes: [LogType.error]));

  Logger.interceptors.add(DefaultLogInterceptor((Object? data) {
    print('\x1B[33mWARNING OR INFO: $data\x1B[0m');
  }, logTypes: [LogType.warn, LogType.info]));

  logger.d('"debug message"');
  logger.e('"error message"');
  logger.i('"info message"');
  logger.w('"warn message"');
  logger.trace('"trace message"', stackTrace: StackTrace.current);
  logger.prod('"prod message"');

  await Future.delayed(Duration.zero);
}
