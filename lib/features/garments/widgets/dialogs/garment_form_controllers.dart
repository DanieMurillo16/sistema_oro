import 'package:flutter/material.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

/// Los controladores de texto del formulario de prenda (estado efímero de la
/// vista). Se crean con los datos de la prenda al editar y se liberan juntos.
class GarmentFormControllers {
  GarmentFormControllers([Garment? g])
    : name = TextEditingController(text: g?.name),
      reference = TextEditingController(text: g?.reference),
      weight = TextEditingController(
        text: GarmentRules.measureInput(g?.weight),
      ),
      length = TextEditingController(
        text: GarmentRules.measureInput(g?.length),
      ),
      width = TextEditingController(text: GarmentRules.measureInput(g?.width)),
      thickness = TextEditingController(
        text: GarmentRules.measureInput(g?.thickness),
      ),
      salePrice = TextEditingController(
        text: GarmentRules.moneyInput(g?.salePrice),
      ),
      previousPrice = TextEditingController(
        text: GarmentRules.moneyInput(g?.previousPrice),
      ),
      purchasePrice = TextEditingController(
        text: GarmentRules.moneyInput(g?.purchasePrice),
      ),
      stock = TextEditingController(text: g == null ? '1' : ''),
      description = TextEditingController(text: g?.description);

  final TextEditingController name;
  final TextEditingController reference;
  final TextEditingController weight;
  final TextEditingController length;
  final TextEditingController width;
  final TextEditingController thickness;
  final TextEditingController salePrice;
  final TextEditingController previousPrice;
  final TextEditingController purchasePrice;
  final TextEditingController stock;
  final TextEditingController description;

  void dispose() {
    for (final controller in [
      name,
      reference,
      weight,
      length,
      width,
      thickness,
      salePrice,
      previousPrice,
      purchasePrice,
      stock,
      description,
    ]) {
      controller.dispose();
    }
  }
}
