import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class UIHelpers {
  /// Muestra una alerta (SnackBar) estandarizada en toda la aplicación.
  static void showSnackBar(BuildContext context, String message, {bool isError = true}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating, // Las hace flotantes y modernas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}