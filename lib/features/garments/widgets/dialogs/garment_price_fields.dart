import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_controllers.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_number_fields.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';

/// Precio de venta y precio anterior (oferta) en pareja; el de compra, con
/// permiso, a fila completa.
class GarmentPriceFields extends StatelessWidget {
  const GarmentPriceFields({
    super.key,
    required this.controllers,
    required this.canSeeCost,
  });

  final GarmentFormControllers controllers;
  final bool canSeeCost;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppFormPair(
        minWidth: DesignTokens.formShortPairMinWidth,
        first: MoneyField(
          key: const Key('garment_sale_price'),
          controller: controllers.salePrice,
          label: 'Precio venta',
          validator: (t) => GarmentRules.salePrice(parseCopInput(t)),
        ),
        second: MoneyField(
          key: const Key('garment_previous_price'),
          controller: controllers.previousPrice,
          label: 'Precio anterior',
          validator: (t) => GarmentRules.previousPrice(
            parseCopInput(t),
            parseCopInput(controllers.salePrice.text),
          ),
        ),
      ),
      if (canSeeCost) ...[
        const SizedBox(height: DesignTokens.spaceMd),
        MoneyField(
          key: const Key('garment_purchase_price'),
          controller: controllers.purchasePrice,
          label: 'Precio de compra',
        ),
      ],
    ],
  );
}
