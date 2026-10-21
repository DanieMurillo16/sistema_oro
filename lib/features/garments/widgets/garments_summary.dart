import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

/// Resumen del inventario: prendas, unidades, peso total y valor a precio de
/// venta.
class GarmentsSummary extends ConsumerWidget {
  const GarmentsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(garmentsSummaryProvider);
    final textTheme = Theme.of(context).textTheme;
    final stats = [
      ('Prendas', '${summary.garments}'),
      ('Unidades', '${summary.units}'),
      ('Peso', '${GarmentRules.measureInput(summary.grams)} g'),
      ('Valor', formatCop(summary.value)),
    ];
    // Una sola fila: cada dato se encoge si no cabe (nunca se parte).
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        child: Row(
          children: [
            for (final (label, value) in stats)
              Expanded(
                flex: label == 'Valor' ? 3 : 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: textTheme.bodySmall),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value, style: textTheme.titleSmall),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
