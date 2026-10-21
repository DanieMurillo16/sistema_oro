import 'package:flutter/material.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_controllers.dart';

/// Descripción y, al editar, si la prenda se ve en el catálogo.
class GarmentExtraFields extends StatelessWidget {
  const GarmentExtraFields({
    super.key,
    required this.controllers,
    required this.isEdit,
    required this.active,
    required this.onActiveChanged,
  });

  final GarmentFormControllers controllers;
  final bool isEdit;
  final bool active;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        key: const Key('garment_description'),
        controller: controllers.description,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Descripción (opcional)',
          counterText: '',
        ),
      ),
      if (isEdit)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Visible en el catálogo'),
          value: active,
          onChanged: onActiveChanged,
        ),
    ],
  );
}
