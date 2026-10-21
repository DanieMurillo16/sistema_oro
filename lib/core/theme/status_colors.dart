import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_colors.dart';
import 'package:sistema_oro/core/theme/app_dark_colors.dart';

/// Intención de color de un estado (chip, etiqueta, cifra). La vista elige el
/// tono; el color real sale de aquí según el tema, para que se lea en claro y
/// en oscuro.
enum StatusTone { success, warning, error, info, neutral }

Color statusColor(BuildContext context, StatusTone tone) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (tone) {
    StatusTone.success => dark ? AppDarkColors.success : AppColors.success,
    StatusTone.warning => dark ? AppDarkColors.warning : AppColors.warning,
    StatusTone.error => dark ? AppDarkColors.error : AppColors.error,
    StatusTone.info => dark ? AppDarkColors.info : AppColors.info,
    StatusTone.neutral => Theme.of(context).colorScheme.onSurfaceVariant,
  };
}
