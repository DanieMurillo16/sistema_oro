import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/order_actions_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Las dos acciones que solo piden confirmación.
enum QuickAction {
  confirm(
    title: 'Confirmar solicitud',
    message: 'Confirmas que recibiste el pago. La prenda queda reservada para el cliente.',
    label: 'Confirmar',
    icon: Icons.check_circle_outline,
  ),
  deliver(
    title: 'Marcar como entregado',
    message: 'La prenda se entregó al cliente. Este paso no se puede deshacer.',
    label: 'Marcar entregado',
    icon: Icons.inventory_2_outlined,
  );

  const QuickAction({
    required this.title,
    required this.message,
    required this.label,
    required this.icon,
  });

  final String title;
  final String message;
  final String label;
  final IconData icon;
}

class QuickActionDialog extends ConsumerWidget {
  const QuickActionDialog({
    super.key,
    required this.order,
    required this.action,
  });

  final Order order;
  final QuickAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenAction(
      ref,
      orderActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final notifier = ref.read(orderActionsProvider.notifier);
    return AppDialog(
      header: DialogHeader(
        icon: action.icon,
        title: action.title,
        subtitle: order.codeLabel,
      ),
      content: Text(action.message),
      actions: DialogActions(
        onConfirm: () => switch (action) {
          QuickAction.confirm => notifier.confirm(order.id),
          QuickAction.deliver => notifier.deliver(order.id),
        },
        isLoading: ref.watch(orderActionsProvider).isLoading,
        confirmLabel: action.label,
        confirmIcon: action.icon,
      ),
    );
  }
}
