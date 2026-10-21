import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card.dart';
import 'package:sistema_oro/shared/widgets/app_slide_in.dart';

/// La cuadrícula del catálogo como sliver (lazy): 2 columnas en teléfono, 3 en
/// tablet y 4 en escritorio, fotos grandes con poco espacio entre ellas. Las filas son de
/// altura natural (el texto grande crece, no se recorta).
class CatalogGrid extends StatelessWidget {
  const CatalogGrid({super.key, required this.items, required this.onOpen});

  final List<CatalogGarment> items;
  final ValueChanged<CatalogGarment> onOpen;

  static int columnsFor(double width) {
    if (width >= DesignTokens.catalogFourColumnsWidth) return 4;
    if (width >= DesignTokens.catalogThreeColumnsWidth) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final columns = columnsFor(constraints.crossAxisExtent);
      final rows = (items.length / columns).ceil();
      return SliverList.separated(
        itemCount: rows,
        separatorBuilder: (_, _) =>
            const SizedBox(height: DesignTokens.spaceLg),
        itemBuilder: (context, row) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < columns; column++) ...[
              if (column > 0)
                SizedBox(
                  width: columns == 2
                      ? DesignTokens.spaceSm
                      : DesignTokens.spaceMd,
                ),
              Expanded(
                child: row * columns + column < items.length
                    ? AppSlideIn(
                        key: ValueKey(items[row * columns + column].id),
                        // Escalonado: entra de un lado (columnas pares por la izquierda, impares por la
                        // derecha) con fundido, una tarjeta tras otra
                        // (también al filtrar por categoría).
                        from: Offset(column.isEven ? -0.05 : 0.05, 0.02),
                        delay: Duration(
                          milliseconds: ((row * columns + column) % 8) * 60,
                        ),
                        duration: const Duration(milliseconds: 500),
                        child: CatalogCard(
                          garment: items[row * columns + column],
                          onTap: () => onOpen(items[row * columns + column]),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
    },
  );
}
