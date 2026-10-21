import 'package:flutter/material.dart';

/// Paleta de la app. Los neutros y los estados son fijos para todos los
/// proyectos; **solo `primary` cambia por proyecto**.
abstract final class AppColors {
  // CAMBIAR POR PROYECTO: color de marca (logo, appbar, botones principales).
  static const Color primary = Color(0xFF8A6A2F);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Neutros
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0xFFEEEFF5);

  // Estados (también los usan los avisos/toasts)
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF3561FE);

  static const Color shadow = Color(0x14000000);
}
