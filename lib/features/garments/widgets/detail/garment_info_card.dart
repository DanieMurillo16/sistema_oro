import 'package:flutter/material.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/adjust_stock_dialog.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/shared/widgets/info_grid.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Los datos de la prenda. El precio de compra solo aparece si el servidor lo
/// mandó (permiso `prendas.ver_costo`).
class GarmentInfoCard extends StatelessWidget {
  const GarmentInfoCard({
    super.key,
    required this.garment,
    required this.canAdjustStock,
  });

  final Garment garment;

  /// Con permiso, un lápiz junto al stock abre el ajuste de unidades.
  final bool canAdjustStock;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: garment.nameLabel,
    child: InfoGrid(
      items: [
        InfoItem('Tipo', garment.typeLabel),
        if (garment.reference != null)
          InfoItem('Referencia', garment.reference!),
        InfoItem('Oro', garment.goldType.label),
        InfoItem('Peso', garment.weightLabel),
        if (garment.measureParts.isNotEmpty)
          InfoItem('Medidas', garment.measureParts.join(' · '), wide: true),
        InfoItem('Precio de venta', garment.priceLabel, strong: true),
        if (garment.onSale)
          InfoItem('Precio anterior', garment.previousPriceLabel),
        if (garment.purchasePrice != null)
          InfoItem('Precio de compra', garment.purchasePriceLabel),
        InfoItem('En el catálogo', garment.active ? 'Visible' : 'Oculta'),
        if (garment.publishedLabel.isNotEmpty)
          InfoItem('Publicada', garment.publishedLabel),
        InfoItem(
          'Stock',
          garment.pendingRequests > 0
              ? '${garment.stockLabel} · ${garment.pendingLabel}'
              : garment.stockLabel,
          strong: true,
          trailing: canAdjustStock
              ? _AdjustStockButton(garment: garment)
              : null,
        ),
        if (garment.description != null)
          InfoItem('Descripción', garment.description!, wide: true),
      ],
    ),
  );
}

/// El lápiz pequeño junto al stock.
class _AdjustStockButton extends StatelessWidget {
  const _AdjustStockButton({required this.garment});

  final Garment garment;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Ajustar stock',
    child: InkResponse(
      radius: 16,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AdjustStockDialog(garment: garment),
      ),
      child: Icon(
        Icons.edit_outlined,
        size: 16,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ),
  );
}
