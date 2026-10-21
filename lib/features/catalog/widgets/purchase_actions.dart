import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/widgets/buy_button.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_dialog.dart';
import 'package:sistema_oro/features/catalog/widgets/layaway_button.dart';

/// Los dos caminos para quedarse con la prenda, UNO AL LADO DEL OTRO: «Comprar»
/// ocupa dos tercios (primario) y «Separar» un tercio. Solo se apilan cuando el
/// ancho no alcanza (teléfono muy angosto o letra muy grande).
class PurchaseActions extends StatelessWidget {
  const PurchaseActions({super.key, required this.garment});

  final CatalogGarment garment;

  void _open(BuildContext context, RequestKind kind) => showDialog<void>(
    context: context,
    builder: (_) => CheckoutDialog(garment: garment, kind: kind),
  );

  @override
  Widget build(BuildContext context) {
    final buy = BuyButton(
      garment: garment,
      onPressed: () => _open(context, RequestKind.purchase),
    );
    if (garment.soldOut || garment.layawayAmount == null) return buy;
    final layaway = LayawayButton(
      garment: garment,
      onPressed: () => _open(context, RequestKind.layaway),
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 260 * scale
          ? Row(
              children: [
                Expanded(flex: 3, child: buy),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(flex: 2, child: layaway),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buy,
                const SizedBox(height: DesignTokens.spaceSm),
                layaway,
              ],
            ),
    );
  }
}
