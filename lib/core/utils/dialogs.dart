// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import '../../config/router/app_router.dart';


class DialogUtils {
  // Show a custom dialog
  static void showDialogBox({
    required String title,
    required String message,
    String? positiveButtonLabel,
    VoidCallback? onPositiveButtonPressed,
    String? negativeButtonLabel,
    VoidCallback? onNegativeButtonPressed,
    bool dismissible = true,
    Color titleColor = Colors.black,
    Color messageColor = Colors.black87,
    Color backgroundColor = Colors.white,
    Color positiveButtonColor = Colors.blueAccent,
    Color negativeButtonColor = Colors.redAccent,
  }) {
    final context = AppRouter.currentContext;

    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: dismissible,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(
              title,
              style: TextStyle(color: titleColor),
            ),
            content: Text(
              message,
              style: TextStyle(color: messageColor),
            ),
            actions: <Widget>[
              if (negativeButtonLabel != null)
                TextButton(
                  child: Text(
                    negativeButtonLabel,
                    style: TextStyle(color: negativeButtonColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onNegativeButtonPressed != null) {
                      onNegativeButtonPressed();
                    }
                  },
                ),
              if (positiveButtonLabel != null)
                TextButton(
                  child: Text(
                    positiveButtonLabel,
                    style: TextStyle(color: positiveButtonColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onPositiveButtonPressed != null) {
                      onPositiveButtonPressed();
                    }
                  },
                ),
            ],
          );
        },
      );
    }
  }

  // Show an error dialog
  static void showErrorDialog(String message, {String title = 'Error'}) {
    showDialogBox(
      title: title,
      message: message,
      positiveButtonLabel: 'OK',
      titleColor: Colors.redAccent,
    );
  }

  // Show an info dialog
  static void showInfoDialog(String message, {String title = 'Info'}) {
    showDialogBox(
      title: title,
      message: message,
      positiveButtonLabel: 'OK',
      titleColor: Colors.blueAccent,
    );
  }

  // Show a success dialog
  static void showSuccessDialog(String message, {String title = 'Success'}) {
    showDialogBox(
      title: title,
      message: message,
      positiveButtonLabel: 'OK',
      titleColor: Colors.greenAccent,
    );
  }

  // Show a warning dialog
  static void showWarningDialog(String message, {String title = 'Warning'}) {
    showDialogBox(
      title: title,
      message: message,
      positiveButtonLabel: 'OK',
      titleColor: Colors.orangeAccent,
    );
  }

  // Show a loading dialog with a CircularProgressIndicator
  static void showLoadingDialog({String message = 'Loading...'}) {
    final context = AppRouter.currentContext;

    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Show a confirmation dialog
  static void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirmed,
    VoidCallback? onCancelled,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
    Color confirmButtonColor = Colors.blueAccent,
    Color cancelButtonColor = Colors.redAccent,
    bool dismissible = true,
  }) {
    showDialogBox(
      title: title,
      message: message,
      positiveButtonLabel: confirmLabel,
      onPositiveButtonPressed: onConfirmed,
      negativeButtonLabel: cancelLabel,
      onNegativeButtonPressed: onCancelled,
      dismissible: dismissible,
      positiveButtonColor: confirmButtonColor,
      negativeButtonColor: cancelButtonColor,
    );
  }

  // Dismiss any active dialog (optional utility)
  static void dismissDialog() {
    final context = AppRouter.currentContext;
    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

