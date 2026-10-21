import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_price.dart';

/// El precio grande del detalle (con el anterior tachado arriba, pequeño) y, al
/// lado, lo que se ahorra en texto dorado, sin cajas.
class GarmentPriceBlock extends StatelessWidget {
  const GarmentPriceBlock({super.key, required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: DesignTokens.spaceMd,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      CatalogPrice(garment: garment, large: true),
      if (garment.saving > 0)
        Text(
          'Ahorras ${garment.savingLabel}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppCatalogColors.goldText,
            fontWeight: FontWeight.w800,
          ),
        ),
    ],
  );
}
