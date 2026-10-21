import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';

/// Reglas del formulario de compra o separado. Es el único lugar de la app que
/// suma dinero: el contrato exige que, en una COMPRA, el `monto` enviado sea
/// exactamente precio × cantidad + caja. Todo lo demás (20 %, recargos, saldo)
/// lo calcula el servidor.
abstract final class CheckoutRules {
  static const maxQuantity = 20;

  /// Cuánto se puede comprar de una vez: lo que hay, hasta 20.
  static int maxQuantityFor(CatalogGarment garment) =>
      garment.stock.clamp(1, maxQuantity);

  static int boxPrice(BoxKind box, CatalogSettings settings) =>
      box == BoxKind.decorated ? settings.decoratedBoxPrice.round() : 0;

  /// Precio × cantidad + caja: el total de la prenda con su caja.
  static int total(
    CatalogGarment garment,
    int quantity,
    BoxKind box,
    CatalogSettings settings,
  ) => (garment.price * quantity).round() + boxPrice(box, settings);

  /// El 20 % ya calculado por el servidor (por unidad; el separado es de una).
  static int minimumDeposit(CatalogGarment garment) =>
      (garment.layawayAmount ?? garment.price).round();

  static String? name(String? value) =>
      (value ?? '').trim().length < 3 ? 'Escribe tu nombre completo.' : null;

  /// WhatsApp colombiano: 10 dígitos (o con indicativo, hasta 15).
  static String? whatsapp(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length < 10 || digits.length > 15
        ? 'Escribe tu WhatsApp con 10 dígitos.'
        : null;
  }

  static String? city(String? value, CatalogDelivery delivery) =>
      delivery == CatalogDelivery.shipping && (value ?? '').trim().isEmpty
      ? 'Escribe la ciudad.'
      : null;

  static String? address(String? value, CatalogDelivery delivery) =>
      delivery == CatalogDelivery.shipping && (value ?? '').trim().isEmpty
      ? 'Escribe la dirección de envío.'
      : null;

  /// Separado: lo transferido va del 20 % al total.
  static String? layawayAmount(double? value, int minimum, int total) {
    if (value == null) return 'Escribe cuánto transferiste.';
    if (value < minimum) {
      return 'Para separar debes transferir mínimo ${formatCop(minimum)}.';
    }
    if (value > total) return 'No puede superar ${formatCop(total)}.';
    return null;
  }
}
