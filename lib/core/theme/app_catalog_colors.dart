import 'package:flutter/material.dart';

/// Paleta del catálogo público de «Baron Golden Boss» (identidad de su
/// Instagram @barongoldenboss): negro profundo, marrones cálidos muy oscuros y
/// el dorado champán como ÚNICO color de acento. Las fotos de las joyas son lo
/// que tiene color. El negro de fondo es el mismo del logo (`logoBlack`) para
/// que la imagen no se vea como un cuadrado sobre la página.
abstract final class AppCatalogColors {
  /// Negro del logo y del fondo de la página.
  static const Color background = Color(0xFF010101);

  /// Carbón cálido: tarjetas, cabecera, diálogos y barra de compra.
  static const Color surface = Color(0xFF12100D);

  /// Un paso más claro que `surface` (campos, relleno de fotos vacías).
  static const Color surfaceHigh = Color(0xFF1C1914);

  /// Marfil claro para texto (≈ 17:1 sobre el fondo).
  static const Color text = Color(0xFFF4EFE6);

  /// Texto secundario (≈ 7:1 sobre el fondo).
  static const Color muted = Color(0xFFA59C8C);

  /// Borde fino y separadores (marrón muy oscuro).
  static const Color border = Color(0xFF2B2620);

  /// Relleno de los campos de texto.
  static const Color field = Color(0xFF1A1713);

  /// Borde de los campos de formulario (≈ 3:1 con el relleno).
  static const Color fieldBorder = Color(0xFF7A7160);

  /// Rojo de error legible sobre fondo oscuro.
  static const Color error = Color(0xFFEF6C6C);

  /// Verde de «disponible» legible sobre fondo oscuro.
  static const Color success = Color(0xFF6FCF7F);

  /// Texto y iconos SOBRE dorado (botón principal): casi negro.
  static const Color ink = Color(0xFF0A0A0A);

  /// Texto y relleno claro sobre fondos oscuros.
  static const Color onInk = Color(0xFFFFFFFF);

  /// Dorado champán: líneas, bordes y rellenos pequeños.
  static const Color gold = Color(0xFFC9A24A);
  static const Color goldLight = Color(0xFFE6CB82);
  static const Color goldDeep = Color(0xFFA8812F);

  /// Dorado para TEXTO sobre fondo oscuro (≈ 11:1 con el fondo).
  static const Color goldText = goldLight;

  /// Velo oscuro para leer texto sobre una foto.
  static const Color scrim = Color(0xCC000000);

  /// Degradado metálico de las insignias y del botón principal.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldDeep],
  );

  /// Resplandor dorado sutil (en oscuro no hay sombra negra que se vea).
  static List<BoxShadow> cardShadow({bool lifted = false}) => [
    BoxShadow(
      color: gold.withValues(alpha: lifted ? 0.22 : 0),
      blurRadius: 28,
      offset: const Offset(0, 8),
    ),
  ];
}
