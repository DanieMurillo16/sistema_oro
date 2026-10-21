import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_price_block.dart';
import 'package:sistema_oro/features/catalog/widgets/layaway_plan.dart';
import 'package:sistema_oro/features/catalog/widgets/purchase_actions.dart';
import 'package:sistema_oro/features/catalog/widgets/spec_grid.dart';

/// El panel de compra de la prenda: categoría, referencia y disponibilidad;
/// título grande y precio (con lo que se ahorra); la descripción; las
/// especificaciones; el plan de separado; y los botones lado a lado. En
/// teléfono el precio y los botones van en la barra fija de abajo.
class GarmentInfoPanel extends ConsumerWidget {
  const GarmentInfoPanel({
    super.key,
    required this.garment,
    this.showActions = true,
  });

  final CatalogGarment garment;

  /// En teléfono el precio y los botones van en una barra fija abajo.
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final percent = ref.watch(catalogSettingsProvider).value?.layawayPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: DesignTokens.spaceMd,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              garment.typeLabel.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: AppCatalogColors.goldText,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (garment.reference != null)
              Text('Ref: ${garment.reference}', style: textTheme.bodySmall),
            _Availability(garment: garment),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Text(garment.nameLabel, style: textTheme.headlineMedium),
        if (showActions) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          GarmentPriceBlock(garment: garment),
        ],
        if (garment.description != null) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            garment.description!,
            style: textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
        const SizedBox(height: DesignTokens.spaceMd),
        SpecGrid(garment: garment),
        if (percent != null && !garment.soldOut) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          LayawayPlan(garment: garment, percent: percent),
        ],
        if (showActions) ...[
          const SizedBox(height: DesignTokens.spaceLg),
          PurchaseActions(garment: garment),
        ],
      ],
    );
  }
}

class _Availability extends StatelessWidget {
  const _Availability({required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) {
    final soldOut = garment.soldOut;
    final text = soldOut
        ? 'Agotada'
        : garment.lastUnit
        ? 'Última unidad disponible'
        : '${garment.stock} unidades disponibles';
    final color = soldOut ? AppCatalogColors.error : AppCatalogColors.success;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
