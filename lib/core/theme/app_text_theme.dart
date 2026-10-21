import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/app_colors.dart';
import 'package:sistema_oro/core/theme/app_dark_colors.dart';

/// Escala tipográfica única. La familia del cuerpo la pone `AppTheme.fontFamily`
/// (Inter: números y tablas claros). Solo los títulos (headlineSmall, titleLarge,
/// titleMedium) usan `displayFontFamily` (Plus Jakarta Sans). Ambas van
/// empaquetadas en assets/fonts/. Las vistas leen estos estilos con
/// `Theme.of(context).textTheme`; nunca `TextStyle(fontSize: 14)` suelto.
/// Claro y oscuro comparten tamaños y pesos; solo cambian los colores.
abstract final class AppTextTheme {
  /// Familia de títulos (decisión del proyecto; la base solo define una).
  static const String displayFontFamily = 'PlusJakartaSans';

  static final light = _scale(AppColors.text, AppColors.muted);
  static final dark = _scale(AppDarkColors.text, AppDarkColors.muted);
  static final catalog = _scale(AppCatalogColors.text, AppCatalogColors.muted);

  static TextTheme _scale(Color text, Color muted) => TextTheme(
    // Titular de portada (catálogo): grande, firme y con el interlineado justo.
    headlineLarge: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 40,
      height: 1.08,
      letterSpacing: -1,
      fontWeight: FontWeight.w800,
      color: text,
    ),
    headlineMedium: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 30,
      height: 1.1,
      letterSpacing: -0.6,
      fontWeight: FontWeight.w800,
      color: text,
    ),
    headlineSmall: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: text,
    ),
    titleLarge: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: text,
    ),
    titleMedium: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    bodyLarge: TextStyle(fontSize: 14, color: text),
    bodyMedium: TextStyle(fontSize: 13, color: text),
    bodySmall: TextStyle(fontSize: 12, color: muted),
    labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, color: muted),
  );
}
