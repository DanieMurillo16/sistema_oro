import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_controllers.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';
import 'package:sistema_oro/shared/widgets/app_search_dropdown.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Nombre y tipo de prenda en pareja (se apilan si no caben) y, debajo, el
/// tipo de oro.
class GarmentBasicsFields extends StatelessWidget {
  const GarmentBasicsFields({
    super.key,
    required this.controllers,
    required this.types,
    required this.type,
    required this.onTypeChanged,
    required this.goldType,
    required this.onGoldTypeChanged,
  });

  final GarmentFormControllers controllers;
  final List<GarmentType> types;
  final GarmentType? type;
  final ValueChanged<GarmentType?> onTypeChanged;
  final GoldType goldType;
  final ValueChanged<GoldType> onGoldTypeChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Nombre y tipo, uno al lado del otro (se apilan solo si no caben).
      AppFormPair(
        first: TextFormField(
          key: const Key('garment_name'),
          controller: controllers.name,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            counterText: '',
          ),
          validator: GarmentRules.name,
        ),
        second: AppSearchDropdown<GarmentType>(
          label: 'Tipo de prenda',
          showSearchIcon: false, // en pareja, el texto necesita ese ancho
          value: type,
          items: types,
          itemLabel: (t) => t.name,
          onChanged: onTypeChanged,
          validator: GarmentRules.type,
        ),
      ),
      const SizedBox(height: DesignTokens.spaceMd),
      AppToggle<GoldType>(
        options: [
          for (final gold in GoldType.values)
            AppToggleOption(
              value: gold,
              label: 'Oro ${gold.label.toLowerCase()}',
            ),
        ],
        selected: goldType,
        onSelected: onGoldTypeChanged,
      ),
    ],
  );
}
