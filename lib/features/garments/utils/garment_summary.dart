import 'package:sistema_oro/features/garments/models/garment.dart';

/// Totales del inventario: cuántas prendas hay, cuántas unidades, cuánto pesan
/// y cuánto valen a precio de venta (cada una por su stock).
class GarmentSummary {
  const GarmentSummary({
    required this.garments,
    required this.units,
    required this.grams,
    required this.value,
  });

  factory GarmentSummary.of(Iterable<Garment> all) {
    var garments = 0;
    var units = 0;
    var grams = 0.0;
    var value = 0.0;
    for (final g in all) {
      garments++;
      units += g.stock;
      grams += g.weight * g.stock;
      value += g.salePrice * g.stock;
    }
    return GarmentSummary(
      garments: garments,
      units: units,
      grams: grams,
      value: value,
    );
  }

  final int garments;
  final int units;
  final double grams;
  final double value;
}
