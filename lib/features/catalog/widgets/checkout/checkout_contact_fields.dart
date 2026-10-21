import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';
import 'package:sistema_oro/features/catalog/utils/checkout_rules.dart';

/// Nombre y WhatsApp de quien compra (solo se piden en este momento), uno al
/// lado del otro; se apilan solo si no caben.
class CheckoutContactFields extends StatelessWidget {
  const CheckoutContactFields({
    super.key,
    required this.name,
    required this.whatsapp,
  });

  final TextEditingController name;
  final TextEditingController whatsapp;

  @override
  Widget build(BuildContext context) => AppFormPair(
    first: TextFormField(
      key: const Key('checkout_name'),
      controller: name,
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Tu nombre',
        counterText: '',
      ),
      validator: CheckoutRules.name,
    ),
    second: TextFormField(
      key: const Key('checkout_whatsapp'),
      controller: whatsapp,
      maxLength: 15,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Tu WhatsApp',
        counterText: '',
      ),
      validator: CheckoutRules.whatsapp,
    ),
  );
}
