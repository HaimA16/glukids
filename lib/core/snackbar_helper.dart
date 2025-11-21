import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 4,
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  showSnackBar(
    context,
    message,
    backgroundColor: Colors.red.shade700,
    icon: Icons.error_outline_rounded,
    duration: const Duration(seconds: 4),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(
    context,
    message,
    backgroundColor: const Color(0xFF4CAF50),
    icon: Icons.check_circle_outline_rounded,
    duration: const Duration(seconds: 2),
  );
}

void showWarningSnackBar(BuildContext context, String message) {
  showSnackBar(
    context,
    message,
    backgroundColor: Colors.orange.shade700,
    icon: Icons.warning_amber_rounded,
    duration: const Duration(seconds: 3),
  );
}

