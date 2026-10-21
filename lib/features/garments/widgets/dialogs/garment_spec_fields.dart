import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_controllers.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_number_fields.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';

/// Referencia, peso y medidas en parejas de campos cortos; con las unidades al
/// crear (al editar el stock se ajusta aparte).
class GarmentSpecFields extends StatelessWidget {
  const GarmentSpecFields({
    super.key,
    required this.controllers,
    required this.isEdit,
  });

  final GarmentFormControllers controllers;
  final bool isEdit;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppFormPair(
        minWidth: DesignTokens.formShortPairMinWidth,
        first: TextFormField(
          key: const Key('garment_reference'),
          controller: controllers.reference,
          maxLength: 40,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Referencia',
            counterText: '',
          ),
        ),
        second: DecimalField(
          key: const Key('garment_weight'),
          controller: controllers.weight,
          label: 'Peso (g)',
          required: true,
        ),
      ),
      const SizedBox(height: DesignTokens.spaceMd),
      AppFormPair(
        minWidth: DesignTokens.formShortPairMinWidth,
        first: DecimalField(
          key: const Key('garment_length'),
          controller: controllers.length,
          label: 'Largo (cm)',
        ),
        second: DecimalField(
          key: const Key('garment_width'),
          controller: controllers.width,
          label: 'Ancho (cm)',
        ),
      ),
      const SizedBox(height: DesignTokens.spaceMd),
      AppFormPair(
        minWidth: DesignTokens.formShortPairMinWidth,
        first: DecimalField(
          key: const Key('garment_thickness'),
          controller: controllers.thickness,
          label: 'Grosor (mm)',
        ),
        second: isEdit
            ? const SizedBox.shrink()
            : TextFormField(
                key: const Key('garment_stock'),
                controller: controllers.stock,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Unidades',
                  counterText: '',
                ),
                validator: GarmentRules.stock,
              ),
      ),
    ],
  );
}
