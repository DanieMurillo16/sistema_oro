import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';

/// «Compra» o «Separación»: etiqueta de contorno (sin relleno) para no
/// confundirla con el chip de estado, que va teñido.
class OrderTypeChip extends StatelessWidget {
  const OrderTypeChip({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = order.isLayaway ? scheme.secondary : scheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm + DesignTokens.spaceXxs,
          vertical: DesignTokens.spaceXs,
        ),
        child: Text(
          order.typeChipLabel,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ),
    );
  }
}
