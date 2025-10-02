import 'package:flutter/material.dart';

/// App brand colors centralized here for reuse across themes and widgets.
/// Professional university color scheme inspired by Jamia Millia Islamia (JMI).
/// Green represents growth, knowledge, and academic excellence.
class AppColors {
  AppColors._();

  // Primary Brand Colors - University Green (JMI Inspired)
  static const Color primary = Color(0xFF1B5E20);           // Deep Forest Green - Primary
  static const Color primaryLight = Color(0xFF388E3C);      // Lighter Green
  static const Color primaryDark = Color(0xFF0D3D11);       // Darker Forest Green
  
  // Secondary Brand Colors - Complementary Teal/Emerald
  static const Color secondary = Color(0xFF00796B);         // Teal Green
  static const Color secondaryLight = Color(0xFF26A69A);    // Light Teal
  
  // Accent Colors - Gold (Academic Excellence)
  static const Color accent = Color(0xFFFFB300);            // University Gold
  static const Color accentLight = Color(0xFFFFD54F);       // Light Gold
  
  // Background Colors
  static const Color tertiary = Color(0xFFF5F5F7);          // Light Grey Background
  static const Color background = Color(0xFFFFFFFF);        // White
  static const Color cardBackground = Color(0xFFFFFFFF);    // Card White
  
  // Faculty/Department Gradient Colors (Professional Green Palette)
  static const List<Color> gradientColors = [
    Color(0xFF1B5E20),  // Deep Forest Green (Primary)
    Color(0xFF2E7D32),  // Medium Green
    Color(0xFF388E3C),  // Lighter Green
    Color(0xFF00695C),  // Deep Teal
    Color(0xFF00796B),  // Teal Green
    Color(0xFF00897B),  // Light Teal
  ];
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);      // Almost Black
  static const Color textSecondary = Color(0xFF666666);    // Medium Grey
  static const Color textLight = Color(0xFFFFFFFF);        // White
  
  // Semantic colors (extend as needed)
  static const Color success = Color(0xFF2E7D32);          // Green
  static const Color warning = Color(0xFFF9A825);          // Amber
  static const Color error = Color(0xFFC62828);            // Red
  static const Color info = Color(0xFF0288D1);             // Light Blue
}
