import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/purchase_actions.dart';

/// Barra fija con «Comprar» y «Separar» lado a lado para el detalle en
/// teléfono: los botones siempre a la vista, sin tener que bajar hasta el final.
class PurchaseBar extends StatelessWidget {
  const PurchaseBar({super.key, required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outline)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33C9A24A),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [PurchaseActions(garment: garment)],
            ),
          ),
        ),
      ),
    );
  }
}
