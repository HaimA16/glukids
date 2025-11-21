import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, backgroundColor: Colors.red);
}

void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, backgroundColor: Colors.green);
}

