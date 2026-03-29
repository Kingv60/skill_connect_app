import 'package:flutter/material.dart';

class AppColors {
  // --- Core Backgrounds ---
  static const Color scaffoldBg = Color(0xFF090A0C); // Main screen background
  static const Color drawerBg = Color(0xFF0F1115);   // Drawer background
  static const Color surface = Color(0xFF171B23);    // Surface/Elevated background
  static const Color cardBg = Color(0xFF1A1D24);     // Cards and Dialogs

  // --- Brand & Accent Colors ---
  static const Color primary = Color(0xFF6366F1);    // Modern Indigo
  static const Color secondary = Color(0xFFA855F7);  // Soft Purple/Accent
  static const Color bluePrime = Colors.blue;        // Standard Blue
  static const Color accentBlue = Color(0xFF00D2FF); // Electric Blue for borders

  // --- Text & Icon Colors ---
  static const Color textPrimary = Color(0xFFFFFFFF);   // High emphasis (White)
  static const Color textSecondary = Color(0xFF94A3B8); // Medium emphasis (Slate)
  static const Color textMuted = Color(0xFF64748B);     // Low emphasis / Disabled

  // --- Status Colors ---
  static const Color error = Color(0xFFEF4444);       // Red for logout/errors
  static const Color success = Color(0xFF22C55E);     // Green for completions
  static const Color warning = Color(0xFFF59E0B);     // Amber for alerts

  // --- Gradients ---
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient blueGradient = LinearGradient(
    colors: [primary, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}