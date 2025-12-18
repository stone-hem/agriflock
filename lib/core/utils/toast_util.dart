import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  // Private constructor to prevent instantiation
  ToastUtil._();

  /// Show an error toast
  static void showError(String message) {
    _showToast(message, Colors.red);
  }

  /// Show a success toast
  static void showSuccess(String message) {
    _showToast(message, Colors.green);
  }

  /// Show an info toast
  static void showInfo(String message) {
    _showToast(message, Colors.blue);
  }

  /// Show a warning toast
  static void showWarning(String message) {
    _showToast(message, Colors.orange);
  }

  /// Core method to show toast
  static void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
