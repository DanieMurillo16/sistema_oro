import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/layaways/widgets/dialogs/register_payment_dialog.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_action_button.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/cancel_order_dialog.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/quick_action_dialog.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/reject_order_dialog.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/ship_order_dialog.dart';

/// Las acciones que Barón puede hacer ahora mismo sobre el pedido. Cada una
/// abre su diálogo; la regla de qué aplica vive en `OrderRules.actionsFor`.
class OrderActionsBar extends ConsumerWidget {
  const OrderActionsBar({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final actions = OrderRules.actionsFor(
      order,
      (p) => session?.can(p) ?? false,
    );
    if (actions.isEmpty) return const SizedBox.shrink();
    // Flotante y sin fondo propio: los botones se apoyan sobre el contenido sin
    // taparlo con una banda.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Wrap(
          spacing: DesignTokens.spaceSm,
          runSpacing: DesignTokens.spaceSm,
          alignment: WrapAlignment.end,
          children: [
            for (final action in actions)
              OrderActionButton(
                action: action,
                onPressed: () => _open(context, action),
              ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, OrderAction action) {
    showDialog<void>(
      context: context,
      builder: (_) => switch (action) {
        OrderAction.confirm => QuickActionDialog(
          order: order,
          action: QuickAction.confirm,
        ),
        OrderAction.deliver => QuickActionDialog(
          order: order,
          action: QuickAction.deliver,
        ),
        OrderAction.reject => RejectOrderDialog(order: order),
        OrderAction.cancel => CancelOrderDialog(order: order),
        OrderAction.ship => ShipOrderDialog(order: order),
        OrderAction.registerPayment => RegisterPaymentDialog(order: order),
      },
    );
  }
}
