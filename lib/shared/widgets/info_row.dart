import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Una línea «etiqueta … valor» de un detalle. El valor crece en varias líneas
/// si hace falta; no se recorta.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.block = false,
  });

  final String label;
  final String value;

  /// Valor destacado (totales, saldo).
  final bool strong;

  /// Texto largo (descripción, notas, motivo, dirección): va debajo de la
  /// etiqueta, alineado a la izquierda, en vez de justificado a la derecha.
  final bool block;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (block) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall),
            Text(value, style: textTheme.bodyMedium),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: textTheme.bodySmall)),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: strong ? textTheme.titleSmall : textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
