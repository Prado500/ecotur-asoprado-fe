import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF13678A);
  static const primaryDark = Color(0xFF0E506B);


  static const accent = Color(0xFFD97D48); //Color naranja en texto y boton
  static const accentDark = Color(0xFFB8440A); // para texto sobre fondo claro
  static const accentTint = Color(0xFFFCE3D4); // fondo tintado en foco


  static const eco = Color(0xFF0D7313);

  // Superficies
  static const surface = Colors.white;
  static const background = Color(0xFFF4F5F4);
  static const fillField = Color(0xFFFAFAF9);
  static const fieldFillTint = Color(0xFFE9F2F5); // tinte azul muy sutil, fondo constante de inputs

  // Bordes
  static const border = Color(0xFFECECEC);
  static const borderStrong = Color(0xFFE2E8F0);

  // Texto
  static const textDark = Color(0xFF1A1A1A);
  static const label = Color(0xFF5A5A5A);
  static const muted = Color(0xFF8A8A8A);
  static const iconInactive = Color(0xFFB0B0B0);

  // Estado
  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF006C49);

  // Decoración (CustomPainter: líneas diagonales, grillas de fondo)
  static const decorativeLine = Color(0xFFBAC9CC);

  //  Escena "hero" del login/bienvenida ---
  /// Degradado dorado → naranja-rojizo profundo, referencia de Colors
  static const heroTop = Color(0xFFF7A93B);
  static const heroBottom = Color(0xFFE8590C);

  static const fieldFillWarm = Color(0xFFFBF3EC);

  static const heroGradient = LinearGradient(
    colors: [Colors.white, heroTop, heroBottom],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Degradados reutilizables
  static const accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}