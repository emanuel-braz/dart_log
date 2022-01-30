import 'dart:convert';
import 'package:dart_log/src/logger.dart';

String jsonFormat(String json) {
  try {
    if (json.startsWith("{")) {
      Map<String, dynamic> decode = const JsonCodec().decode(json);
      return _convert(decode, 0);
    } else if (json.startsWith("[")) {
      List decode = const JsonCodec().decode(json);
      return _convert(decode, 0);
    } else {
      logger.e("Wrong format: $json");
      return "Wrong format: $json";
    }
  } catch (e) {
    logger.e("${e.toString().trim()}\njson: $json");
    return "${e.toString().trim()}\njson: $json";
  }
}

String _convert(dynamic object, int deep, {bool isObject = false}) {
  var buffer = StringBuffer();
  var nextDeep = deep + 1;
  if (object is Map) {
    var list = object.keys.toList();
    if (!isObject) {
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("{");
    if (list.isEmpty) {
      buffer.write("}");
    } else {
      buffer.write("\n");
      for (int i = 0; i < list.length; i++) {
        buffer.write("${getDeepSpace(nextDeep)}\"${list[i]}\":");
        buffer.write(_convert(object[list[i]], nextDeep, isObject: true));
        if (i < list.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}}");
    }
  } else if (object is List) {
    if (!isObject) {
      buffer.write(getDeepSpace(deep));
    }
    buffer.write("[");
    if (object.isEmpty) {
      buffer.write("]");
    } else {
      buffer.write("\n");
      for (int i = 0; i < object.length; i++) {
        buffer.write(_convert(object[i], nextDeep));
        if (i < object.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}]");
    }
  } else if (object is String) {
    buffer.write("\"$object\"");
  } else if (object is num || object is bool) {
    buffer.write(object);
  } else {
    buffer.write("null");
  }
  return buffer.toString();
}

String getDeepSpace(int deep) {
  var tab = StringBuffer();
  for (int i = 0; i < deep; i++) {
    tab.write("\t");
  }
  return tab.toString();
}
