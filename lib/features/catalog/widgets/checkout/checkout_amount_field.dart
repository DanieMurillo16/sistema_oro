import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/utils/cop_currency_input_formatter.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/utils/checkout_rules.dart';

/// Cuánto transferiste (solo en un separado): del mínimo al total.
class CheckoutAmountField extends StatelessWidget {
  const CheckoutAmountField({
    super.key,
    required this.controller,
    required this.minimum,
    required this.total,
  });

  final TextEditingController controller;
  final int minimum;
  final int total;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: const Key('checkout_amount'),
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      const CopCurrencyInputFormatter(),
    ],
    decoration: const InputDecoration(
      labelText: 'Valor que transferiste',
      prefixText: r'$ ',
      helperText: 'Puedes transferir más del mínimo, hasta el total.',
    ),
    validator: (text) =>
        CheckoutRules.layawayAmount(parseCopInput(text), minimum, total),
  );
}
