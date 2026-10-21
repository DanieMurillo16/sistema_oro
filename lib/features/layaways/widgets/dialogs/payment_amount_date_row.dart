import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/cop_currency_input_formatter.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/layaways/utils/payment_rules.dart';
import 'package:sistema_oro/shared/widgets/app_date_field.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';

/// Valor del abono (hasta el saldo) y fecha (hoy o antes), en pareja.
class PaymentAmountDateRow extends StatelessWidget {
  const PaymentAmountDateRow({
    super.key,
    required this.amount,
    required this.balance,
    required this.date,
    required this.onDateChanged,
  });

  final TextEditingController amount;
  final double balance;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) => AppFormPair(
    minWidth: DesignTokens.formShortPairMinWidth,
    first: TextFormField(
      key: const Key('payment_amount'),
      controller: amount,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        const CopCurrencyInputFormatter(),
      ],
      decoration: const InputDecoration(labelText: 'Valor', prefixText: r'$ '),
      validator: (text) => PaymentRules.amount(parseCopInput(text), balance),
    ),
    second: AppDateField(
      label: 'Fecha',
      value: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      onChanged: onDateChanged,
    ),
  );
}
