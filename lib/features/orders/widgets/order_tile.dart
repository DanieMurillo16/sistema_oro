import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/widgets/order_status_chip.dart';
import 'package:sistema_oro/features/orders/widgets/order_type_chip.dart';
import 'package:sistema_oro/features/orders/widgets/receipt_thumb.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';

/// Una fila de la lista de pedidos o de separados: quién, qué prenda, cuánto
/// y en qué estado. Un separado muestra además su saldo y su plazo.
class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
    this.showTypeAndReceipt = false,
  });

  final Order order;
  final VoidCallback onTap;

  /// En «Pedidos» (compras y separados mezclados): chip Compra/Separación,
  /// banco y miniatura del comprobante del pago inicial.
  final bool showTypeAndReceipt;

  @override
  Widget build(BuildContext context) {
    final detailed = showTypeAndReceipt;
    final receipt = detailed ? order.receipt : null;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DotSeparatedText(
          parts: [order.garmentLabel, order.code, order.quantityLabel],
        ),
        const SizedBox(height: DesignTokens.spaceXs),
        _TileChips(order: order, detailed: detailed),
      ],
    );
    return Card(
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
                    // La miniatura va junto a las dos líneas de abajo (suman su
                    // misma altura): no añade alto ni les quita ancho al título.
                    if (receipt == null)
                      info
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: info),
                          const SizedBox(width: DesignTokens.spaceSm),
                          ReceiptThumb(file: receipt),
                        ],
                      ),
                    if (detailed) _TileExtras(order: order),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Los chips: en «Pedidos», tipo (contorno) + estado (teñido); en Separados,
/// el estado con su prefijo y, si está activo, saldo y plazo.
class _TileChips extends StatelessWidget {
  const _TileChips({required this.order, required this.detailed});

  final Order order;
  final bool detailed;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: DesignTokens.spaceSm,
    runSpacing: DesignTokens.spaceXs,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      if (detailed) OrderTypeChip(order: order),
      OrderStatusChip(
        status: order.status,
        prefix: order.isLayaway && !detailed ? order.type.label : null,
      ),
      if (!detailed) ..._layawayParts(context, order, grouped: false),
    ],
  );
}

/// Banco de origen y, en un separado activo, saldo y plazo: a todo el ancho,
/// debajo (así no compiten con la miniatura).
class _TileExtras extends StatelessWidget {
  const _TileExtras({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final bank = order.bank;
    final parts = _layawayParts(context, order, grouped: true);
    if (bank == null && parts.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
      child: Wrap(
        spacing: DesignTokens.spaceSm,
        runSpacing: DesignTokens.spaceXs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (bank != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  size: DesignTokens.iconSm,
                ),
                const SizedBox(width: DesignTokens.spaceXs),
                Text(order.bankLabel, style: textTheme.bodySmall),
              ],
            ),
          ...parts,
        ],
      ),
    );
  }
}

/// Saldo y plazo de un separado activo. [grouped]: juntos en una pieza (si no
/// caben en la línea, bajan los dos); si no, cada uno fluye por su cuenta.
List<Widget> _layawayParts(
  BuildContext context,
  Order order, {
  required bool grouped,
}) {
  if (!order.isLayaway || order.status != OrderStatus.active) return const [];
  final textTheme = Theme.of(context).textTheme;
  final overdue = OrderRules.isOverdue(order);
  final balance = Text(
    'Saldo ${order.balanceLabel}',
    style: textTheme.bodySmall,
  );
  final due = Text(
    order.layawayDueLabel,
    style: textTheme.bodySmall?.copyWith(
      color: overdue ? statusColor(context, StatusTone.error) : null,
    ),
  );
  if (!grouped) return [balance, due];
  return [
    Wrap(spacing: DesignTokens.spaceSm, children: [balance, due]),
  ];
}
