import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Las especificaciones (material, peso, medidas, categoría) en dos columnas
/// separadas por líneas finas: sin cajas ni rellenos.
class SpecGrid extends StatelessWidget {
  const SpecGrid({super.key, required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) {
    final measures = garment.measureParts.join('\n');
    final cells = [
      ('Material', garment.goldLabel),
      ('Peso', garment.weightLabel),
      if (measures.isNotEmpty) ('Medidas', measures),
      ('Categoría', garment.typeLabel),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final columns = constraints.maxWidth >= 280 * scale ? 2 : 1;
        final gap = DesignTokens.spaceLg;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          children: [
            for (final (label, value) in cells)
              SizedBox(width: width, child: _Cell(label, value)),
          ],
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppCatalogColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(value, style: textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
