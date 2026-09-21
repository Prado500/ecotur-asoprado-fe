import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileLimit = 600;
  static const double desktopLimit = 900;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileLimit;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileLimit &&
          MediaQuery.of(context).size.width < desktopLimit;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopLimit;

  // Metodo genericos para retornar diseño según el dispositivo
  static T getValue<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopLimit) {
      return desktop;
    } else if (width >= mobileLimit) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}