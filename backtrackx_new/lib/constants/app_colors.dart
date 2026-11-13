import 'package:flutter/material.dart';

/// Central color palette for the High-Tech Theme.
class AppColors {
  static Color primary = const Color(0xFF900C3F);      
  static Color secondary = const Color(0xFFFFC300);    
  static Color background = const Color(0xFF0A0E17);   
  static Color surface = const Color(0xFF131B2F);      
  static Color error = const Color(0xFFFF003C);        
  static Color success = const Color(0xFF00FF66);      
  static Color textPrimary = const Color(0xFFF8FAFC);  
  static Color textSecondary = const Color(0xFF94A3B8);

  static void setLightMode() {
    // Luxurious Crimson & Gold Theme
    primary = const Color(0xFF900C3F);      // Rich Burgundy/Crimson
    secondary = const Color(0xFFF5B041);    // Rich Gold
    background = const Color(0xFFFDFEFE);   // Very Light Warm White
    surface = const Color(0xFFFFFFFF);      // White
    error = const Color(0xFFC0392B);        // Red
    success = const Color(0xFF27AE60);      // Green
    textPrimary = const Color(0xFF2C3E50);  // Dark Slate
    textSecondary = const Color(0xFF7F8C8D);// Slate Gray
  }

  static void setDarkMode() {
    // Vibrant Crimson & Gold Dark Theme
    primary = const Color(0xFFC70039);      // Bright Crimson
    secondary = const Color(0xFFFFC300);    // Bright Gold
    background = const Color(0xFF170B11);   // Very Dark Crimson-tinted Gray
    surface = const Color(0xFF24111A);      // Slightly lighter Crimson-tinted surface
    error = const Color(0xFFFF5252);        
    success = const Color(0xFF69F0AE);      
    textPrimary = const Color(0xFFF8FAFC);  
    textSecondary = const Color(0xFFB0BEC5);
  }
}
