import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/utils/cop_currency_input_formatter.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

final _decimalOnly = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

/// Campo de medida con decimales (coma o punto): peso, largo, ancho, grosor.
class DecimalField extends StatelessWidget {
  const DecimalField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;

  /// El peso es obligatorio; las medidas son opcionales.
  final bool required;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [_decimalOnly],
    maxLength: 7,
    decoration: InputDecoration(labelText: label, counterText: ''),
    validator: required ? GarmentRules.weight : GarmentRules.optionalMeasure,
  );
}

/// Campo de pesos con puntos de miles al escribir.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      const CopCurrencyInputFormatter(),
    ],
    decoration: InputDecoration(labelText: label, prefixText: r'$ '),
    validator: validator,
  );
}
