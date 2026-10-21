import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// El único botón flotante de la app. Una sola acción principal por pantalla;
/// si hacen falta dos, la segunda va en el encabezado.
///
/// - [heroTag] es obligatorio y propio: sin etiqueta, dos rutas con flotante
///   chocan durante la transición.
/// - [label] dice qué hace, en una o dos palabras: el flotante tapa lo que hay
///   debajo y no puede ser una frase.
/// - [compactOnPhone] lo encoge en teléfono donde la lista de abajo importa
///   tanto como el botón.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.compactOnPhone = false,
  });

  final String heroTag;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool compactOnPhone;

  @override
  Widget build(BuildContext context) {
    final narrow =
        compactOnPhone &&
        MediaQuery.sizeOf(context).width < DesignTokens.compactLayoutWidth;
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      heroTag: heroTag,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 4,
      extendedPadding: narrow
          ? const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd)
          : null,
      onPressed: onPressed,
      icon: Icon(icon, size: narrow ? DesignTokens.iconSm : 24),
      label: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}
