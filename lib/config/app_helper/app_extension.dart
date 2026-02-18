import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_formats.dart';

extension LoadingExtension on ChangeNotifier {
  static bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }
}

extension ExceptionExtension on Exception {
  String get message {
    try {
      return (this as dynamic).message;
    } catch (_) {
      return toString();
    }
  }
}

extension StringExtension on String {
  void printMe() {
    if (kDebugMode) {
      print(this);
    }
  }

  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';

  String smallLength({int maxLength = 10}) =>
      length > maxLength ? '${substring(0, maxLength)}...' : this;

  Map<String, dynamic> toMap() => jsonDecode(this);

  String toJson() => jsonEncode(toMap());
}

extension ContextExtensions on BuildContext {
  /// The same of [MediaQuery.of(context).size]
  Size get mediaQuerySize => MediaQuery.sizeOf(this);

  /// The same of [MediaQuery.of(context).size]
  ThemeData get theme => Theme.of(this);

  /// The same of [MediaQuery.of(context).size.height]
  /// Note: updates when you rezise your screen (like on a browser or
  /// desktop window)
  double get height => mediaQuerySize.height;

  /// The same of [MediaQuery.of(context).size.width]
  /// Note: updates when you rezise your screen (like on a browser or
  /// desktop window)
  double get width => mediaQuerySize.width;
}

extension DateTimeExtension on DateTime {
  String get dateTimeFormat => AppFormats.dateTimeFormat.format(this);
  String get dateFormat => AppFormats.dateFormat.format(this);
  String get timeFormat => AppFormats.timeFormat.format(this);
  String get format => AppFormats.format.format(this);
}

extension TimeOfDayExtension on TimeOfDay {
  DateTime get timeOfDayToDate => DateTime(0, 0, 0, hour, minute);
}

