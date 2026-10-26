import 'package:flutter/material.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// La casilla obligatoria del separado: «Entiendo que la prenda se entrega solo
/// cuando pague el 100 %». Va al final del formulario, junto al botón, que
/// queda apagado hasta marcarla. El estado vive en el diálogo (una sola
/// fuente), no aquí.
class CheckoutLayawayAccept extends StatelessWidget {
  const CheckoutLayawayAccept({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    key: const Key('layaway_accept'),
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    dense: true,
    value: accepted,
    onChanged: (value) => onChanged(value ?? false),
    title: Text(
      LayawayRule.accept,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}
