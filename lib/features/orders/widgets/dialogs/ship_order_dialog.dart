import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/order_actions_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Marcar un pedido como enviado, con el número de guía si lo hay.
class ShipOrderDialog extends ConsumerStatefulWidget {
  const ShipOrderDialog({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<ShipOrderDialog> createState() => _ShipOrderDialogState();
}

class _ShipOrderDialogState extends ConsumerState<ShipOrderDialog> {
  final _tracking = TextEditingController();

  @override
  void dispose() {
    _tracking.dispose();
    super.dispose();
  }

  void _submit() {
    final guide = _tracking.text.trim();
    ref
        .read(orderActionsProvider.notifier)
        .ship(widget.order.id, tracking: guide.isEmpty ? null : guide);
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      orderActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    return AppDialog(
      header: DialogHeader(
        icon: Icons.local_shipping_outlined,
        title: 'Marcar como enviado',
        subtitle: widget.order.codeLabel,
      ),
      content: TextField(
        key: const Key('ship_tracking'),
        controller: _tracking,
        maxLength: 60,
        decoration: const InputDecoration(
          labelText: 'Número de guía (opcional)',
          counterText: '',
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(orderActionsProvider).isLoading,
        confirmLabel: 'Marcar enviado',
        confirmIcon: Icons.local_shipping_outlined,
      ),
    );
  }
}
