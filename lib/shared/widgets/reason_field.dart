import 'package:flutter/material.dart';
import 'package:sistema_oro/shared/utils/validators.dart';

/// Campo de «Motivo» (varias líneas, mínimo 3 letras) para rechazar, cancelar,
/// anular o ajustar. El motivo queda en el historial.
class ReasonField extends StatelessWidget {
  const ReasonField({
    super.key,
    required this.controller,
    required this.fieldKey,
  });

  final TextEditingController controller;
  final Key fieldKey;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: fieldKey,
    controller: controller,
    maxLength: 200,
    minLines: 2,
    maxLines: 4,
    decoration: const InputDecoration(labelText: 'Motivo', counterText: ''),
    validator: Validators.reason,
  );
}
