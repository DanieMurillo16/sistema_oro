import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/theme/app_colors.dart';
import 'package:sistema_oro/core/theme/app_dark_colors.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('el tema oscuro usa los colores de la paleta oscura', () {
    final theme = AppTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppDarkColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.secondary, AppDarkColors.accent);
    expect(theme.textTheme.bodyLarge!.color, AppDarkColors.text);
  });

  test('el tema claro conserva la paleta clara', () {
    final theme = AppTheme.light;
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.textTheme.bodyLarge!.color, AppColors.text);
  });

  test('contraste suficiente (WCAG AA) en los pares que se usan', () {
    final pares = {
      'texto sobre fondo oscuro': (
        AppDarkColors.text,
        AppDarkColors.background,
      ),
      'texto sobre superficie oscura': (
        AppDarkColors.text,
        AppDarkColors.surface,
      ),
      'texto apagado sobre superficie oscura': (
        AppDarkColors.muted,
        AppDarkColors.surface,
      ),
      'acento sobre superficie oscura': (
        AppDarkColors.accent,
        AppDarkColors.surface,
      ),
      'error sobre superficie oscura': (
        AppDarkColors.error,
        AppDarkColors.surface,
      ),
      'acento sobre fondo oscuro': (
        AppDarkColors.accent,
        AppDarkColors.background,
      ),
      'texto de botón sobre dorado de marca': (
        AppColors.onPrimary,
        AppColors.primary,
      ),
    };
    pares.forEach((nombre, par) {
      expect(
        _contrast(par.$1, par.$2),
        greaterThanOrEqualTo(4.5),
        reason: nombre,
      );
    });
  });

  test('el borde del campo oscuro se distingue de su relleno (≥ 1,8:1)', () {
    expect(
      _contrast(AppDarkColors.inputBorder, AppDarkColors.surfaceHigh),
      greaterThanOrEqualTo(1.8),
    );
  });

  test(
    'Cancelar y el campo enfocado usan el acento legible, no el primary',
    () {
      final theme = AppTheme.dark;
      final cancel = theme.outlinedButtonTheme.style!.foregroundColor!.resolve(
        {},
      );
      expect(cancel, AppDarkColors.accent);
    },
  );
}
