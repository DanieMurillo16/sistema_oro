import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/utils/client_labels.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/orders/widgets/order_status_chip.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';

/// Un pedido o separado dentro de la ficha del cliente, con la mini foto de la
/// prenda (sale de la lista única de pedidos, ya cargada).
class ClientOrderTile extends ConsumerWidget {
  const ClientOrderTile({super.key, required this.order, required this.onTap});

  final ClientOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(
      ordersProvider.select(
        (orders) =>
            orders.value?.where((o) => o.id == order.id).firstOrNull?.thumbnail,
      ),
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkThumb(url: thumbnail, size: DesignTokens.miniThumbSize),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(child: _OrderInfo(order: order)),
          ],
        ),
      ),
    );
  }
}

class _OrderInfo extends StatelessWidget {
  const _OrderInfo({required this.order});

  final ClientOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(order.garmentLabel, style: textTheme.titleSmall),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Text(order.totalLabel, style: textTheme.titleSmall),
          ],
        ),
        DotSeparatedText(
          parts: [order.type.label, order.code, order.createdLabel],
        ),
        const SizedBox(height: DesignTokens.spaceXs),
        Wrap(
          spacing: DesignTokens.spaceSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OrderStatusChip(status: order.status),
            if (order.type == OrderType.layaway && order.balance > 0)
              Text('Saldo ${order.balanceLabel}', style: textTheme.bodySmall),
            if (order.dueLabel.isNotEmpty && order.balance > 0)
              Text(order.dueLabel, style: textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
