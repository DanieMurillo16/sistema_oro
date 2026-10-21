import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/shared/widgets/app_pressable.dart';
import 'package:sistema_oro/shared/widgets/app_pulse.dart';

/// «Comprar»: el botón principal, dorado con texto negro, con el precio en una segunda línea.
/// Late despacio para llamar la atención (apagado si la prenda está agotada).
class BuyButton extends StatelessWidget {
  const BuyButton({super.key, required this.garment, required this.onPressed});

  final CatalogGarment garment;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final soldOut = garment.soldOut;
    final button = AppPressable(
      lift: 3,
      child: FilledButton(
        onPressed: soldOut ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
          backgroundColor: AppCatalogColors.gold,
          foregroundColor: AppCatalogColors.ink,
          elevation: 8,
          shadowColor: AppCatalogColors.gold.withValues(alpha: 0.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                soldOut ? 'Agotada' : 'Comprar ahora',
                style: textTheme.labelLarge?.copyWith(
                  color: AppCatalogColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!soldOut)
                Text(
                  garment.priceLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppCatalogColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return soldOut ? button : AppPulse(scale: 1.03, child: button);
  }
}
