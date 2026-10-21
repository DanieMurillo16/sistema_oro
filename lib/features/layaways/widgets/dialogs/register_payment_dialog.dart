import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/layaways/providers/payment_actions_provider.dart';
import 'package:sistema_oro/features/layaways/widgets/dialogs/payment_amount_date_row.dart';
import 'package:sistema_oro/features/layaways/utils/payment_rules.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/image_picker_field.dart';

/// Registrar un abono de un separado: valor, fecha, medio y comprobante.
class RegisterPaymentDialog extends ConsumerStatefulWidget {
  const RegisterPaymentDialog({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<RegisterPaymentDialog> createState() =>
      _RegisterPaymentDialogState();
}

class _RegisterPaymentDialogState extends ConsumerState<RegisterPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  var _date = DateTime.now();
  var _method = PaymentMethod.transfer;
  PickedImage? _receipt;
  var _submitted = false; // para mostrar el error del comprobante

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  String? get _receiptError =>
      _submitted && PaymentRules.needsReceipt(_method) && _receipt == null
      ? 'Adjunta el comprobante de la transferencia.'
      : null;

  void _submit() {
    setState(() => _submitted = true);
    final ready = _formKey.currentState!.validate() && _receiptError == null;
    if (!ready) return;
    ref
        .read(paymentActionsProvider.notifier)
        .register(
          orderId: widget.order.id,
          amount: parseCopInput(_amount.text)!.round(),
          date: _date,
          method: _method,
          receipt: _receipt,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      paymentActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final loading = ref.watch(paymentActionsProvider).isLoading;
    final order = widget.order;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.payments_outlined,
        title: 'Registrar abono',
        subtitle: 'Saldo ${order.balanceLabel}',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentAmountDateRow(
              amount: _amount,
              balance: order.balance,
              date: _date,
              onDateChanged: (date) => setState(() => _date = date),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            AppToggle<PaymentMethod>(
              options: [
                for (final method in PaymentMethod.values)
                  AppToggleOption(value: method, label: method.label),
              ],
              selected: _method,
              onSelected: (method) => setState(() => _method = method),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ImagePickerField(
              image: _receipt,
              onChanged: (image) => setState(() => _receipt = image),
              label: PaymentRules.needsReceipt(_method)
                  ? 'Adjuntar comprobante'
                  : 'Adjuntar comprobante (opcional)',
              errorText: _receiptError,
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: loading,
        confirmLabel: 'Registrar abono',
        confirmIcon: Icons.check,
      ),
    );
  }
}
