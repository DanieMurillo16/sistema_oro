import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/shared/widgets/app_pressable.dart';

/// «Separar»: el botón secundario, de contorno, con el porcentaje y lo que se
/// paga hoy en una segunda línea.
class LayawayButton extends StatelessWidget {
  const LayawayButton({
    super.key,
    required this.garment,
    required this.onPressed,
  });

  final CatalogGarment garment;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppPressable(
      lift: 3,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
          foregroundColor: AppCatalogColors.goldText,
          side: const BorderSide(color: AppCatalogColors.gold, width: 1.2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Separar',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                garment.layawayLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: AppCatalogColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
