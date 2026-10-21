import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/date_formatter.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

/// Textos ya listos para pintar. La vista no formatea nada.
extension GarmentLabels on Garment {
  String get nameLabel => formatDisplayText(name);
  String get typeLabel => formatDisplayText(typeName);
  String get priceLabel => formatCop(salePrice);
  String get previousPriceLabel =>
      previousPrice == null ? '' : formatCop(previousPrice!);
  String get purchasePriceLabel =>
      purchasePrice == null ? '' : formatCop(purchasePrice!);
  String get weightLabel => '${GarmentRules.measureInput(weight)} g';
  String get stockLabel => stock == 1 ? '1 unidad' : '$stock unidades';
  String get publishedLabel =>
      publishedAt == null ? '' : formatDate(publishedAt!);
  String get pendingLabel => pendingRequests == 1
      ? '1 solicitud pendiente'
      : '$pendingRequests solicitudes pendientes';

  /// «Largo 50 cm · Ancho 3 cm · Grosor 2 mm» con lo que haya.
  List<String> get measureParts => [
    if (length != null) 'Largo ${GarmentRules.measureInput(length)} cm',
    if (width != null) 'Ancho ${GarmentRules.measureInput(width)} cm',
    if (thickness != null) 'Grosor ${GarmentRules.measureInput(thickness)} mm',
  ];
}
