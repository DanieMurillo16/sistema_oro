import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Etiqueta flotante sobre la foto: SALE en dorado metálico; NUEVO, ÚLTIMA
/// UNIDAD y AGOTADO en oscuro translúcido (con un fino borde dorado).
class CatalogTag extends StatelessWidget {
  const CatalogTag({super.key, required this.kind});

  final CatalogTagKind kind;

  @override
  Widget build(BuildContext context) {
    final sale = kind == CatalogTagKind.sale;
    final soldOut = kind == CatalogTagKind.soldOut;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: sale ? AppCatalogColors.goldGradient : null,
        color: sale
            ? null
            : (soldOut ? Colors.black : AppCatalogColors.ink).withValues(
                alpha: soldOut ? 0.62 : 0.72,
              ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
        border: sale
            ? null
            : Border.all(color: AppCatalogColors.gold.withValues(alpha: 0.45)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm + 2,
          vertical: 4,
        ),
        child: Text(
          kind.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: sale ? AppCatalogColors.ink : Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

/// Las etiquetas de una prenda apiladas en la esquina de la foto.
class CatalogTags extends StatelessWidget {
  const CatalogTags({super.key, required this.tags});

  final List<CatalogTagKind> tags;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: DesignTokens.spaceXs,
    runSpacing: DesignTokens.spaceXs,
    children: [
      for (final tag in tags.take(2)) CatalogTag(key: ValueKey(tag), kind: tag),
    ],
  );
}
