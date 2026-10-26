import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// El aviso del separado: separar no es llevarse la prenda (se entrega al
/// pagar el 100 %), el plazo y el recargo (de los ajustes). La casilla
/// obligatoria (`CheckoutLayawayAccept`) va al final del formulario, justo
/// antes del botón.
class CheckoutLayawayNotice extends StatelessWidget {
  const CheckoutLayawayNotice({super.key, required this.settings});

  final CatalogSettings settings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surcharge = settings.monthlySurcharge;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppCatalogColors.gold.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LayawayRule.rule,
              style: textTheme.titleSmall?.copyWith(
                color: AppCatalogColors.goldText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              surcharge > 0
                  ? 'Plazo: 1 mes. Cada mes vencido se suma '
                        '${formatCop(surcharge)} al saldo.'
                  : 'Plazo: 1 mes para completar el pago.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
