import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/measure_formatter.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';

/// Etiqueta sobre la foto: el texto y su tono (ver `CatalogTag`).
enum CatalogTagKind { newest, sale, lastUnit, soldOut }

/// Lo que se paga para separar: el porcentaje del ajuste sobre el precio, hacia
/// arriba al peso (igual que el servidor). El detalle trae el valor oficial
/// (`layawayAmount`); el listado no, y se calcula con el mismo criterio.
double layawayDeposit(double price, double percent) =>
    (price * percent / 100).ceilToDouble();

extension CatalogGarmentLabels on CatalogGarment {
  /// Pesos que se pagan hoy para separar (el valor del servidor si lo hay).
  double depositFor(double percent) =>
      layawayAmount ?? layawayDeposit(price, percent);

  /// Cuánto queda por abonar después de separar.
  double balanceFor(double percent) => price - depositFor(percent);

  /// Lo que se ahorra frente al precio anterior (0 si no hay oferta).
  double get saving =>
      onSale && previousPrice != null ? previousPrice! - price : 0;

  String get savingLabel => formatCop(saving);

  String get nameLabel => formatDisplayText(name);
  String get typeLabel => formatDisplayText(type);
  String get priceLabel => formatCop(price);
  String get previousPriceLabel =>
      previousPrice == null ? '' : formatCop(previousPrice!);
  String get goldLabel =>
      goldType == 'ITALIANO' ? 'Oro italiano' : 'Oro nacional';

  /// «Oro italiano» → «Italiano»: corto para un badge.
  String get goldShort => goldType == 'ITALIANO' ? 'Italiano' : 'Nacional';
  String get weightLabel => '${formatMeasure(weight)} g';
  String get layawayLabel =>
      layawayAmount == null ? '' : formatCop(layawayAmount!);

  /// «5,2 g · 50 cm» para la tarjeta: peso y largo, que es lo que se compara.
  List<String> get shortSpecs => [
    weightLabel,
    if (length != null) '${formatMeasure(length)} cm',
  ];

  List<String> get measureParts => [
    if (length != null) 'Largo ${formatMeasure(length)} cm',
    if (width != null) 'Ancho ${formatMeasure(width)} cm',
    if (thickness != null) 'Grosor ${formatMeasure(thickness)} mm',
  ];

  /// Las etiquetas que corresponden, la más importante primero. Agotada
  /// reemplaza a las demás.
  List<CatalogTagKind> get tags => soldOut
      ? [CatalogTagKind.soldOut]
      : [
          if (lastUnit) CatalogTagKind.lastUnit,
          if (onSale) CatalogTagKind.sale,
          if (isNew) CatalogTagKind.newest,
        ];
}

extension CatalogTagLabels on CatalogTagKind {
  String get label => switch (this) {
    CatalogTagKind.newest => 'NUEVO',
    CatalogTagKind.sale => 'SALE',
    CatalogTagKind.lastUnit => 'ÚLTIMA UNIDAD',
    CatalogTagKind.soldOut => 'AGOTADO',
  };
}

extension CatalogSettingsLabels on CatalogSettings {
  String get decoratedBoxLabel => formatCop(decoratedBoxPrice);
  String get percentLabel => '${layawayPercent.round()} %';
}

extension RequestKindLabels on RequestKind {
  String get successTitle => this == RequestKind.purchase
      ? '¡Recibimos tu compra!'
      : '¡Recibimos tu separado!';

  /// El mensaje que se le manda a Barón por WhatsApp con el código del pedido,
  /// para que lo busque y lo apruebe.
  String whatsappMessage(String garmentName, String code) =>
      'Hola, acabo de enviar el comprobante de ${this == RequestKind.purchase ? 'mi compra' : 'mi separado'} '
      'de $garmentName. Mi código es $code.';
}

extension CatalogPageLabels on CatalogPage {
  String get countLabel =>
      'Mostrando ${items.length} de $total ${total == 1 ? 'prenda' : 'prendas'}';
}
