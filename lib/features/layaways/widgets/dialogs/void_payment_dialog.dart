import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/layaways/providers/payment_actions_provider.dart';
import 'package:sistema_oro/features/orders/models/order_payment.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/reason_field.dart';

/// Anular un pago (nunca se borra): pide el motivo y avisa que el saldo sube.
class VoidPaymentDialog extends ConsumerStatefulWidget {
  const VoidPaymentDialog({
    super.key,
    required this.payment,
    this.reopens = false,
  });

  final OrderPayment payment;

  /// El separado estaba pagado: al anular vuelve a «Activo» (no se entrega).
  final bool reopens;

  @override
  ConsumerState<VoidPaymentDialog> createState() => _VoidPaymentDialogState();
}

class _VoidPaymentDialogState extends ConsumerState<VoidPaymentDialog> {
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
        .read(paymentActionsProvider.notifier)
        .voidPayment(widget.payment.id, _reason.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      paymentActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final payment = widget.payment;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.block,
        title: 'Anular pago',
        subtitle: payment.amountLabel,
        color: Theme.of(context).colorScheme.error,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.reopens
                  ? 'El pago queda registrado como anulado (no se borra). El '
                        'separado vuelve a «Activo» con saldo y no se podrá '
                        'entregar hasta que se cubra de nuevo.'
                  : 'El pago queda registrado como anulado (no se borra) y el '
                        'saldo del separado vuelve a subir.',
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ReasonField(
              controller: _reason,
              fieldKey: const Key('void_reason'),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(paymentActionsProvider).isLoading,
        confirmLabel: 'Anular pago',
        confirmIcon: Icons.block,
        destructive: true,
      ),
    );
  }
}
