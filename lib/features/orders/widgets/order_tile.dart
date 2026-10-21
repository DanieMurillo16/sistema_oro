import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/widgets/order_status_chip.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';

/// Una fila de la lista de pedidos o de separados: quién, qué prenda, cuánto
/// y en qué estado. Un separado muestra además su saldo y su plazo.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkThumb(url: order.thumbnail),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWithAmount(
                    title: order.clientLabel,
                    amount: order.totalLabel,
                  ),
                  DotSeparatedText(
                    parts: [
                      order.garmentLabel,
                      order.code,
                      order.quantityLabel,
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  _TileStatus(order: order),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TileStatus extends StatelessWidget {
  const _TileStatus({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final overdue = OrderRules.isOverdue(order);
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: DesignTokens.spaceSm,
      runSpacing: DesignTokens.spaceXs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OrderStatusChip(
          status: order.status,
          prefix: order.isLayaway ? order.type.label : null,
        ),
        if (order.isLayaway && order.status == OrderStatus.active) ...[
          Text('Saldo ${order.balanceLabel}', style: textTheme.bodySmall),
          Text(
            order.layawayDueLabel,
            style: textTheme.bodySmall?.copyWith(
              color: overdue ? statusColor(context, StatusTone.error) : null,
            ),
          ),
        ],
      ],
    );
  }
}
