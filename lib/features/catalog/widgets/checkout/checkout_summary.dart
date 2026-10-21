import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_price.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';

/// La prenda que se compra o separa, con su precio y, en un separado, cuánto
/// hay que transferir como mínimo (el 20 % que calcula el servidor).
class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({
    super.key,
    required this.garment,
    required this.kind,
    this.trailing,
  });

  final CatalogGarment garment;
  final RequestKind kind;

  /// La cantidad: a la derecha de la fila, centrada con la miniatura y el
  /// nombre; si no cabe ahí, debajo del precio ([inline] = etiqueta y control
  /// en una sola línea).
  final Widget Function(bool inline)? trailing;

  /// Largo máximo del nombre para que la cantidad vaya a su derecha.
  static const _sideNameMax = 30;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        // A la derecha si el nombre conserva espacio; si no (teléfono muy
        // angosto o letra grande), debajo del precio.
        // Y solo con un nombre corto: uno largo en 138 px da 4 líneas.
        final side =
            trailing != null &&
            constraints.maxWidth >= 300 * scale &&
            garment.nameLabel.length <= _sideNameMax;
        return Row(
          crossAxisAlignment: side
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            NetworkThumb(url: garment.thumbnail, size: DesignTokens.thumbSize),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(garment.nameLabel, style: textTheme.titleSmall),
                  CatalogPrice(garment: garment),
                  if (kind == RequestKind.layaway)
                    Text(
                      'Separas con ${garment.layawayLabel} y pagas el resto en abonos, en máximo un mes.',
                      style: textTheme.bodySmall,
                    ),
                  if (trailing != null && !side) ...[
                    const SizedBox(height: DesignTokens.spaceSm),
                    trailing!(true),
                  ],
                ],
              ),
            ),
            if (side) ...[
              const SizedBox(width: DesignTokens.spaceSm),
              trailing!(false),
            ],
          ],
        );
      },
    );
  }
}
