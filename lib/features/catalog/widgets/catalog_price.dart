import 'package:flutter/material.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// El precio de la prenda; si está en oferta, el anterior tachado. En una
/// tarjeta angosta va debajo; en el detalle ([large]) al lado.
class CatalogPrice extends StatelessWidget {
  const CatalogPrice({
    super.key,
    required this.garment,
    this.large = false,
    this.showPrevious = true,
  });

  final CatalogGarment garment;
  final bool large;

  /// En la tarjeta del listado se omite el precio anterior (más limpio).
  final bool showPrevious;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final price = Text(
      garment.priceLabel,
      style: large
          ? textTheme.headlineSmall
          : textTheme.titleMedium?.copyWith(fontSize: 15),
    );
    if (!showPrevious || !garment.onSale || garment.previousPrice == null) {
      return price;
    }
    final previous = Text(
      garment.previousPriceLabel,
      // Pequeño y tenue: informa sin competir con el precio actual.
      style: textTheme.labelSmall?.copyWith(
        fontSize: large ? 12 : 10,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.lineThrough,
        decorationColor: textTheme.labelSmall?.color?.withValues(alpha: 0.5),
        color: textTheme.labelSmall?.color?.withValues(alpha: 0.65),
      ),
    );
    return large
        // Detalle: el precio anterior, pequeño y arriba; el actual, grande.
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [previous, price],
          )
        // Tarjeta: el anterior, diminuto y arriba, pegado al precio actual.
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                style: const TextStyle(height: 1),
                child: previous,
              ),
              price,
            ],
          );
  }
}
