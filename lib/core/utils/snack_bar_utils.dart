// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import '../../config/router/app_router.dart';


class SnackBarUtils {
  static const Duration _defaultDuration = Duration(seconds: 3);

  // Show a custom SnackBar with optional action
  static void showSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Color actionColor = Colors.blueAccent,
  }) {
    final context = AppRouter.currentContext;

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                  textColor: actionColor,
                )
              : null,
        ),
      );
    }
  }

  // Show an error SnackBar
  static void showError(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
    );
  }

  // Show an info SnackBar
  static void showInfo(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
    );
  }

  // Show a success SnackBar
  static void showSuccess(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.greenAccent,
      textColor: Colors.white,
    );
  }

  // Show a loading SnackBar (with indefinite duration)
  static void showLoading(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      duration: const Duration(hours: 1), // long duration for loading
    );
  }

  // Show a warning SnackBar
  static void showWarning(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.orangeAccent,
      textColor: Colors.white,
    );
  }

  // Dismiss any active SnackBar (optional utility)
  static void dismissSnackBar() {
    final context = AppRouter.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }
}

