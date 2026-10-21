import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/app_colors.dart';
import 'package:sistema_oro/core/theme/app_dark_colors.dart';
import 'package:sistema_oro/core/theme/app_text_theme.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Los colores que cambian entre el tema claro (catálogo) y el oscuro
/// (administración). Todo lo demás del tema es común.
class _Palette {
  const _Palette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.text,
    required this.muted,
    required this.border,
    required this.fieldFill,
    required this.fieldBorder,
    required this.error,
    required this.accent,
    this.primary,
    this.onPrimary,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.textTheme,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color text;
  final Color muted;
  final Color border;
  final Color fieldFill;
  final Color fieldBorder;
  final Color error;

  /// Color de texto, iconos y borde activo: el primary en claro, el dorado
  /// claro en oscuro (el primary no contrasta sobre fondo oscuro).
  final Color accent;

  /// Color de los botones principales; sin él, el dorado de marca.
  final Color? primary;
  final Color? onPrimary;
  final Color appBarBackground;
  final Color appBarForeground;
  final TextTheme textTheme;
}

abstract final class AppTheme {
  // CAMBIAR POR PROYECTO: familia de fuente. Debe estar empaquetada en
  // assets/fonts/ y declarada en pubspec.yaml (pesos 400, 500, 600 y 700).
  // Nunca google_fonts en ejecución: provoca un cambio visual al arrancar.
  static const String fontFamily = 'Inter';

  /// Catálogo público: claro y elegante.
  static ThemeData get light => _build(
    _Palette(
      brightness: Brightness.light,
      background: AppColors.background,
      surface: AppColors.surface,
      surfaceHigh: AppColors.background,
      text: AppColors.text,
      muted: AppColors.muted,
      border: AppColors.border,
      fieldFill: AppColors.surface,
      fieldBorder: AppColors.border,
      error: AppColors.error,
      accent: AppColors.primary,
      appBarBackground: AppColors.primary,
      appBarForeground: AppColors.onPrimary,
      textTheme: AppTextTheme.light,
    ),
  );

  /// Catálogo público («Baron Golden Boss»): negro profundo, carbón cálido y
  /// dorado champán de acento; botones principales dorados con texto negro.
  static ThemeData get catalog => _build(
    _Palette(
      brightness: Brightness.dark,
      background: AppCatalogColors.background,
      surface: AppCatalogColors.surface,
      surfaceHigh: AppCatalogColors.surfaceHigh,
      text: AppCatalogColors.text,
      muted: AppCatalogColors.muted,
      border: AppCatalogColors.border,
      fieldFill: AppCatalogColors.field,
      fieldBorder: AppCatalogColors.fieldBorder,
      error: AppCatalogColors.error,
      accent: AppCatalogColors.goldText,
      primary: AppCatalogColors.gold,
      onPrimary: AppCatalogColors.ink,
      appBarBackground: AppCatalogColors.surface,
      appBarForeground: AppCatalogColors.text,
      textTheme: AppTextTheme.catalog,
    ),
  );

  /// Administración: oscura, con acento dorado.
  static ThemeData get dark => _build(
    _Palette(
      brightness: Brightness.dark,
      background: AppDarkColors.background,
      surface: AppDarkColors.surface,
      surfaceHigh: AppDarkColors.surfaceHigh,
      text: AppDarkColors.text,
      muted: AppDarkColors.muted,
      border: AppDarkColors.border,
      fieldFill: AppDarkColors.surfaceHigh,
      fieldBorder: AppDarkColors.inputBorder,
      error: AppDarkColors.error,
      accent: AppDarkColors.accent,
      appBarBackground: AppDarkColors.surface,
      appBarForeground: AppDarkColors.text,
      textTheme: AppTextTheme.dark,
    ),
  );

  static ThemeData _build(_Palette p) {
    final isDark = p.brightness == Brightness.dark;
    // El primary se declara explícito: fromSeed no puede cambiarlo ni añadir
    // un tinte violeta a las superficies.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: p.brightness,
        ).copyWith(
          primary: p.primary ?? AppColors.primary,
          onPrimary: p.onPrimary ?? AppColors.onPrimary,
          secondary: p.accent,
          tertiary: p.accent,
          primaryContainer: p.accent.withValues(alpha: isDark ? 0.16 : 0.08),
          secondaryContainer: p.accent.withValues(alpha: isDark ? 0.16 : 0.08),
          tertiaryContainer: p.accent.withValues(alpha: isDark ? 0.16 : 0.08),
          onPrimaryContainer: p.accent,
          onSecondaryContainer: p.accent,
          onTertiaryContainer: p.accent,
          surface: p.surface,
          surfaceContainerLowest: p.surface,
          surfaceContainerLow: p.background,
          surfaceContainer: p.surfaceHigh,
          surfaceContainerHigh: p.surfaceHigh,
          surfaceContainerHighest: p.border,
          onSurface: p.text,
          onSurfaceVariant: p.muted,
          outline: p.border,
          outlineVariant: p.border,
          error: p.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      fontFamily: fontFamily,
      textTheme: p.textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: p.border),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.accent),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : null,
        ),
        checkColor: WidgetStatePropertyAll(p.background),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : null,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: p.appBarBackground,
        foregroundColor: p.appBarForeground,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.fieldFill,
        border: _inputBorder(p.fieldBorder),
        enabledBorder: _inputBorder(p.fieldBorder),
        focusedBorder: _inputBorder(p.accent),
        errorBorder: _inputBorder(p.error),
        focusedErrorBorder: _inputBorder(p.error),
        floatingLabelStyle: TextStyle(color: p.accent),
        contentPadding: const EdgeInsets.all(DesignTokens.spaceMd),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        color: p.surface,
        shadowColor: scheme.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          side: isDark ? BorderSide(color: p.border) : BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, DesignTokens.dialogButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, DesignTokens.dialogButtonHeight),
          foregroundColor: p.accent,
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
    borderSide: BorderSide(color: color),
  );

  /// Campos compactos para diálogos: alto mínimo de 48, padding vertical
  /// reducido y sin altura máxima que recorte texto ampliado o errores.
  static ThemeData compactForm(ThemeData theme) => theme.copyWith(
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      isDense: true,
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceSm,
      ),
    ),
  );
}
