import 'package:flutter/material.dart';

class AppColors {
  // Background Mesh Gradient Colors
  static const Color bgGradientTop = Color(0xFFF0F9F4);
  static const Color bgGradientBottom = Color(0xFFB9E5D1);

  // The Dark Teal/Green for Buttons and Mic (from your color code)
  static const Color primary = Color(0xFF173B45);

  // Text Colors
  static const Color textPrimary = Color(0xFF173B45);
  static const Color textSecondary = Color(0xFF667085);

  // UI Component Colors (The missing members)
  static const Color inputFill = Colors.white;              // For text field backgrounds
  static const Color borderDefault = Color(0xFFD0D5DD);     // Light grey for unselected borders
  static const Color borderSelected = Color(0xFF173B45);    // Dark green for active borders/selections

  // Card and Chip Colors
  static const Color cardGrey = Color(0xFFD9D9D9);          // For the "Today's weather" chips
  static const Color chipSelectedBg = Color(0xFFF0FDF9);    // Soft green tint for selected chips
}