import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/checkout_rules.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/quantity_stepper.dart';

/// «Cantidad» con − y +, hasta lo que haya (máx. 20). A la derecha de la fila
/// de la prenda, la etiqueta va centrada sobre el control (el nombre conserva
/// su ancho); con [inline] (debajo del precio hay sitio) van en una línea.
class CheckoutQuantityRow extends StatelessWidget {
  const CheckoutQuantityRow({
    super.key,
    required this.garment,
    required this.quantity,
    required this.onChanged,
    this.inline = false,
  });

  final CatalogGarment garment;
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      'Cantidad',
      style: Theme.of(context).textTheme.bodySmall,
    );
    final stepper = QuantityStepper(
      value: quantity,
      max: CheckoutRules.maxQuantityFor(garment),
      onChanged: onChanged,
    );
    if (inline) {
      return Wrap(
        spacing: DesignTokens.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [label, stepper],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        label,
        const SizedBox(height: DesignTokens.spaceXs),
        stepper,
      ],
    );
  }
}
