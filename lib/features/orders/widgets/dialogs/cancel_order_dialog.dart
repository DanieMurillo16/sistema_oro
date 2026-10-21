import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/cancel_refund_field.dart';
import 'package:sistema_oro/features/orders/providers/order_actions_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/reason_field.dart';

/// Cancelar un pedido: Barón decide qué pasa con lo ya abonado y queda
/// registrado con su motivo. La unidad vuelve al catálogo.
class CancelOrderDialog extends ConsumerStatefulWidget {
  const CancelOrderDialog({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends ConsumerState<CancelOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _refund = TextEditingController();
  var _decision = CancelDecision.keepAll;

  @override
  void dispose() {
    _reason.dispose();
    _refund.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final partial = _decision == CancelDecision.refundPart;
    ref
        .read(orderActionsProvider.notifier)
        .cancel(
          widget.order.id,
          decision: _decision,
          reason: _reason.text.trim(),
          returnedAmount: partial ? parseCopInput(_refund.text)!.round() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      orderActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final order = widget.order;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.cancel_outlined,
        title: 'Cancelar pedido',
        subtitle: '${order.codeLabel} · pagado ${order.paidLabel}',
        color: Theme.of(context).colorScheme.error,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('¿Qué pasa con lo que el cliente ya pagó?'),
            const SizedBox(height: DesignTokens.spaceSm),
            AppToggle<CancelDecision>(
              options: [
                for (final decision in CancelDecision.values)
                  AppToggleOption(value: decision, label: decision.label),
              ],
              selected: _decision,
              onSelected: (decision) => setState(() => _decision = decision),
            ),
            CancelRefundField(
              controller: _refund,
              visible: _decision == CancelDecision.refundPart,
              paid: order.paid,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ReasonField(
              controller: _reason,
              fieldKey: const Key('cancel_reason'),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(orderActionsProvider).isLoading,
        confirmLabel: 'Cancelar pedido',
        confirmIcon: Icons.cancel_outlined,
        destructive: true,
      ),
    );
  }
}
