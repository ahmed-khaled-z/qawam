import 'package:flutter/foundation.dart';

class Logger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';

  static const int _maxLineLength = 80; // Adjust based on your console width

  // Log types
  static void info(String message) {
    _log(message, _blue, 'INFO');
  }

  static void success(String message) {
    _log(message, _green, 'SUCCESS');
  }

  static void warning(String message) {
    _log(message, _yellow, 'WARNING');
  }

  static void error(String message) {
    _log(message, _red, 'ERROR');
  }

  // Private log function
  static void _log(String message, String color, String type) {
    if (kDebugMode) {
      // Split the message into lines that fit within the console width
      List<String> lines = _splitMessageIntoLines(message);

      String border = '*' * (_maxLineLength + 10);
      String formattedMessage = '$color$border\n';

      for (String line in lines) {
        formattedMessage +=
            '*  $line${' ' * (_maxLineLength - line.length)}  *\n';
      }

      formattedMessage += '$border$_reset';
      print(formattedMessage);
    }
  }

  // Helper function to split a message into lines of _maxLineLength
  static List<String> _splitMessageIntoLines(String message) {
    List<String> lines = [];
    for (int i = 0; i < message.length; i += _maxLineLength) {
      lines.add(
        message.substring(
          i,
          i + _maxLineLength > message.length
              ? message.length
              : i + _maxLineLength,
        ),
      );
    }
    return lines;
  }
}
