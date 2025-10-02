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
        surface: AppColors.background,
        surfaceContainerHighest: AppColors.cardBackground,
      ),
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.tertiary,
      cardColor: AppColors.cardBackground,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        titleTextStyle: type.appBarTextStyle,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white70,
        elevation: 8,
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
