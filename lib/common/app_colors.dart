import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const primary = Color(0xFF4571A0); // Soft blue-teal
  static const background = Color(0xFFF6F6F3); // Sand/pearl gray
  static const surface = Color(0xFFFFFFFF); // Pure white
  static const textPrimary = Color(0xFF2D3A4A); // Blue-gray
  static const textSecondary = Color(0xFF7B8A99); // Muted blue-gray
  static const textThin = Color(0xFFD8D3CC); // Pastel sand/brown
  static const divider = Color(0xFFE3E8ED); // Light blue-gray
  static const cardBackground = Color(0xFFFFFFFF); // White
  static const inputBackground = Color(0xFFFFFFFF); // White
  static const shadowColor = Color(0x1A000000); // 10% black

  // Dark Theme Colors
  static const darkPrimary = Color(0xFF64B5F6); // Bright blue
  static const darkBackground = Color(0xFF0A0E21); // Deep navy
  static const darkSurface = Color(0xFF1A1F35); // Dark navy surface
  static const darkCardBackground = Color(0xFF252B42); // Card background
  static const darkInputBackground = Color(0xFF2A3149); // Input background
  static const darkTextPrimary = Color(0xFFF5F5F5); // Almost white for primary text
  static const darkTextSecondary = Color(0xFFE0E0E0); // Light gray for secondary text
  static const darkTextThin = Color(0xFFBDBDBD); // Medium gray for thin text
  static const darkDivider = Color(0xFF37474F); // Dark blue-gray
  static const darkShadowColor = Color(0x40000000); // 25% black

  // Status colors (softened)
  static const success = Color(0xFF6CBBA0); // Soft green-teal
  static const failed = Color(0xFFD97B6C); // Soft muted red
  static const darkSuccess = Color(0xFF81C784); // Brighter green for dark mode
  static const darkFailed = Color(0xFFE57373); // Brighter red for dark mode

  // Gradient colors for dark mode
  static const darkGradientStart = Color(0xFF1A1F35);
  static const darkGradientEnd = Color(0xFF252B42);
  
  // Accent colors for dark mode
  static const darkAccent = Color(0xFF42A5F5); // Material blue
  static const darkAccentVariant = Color(0xFF1976D2); // Darker blue

  // Get colors based on theme
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackground : background;
  }

  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? darkSurface : surface;
  }

  static Color getCardBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkCardBackground : cardBackground;
  }

  static Color getInputBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkInputBackground : inputBackground;
  }

  static Color getTextPrimaryColor(bool isDarkMode) {
    return isDarkMode ? darkTextPrimary : textPrimary;
  }

  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : textSecondary;
  }

  static Color getTextThinColor(bool isDarkMode) {
    return isDarkMode ? darkTextThin : textThin;
  }

  static Color getDividerColor(bool isDarkMode) {
    return isDarkMode ? darkDivider : divider;
  }

  static Color getShadowColor(bool isDarkMode) {
    return isDarkMode ? darkShadowColor : shadowColor;
  }

  static Color getPrimaryColor(bool isDarkMode) {
    return isDarkMode ? darkPrimary : primary;
  }

  static Color getSuccessColor(bool isDarkMode) {
    return isDarkMode ? darkSuccess : success;
  }

  static Color getFailedColor(bool isDarkMode) {
    return isDarkMode ? darkFailed : failed;
  }
}
