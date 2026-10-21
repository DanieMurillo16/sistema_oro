import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_price.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_reserve_button.dart';
import 'package:sistema_oro/features/catalog/widgets/layaway_info_dialog.dart';

/// Precio y «Reservar» siempre en la misma línea: si el ancho aprieta (tarjeta
/// angosta o letra grande), toda la línea se encoge junta en vez de partirse.
class CatalogCardPriceRow extends StatelessWidget {
  const CatalogCardPriceRow({
    super.key,
    required this.garment,
    required this.canReserve,
  });

  final CatalogGarment garment;

  /// Falta el porcentaje de los ajustes: sin él no se muestra «Reservar».
  final bool canReserve;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatalogPrice(garment: garment, showPrevious: false),
        if (canReserve && !garment.soldOut) ...[
          const SizedBox(width: DesignTokens.spaceSm),
          CatalogReserveButton(
            onPressed: () => showLayawayInfo(context, garment),
          ),
        ],
      ],
    ),
  );
}
