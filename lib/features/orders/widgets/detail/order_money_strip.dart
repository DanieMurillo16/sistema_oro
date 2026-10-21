import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';

/// La franja del dinero, en una sola fila: total, pagado y saldo (el saldo
/// resaltado en un separado). Todo viene ya calculado por el servidor.
class OrderMoneyStrip extends StatelessWidget {
  const OrderMoneyStrip({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = [
      ('Total', order.totalLabel, false),
      ('Pagado', order.paidLabel, false),
      if (order.isLayaway) ('Saldo', order.balanceLabel, true),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        child: Row(
          children: [
            for (final (label, value, highlight) in stats)
              Expanded(child: _Stat(label, value, highlight)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.highlight);

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: highlight
                ? textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
