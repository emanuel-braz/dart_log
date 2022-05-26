import 'enums/types.dart';

abstract class LogInterceptor {
  void log(Object? data, LogType logType);
}

class DefaultLogInterceptor implements LogInterceptor {
  final List<LogType> logTypes;
  final void Function(Object? data) onLog;

  DefaultLogInterceptor(this.onLog, {this.logTypes = const <LogType>[]});

  @override
  void log(Object? data, LogType logType) {
    if (logTypes.isEmpty || logTypes.isNotEmpty && logTypes.contains(logType)) {
      final message = '${logType.name}: ${data.toString().trimLeft()}';
      onLog(message);
    }
  }
}
