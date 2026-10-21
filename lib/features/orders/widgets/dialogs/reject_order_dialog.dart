import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/order_actions_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/reason_field.dart';

/// Rechazar una solicitud pendiente: pide el motivo. La unidad vuelve al
/// catálogo y el pago inicial se anula (Barón devuelve el dinero por fuera).
class RejectOrderDialog extends ConsumerStatefulWidget {
  const RejectOrderDialog({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends ConsumerState<RejectOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(orderActionsProvider.notifier)
        .reject(widget.order.id, _reason.text.trim());
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
        icon: Icons.close_rounded,
        title: 'Rechazar solicitud',
        subtitle: widget.order.codeLabel,
        color: Theme.of(context).colorScheme.error,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'La prenda vuelve al catálogo y el pago inicial se anula. '
              'Recuerda devolverle el dinero al cliente.',
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ReasonField(
              controller: _reason,
              fieldKey: const Key('reject_reason'),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(orderActionsProvider).isLoading,
        confirmLabel: 'Rechazar solicitud',
        confirmIcon: Icons.close_rounded,
        destructive: true,
      ),
    );
  }
}
