import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_client_row.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_money_strip.dart';
import 'package:sistema_oro/features/orders/widgets/order_status_chip.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/info_grid.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';

/// Todo lo esencial del pedido en una sola tarjeta: la prenda y su estado, el
/// cliente, el dinero en una fila y el desglose (precio, caja, 20 %, plazo).
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detail = order.detail;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkThumb(
                  url: order.detail?.image ?? order.thumbnail,
                  size: DesignTokens.summaryThumbSize,
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.garmentLabel, style: textTheme.titleMedium),
                      DotSeparatedText(
                        parts: [
                          order.type.label,
                          order.reference ?? '',
                          order.quantityLabel,
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceSm),
                      Wrap(
                        spacing: DesignTokens.spaceSm,
                        runSpacing: DesignTokens.spaceXs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OrderStatusChip(status: order.status),
                          if (order.layawayDueLabel.isNotEmpty &&
                              order.isLayaway)
                            Text(
                              order.layawayDueLabel,
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            OrderClientRow(order: order),
            if (order.createdLabel.isNotEmpty)
              Text(
                'Solicitud del ${order.createdLabel}',
                style: textTheme.bodySmall,
              ),
            const SizedBox(height: DesignTokens.spaceMd),
            OrderMoneyStrip(order: order),
            if (detail != null) ...[
              const SizedBox(height: DesignTokens.spaceMd),
              InfoGrid(
                columns: 3,
                items: [
                  InfoItem('Precio', detail.unitPriceLabel),
                  InfoItem('Caja', detail.boxLabel),
                  if (detail.surcharges > 0)
                    InfoItem('Recargos', detail.surchargesLabel),
                  if (order.isLayaway)
                    InfoItem(
                      'Para separar (${detail.percentLabel})',
                      detail.minimumDepositLabel,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
