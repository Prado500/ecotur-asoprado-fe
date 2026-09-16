import 'package:flutter/material.dart';

class UIHelpers {
  /// Muestra una alerta (SnackBar) estandarizada en toda la aplicación.
  static void showSnackBar(BuildContext context, String message, {bool isError = true}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF006C49),
        behavior: SnackBarBehavior.floating, // Las hace flotantes y modernas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}