import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Montserrat';

  /// Título grande de pantalla
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: 0.2,
  );

  /// Título editorial grande (layouts tipo split-screen con imagen)
  static const displayTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.3,
    height: 1.15,
  );

  /// Título grande sobre imagen (blanco, para overlays de hero images)
  static const heroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.2,
  );

  /// Párrafo sobre imagen (blanco translúcido)
  static const heroBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    height: 1.5,
  );

  /// Subtítulo/descripción bajo el título
  static const subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  /// Nombre de marca junto al logo — azul
  static const brandWordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 1.2,
  );

  /// Label pequeño encima de un input
  static const inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.label,
    letterSpacing: 0.5,
  );

  /// Texto que digita el usuario como input del label
  static const inputValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// Texto de un botón principal (relleno)
  static const buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// Texto de un botón secundario (outline)
  static const buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Enlaces
  static const link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Texto de error bajo un input
  static const inputError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    color: AppColors.error,
  );
}
