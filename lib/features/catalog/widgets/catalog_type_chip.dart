import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';

/// Un tipo de prenda en la franja de categorías: píldora dorada con texto
/// negro si está elegido, solo contorno tenue si no. Alto de toque de 44.
class CatalogTypeChip extends StatelessWidget {
  const CatalogTypeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      side: BorderSide(
        color: selected ? AppCatalogColors.gold : AppCatalogColors.border,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: motionDuration(context, DesignTokens.animationFast),
        constraints: const BoxConstraints(
          minHeight: DesignTokens.chipTouchHeight,
        ),
        decoration: ShapeDecoration(
          color: selected ? AppCatalogColors.gold : Colors.transparent,
          shape: shape,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceSm,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  formatDisplayText(label),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? AppCatalogColors.ink : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
