import 'package:flutter/material.dart';

/// Responsive utilities for handling different screen sizes
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double safeAreaTop;
  static late double safeAreaBottom;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    safeAreaTop = _mediaQueryData.padding.top;
    safeAreaBottom = _mediaQueryData.padding.bottom;
  }

  /// Check if device is a small phone (width < 360)
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if device is a regular phone (360 <= width < 600)
  static bool isPhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }

  /// Check if device is a tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.85;
    if (width < 400) return size * 0.9;
    if (width >= 600) return size * 1.1;
    return size;
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.8;
    if (width >= 600) return size * 1.2;
    return size;
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.85;
    if (width >= 600) return size * 1.15;
    return size;
  }
}