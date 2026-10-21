import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Un dato de un detalle: etiqueta pequeña arriba y valor abajo.
class InfoItem {
  const InfoItem(
    this.label,
    this.value, {
    this.strong = false,
    this.wide = false,
    this.trailing,
  });

  final String label;
  final String value;

  /// Valor destacado (totales, saldo).
  final bool strong;

  /// Ocupa toda la fila (texto largo: dirección, notas, motivo, medidas).
  final bool wide;

  /// Acción pequeña a la derecha del valor (p. ej. un lápiz para editarlo).
  final Widget? trailing;
}

/// Datos de un detalle en dos columnas cuando hay ancho (una sola si no
/// caben, o con letra muy grande). Reemplaza una pila larga de [InfoRow] para
/// que la tarjeta no crezca tanto hacia abajo.
class InfoGrid extends StatelessWidget {
  const InfoGrid({super.key, required this.items, this.columns = 2});

  final List<InfoItem> items;

  /// Columnas máximas cuando hay ancho (2 por defecto; 4 para un resumen).
  final int columns;

  /// Ancho mínimo de cada columna antes de pasar a una sola.
  static const _minColumn = 130.0;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = DesignTokens.spaceMd;
        // Cuántas columnas caben con el ancho mínimo de cada una (la letra
        // grande cuenta); nunca más de [columns].
        final fit =
            ((constraints.maxWidth + gap) / ((_minColumn * scale) + gap))
                .floor();
        final count = fit.clamp(1, columns);
        final cell = (constraints.maxWidth - gap * (count - 1)) / count;
        return Wrap(
          spacing: gap,
          runSpacing: DesignTokens.spaceSm,
          children: [
            for (final item in items)
              SizedBox(
                width: count > 1 && !item.wide ? cell : constraints.maxWidth,
                child: _InfoCell(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.item});

  final InfoItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = Text(
      item.value,
      style: item.strong ? textTheme.titleSmall : textTheme.bodyMedium,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.label, style: textTheme.bodySmall),
        if (item.trailing == null)
          value
        else
          Row(
            children: [
              Flexible(child: value),
              const SizedBox(width: DesignTokens.spaceXs),
              item.trailing!,
            ],
          ),
      ],
    );
  }
}
