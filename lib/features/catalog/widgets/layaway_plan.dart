import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Cómo funciona separar esta prenda: cuánto se paga hoy y cuánto queda. Los
/// montos salen del 20 % que calcula el servidor. Sin caja: una línea dorada
/// a la izquierda y las cifras.
class LayawayPlan extends StatelessWidget {
  const LayawayPlan({super.key, required this.garment, required this.percent});

  final CatalogGarment garment;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppCatalogColors.gold, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan separe · ${percent.round()} %',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _Figure(
                    'Pagas hoy',
                    formatCop(garment.depositFor(percent)),
                  ),
                ),
                Expanded(
                  child: _Figure(
                    'Saldo para abonar',
                    formatCop(garment.balanceFor(percent)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'La apartamos a tu nombre y sale del catálogo mientras completas '
              'tus abonos.',
              style: textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: textTheme.titleLarge),
        ),
      ],
    );
  }
}
