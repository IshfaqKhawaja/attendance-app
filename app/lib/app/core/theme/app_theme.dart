import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/typography.dart' as type;

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.tertiary,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: type.appBarTextStyle,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 300),
        showDuration: Duration(seconds: 2),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.tertiary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: type.appBarTextStyle,
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 300),
        showDuration: Duration(seconds: 2),
      ),
    );
  }
}
