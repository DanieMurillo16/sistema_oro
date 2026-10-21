import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_colors.dart';

/// Paleta oscura de la administración (referencia: «Cuentas Claras», ver
/// docs/DISENO_REFERENCIAS.md). Casi negro azulado, superficies apenas más
/// claras y un dorado champán para texto, iconos y bordes activos; el relleno
/// de los botones sigue siendo `AppColors.primary`. Los colores de estado
/// (éxito, aviso, error, info) son los de `AppColors`.
abstract final class AppDarkColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceHigh = Color(0xFF1E252E);
  static const Color text = Color(0xFFF3EFE6);
  static const Color muted = Color(0xFF9BA3AF);
  static const Color border = Color(0xFF2A313B);

  /// Borde de los campos de formulario: más visible que `border` (≈ 2:1 con
  /// el relleno `surfaceHigh`).
  static const Color inputBorder = Color(0xFF47515F);

  /// Rojo de error legible sobre `surface` (≈ 4,9:1); el de `AppColors` queda
  /// en 4,1:1 sobre fondo oscuro.
  static const Color error = Color(0xFFEF5350);

  /// Estados legibles sobre fondo oscuro (para texto, iconos y chips; los de
  /// `AppColors` contrastan poco ahí). `error` está arriba.
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF82A0FF);

  /// Dorado claro para texto y bordes activos sobre fondo oscuro (≈ 8:1 con
  /// `surface`). El dorado de marca (`AppColors.primary`) queda para rellenos.
  static const Color accent = Color(0xFFD2AE6D);

  /// Extremos del degradado del icono de marca (splash).
  static const Color goldLight = Color(0xFFE8D2A0);
  static const Color goldDeep = AppColors.primary;
}
