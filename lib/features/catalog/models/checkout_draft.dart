import 'package:sistema_oro/core/utils/json_helpers.dart';

enum RequestKind {
  purchase('COMPRA', 'Comprar'),
  layaway('SEPARADO', 'Separar');

  const RequestKind(this.api, this.label);

  final String api;
  final String label;
}

enum BoxKind {
  free('GRATIS', 'Caja gratis'),
  decorated('DECORADA', 'Caja decorada');

  const BoxKind(this.api, this.label);

  final String api;
  final String label;
}

enum CatalogDelivery {
  pickup('RECOGE', 'Recoger'),
  shipping('ENVIO', 'Envío');

  const CatalogDelivery(this.api, this.label);

  final String api;
  final String label;
}

/// Lo que se envía a `publico/solicitud.php`. [submitKey] (UUID v4) se genera
/// al abrir el formulario y se reutiliza al reintentar: el servidor devuelve el
/// mismo código en vez de duplicar. El campo señuelo `sitio_web` va vacío.
class CheckoutDraft {
  const CheckoutDraft({
    required this.submitKey,
    required this.kind,
    required this.garmentId,
    required this.quantity,
    required this.box,
    required this.name,
    required this.whatsapp,
    required this.delivery,
    required this.amount,
    this.city,
    this.address,
    this.bank,
  });

  final String submitKey;
  final RequestKind kind;
  final int garmentId;
  final int quantity;
  final BoxKind box;
  final String name;
  final String whatsapp;
  final CatalogDelivery delivery;

  /// Pesos transferidos (entero); viaja como texto con 2 decimales.
  final int amount;
  final String? city;
  final String? address;

  /// Banco o medio desde el que transfirió (opcional); viaja con el comprobante.
  final String? bank;

  Map<String, dynamic> toFields() => {
    'clave_envio': submitKey,
    'tipo': kind.api,
    'id_prenda': garmentId,
    'cantidad': quantity,
    'caja': box.api,
    'nombre': name,
    'whatsapp': whatsapp,
    'entrega': delivery.api,
    'ciudad': ?city,
    'direccion': ?address,
    'monto': moneyText(amount),
    'banco': ?bank,
    'sitio_web': '',
  };
}
