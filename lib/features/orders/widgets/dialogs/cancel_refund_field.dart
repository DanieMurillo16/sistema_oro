import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/cop_currency_input_formatter.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/shared/widgets/app_collapse.dart';

/// «Valor que se devuelve»: aparece solo en la devolución parcial y debe ser
/// menor a lo pagado.
class CancelRefundField extends StatelessWidget {
  const CancelRefundField({
    super.key,
    required this.controller,
    required this.visible,
    required this.paid,
  });

  final TextEditingController controller;
  final bool visible;
  final double paid;

  @override
  Widget build(BuildContext context) => AppCollapse(
    visible: visible,
    child: Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spaceMd),
      child: TextFormField(
        key: const Key('cancel_refund'),
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          const CopCurrencyInputFormatter(),
        ],
        decoration: const InputDecoration(
          labelText: 'Valor que se devuelve',
          prefixText: r'$ ',
        ),
        validator: (text) => visible
            ? OrderRules.partialRefund(parseCopInput(text), paid)
            : null,
      ),
    ),
  );
}
