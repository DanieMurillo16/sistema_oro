import 'package:sistema_oro/core/utils/json_helpers.dart';

/// Modelos PÚBLICOS del catálogo. No existe aquí ningún precio de compra ni
/// dato de clientes: el servidor tampoco los manda.

class CatalogType {
  const CatalogType({required this.id, required this.name});

  factory CatalogType.fromJson(Map<String, dynamic> json) => CatalogType(
    id: jsonInt(json['id_tipo_prenda']),
    name: jsonString(json['nombre']),
  );

  final int id;
  final String name;
}

class CatalogImage {
  const CatalogImage({required this.thumbUrl, required this.bigUrl});

  factory CatalogImage.fromJson(Map<String, dynamic> json) => CatalogImage(
    thumbUrl: jsonString(json['url_miniatura']),
    bigUrl: jsonString(json['url_grande']),
  );

  final String thumbUrl;
  final String bigUrl;
}

/// Una prenda del catálogo. `layawayAmount` (el 20 % ya calculado) y las
/// imágenes solo vienen en el detalle.
class CatalogGarment {
  const CatalogGarment({
    required this.id,
    required this.name,
    required this.reference,
    required this.type,
    required this.goldType,
    required this.weight,
    required this.length,
    required this.width,
    required this.thickness,
    required this.price,
    required this.previousPrice,
    required this.stock,
    required this.isNew,
    required this.onSale,
    required this.lastUnit,
    required this.soldOut,
    required this.thumbnail,
    this.description,
    this.layawayAmount,
    this.images = const [],
    this.photoCount = 0,
  });

  /// El listado trae `miniatura`; el detalle no (API.md): ahí sirve la de la
  /// primera foto.
  static String? _thumbnail(Map<String, dynamic> json) {
    final own = jsonStringOrNull(json['miniatura']);
    if (own != null) return own;
    final first = jsonMapList(json['imagenes']).firstOrNull;
    final url = first == null ? '' : CatalogImage.fromJson(first).thumbUrl;
    return url.isEmpty ? null : url;
  }

  factory CatalogGarment.fromJson(Map<String, dynamic> json) => CatalogGarment(
    id: jsonInt(json['id_prenda']),
    name: jsonString(json['nombre']),
    reference: jsonStringOrNull(json['referencia']),
    type: jsonString(json['tipo']),
    goldType: jsonString(json['tipo_oro']),
    weight: jsonDecimal(json['peso_gramos']),
    length: jsonDecimalOrNull(json['largo_cm']),
    width: jsonDecimalOrNull(json['ancho_cm']),
    thickness: jsonDecimalOrNull(json['grosor_mm']),
    price: jsonDecimal(json['precio_venta']),
    previousPrice: jsonDecimalOrNull(json['precio_anterior']),
    stock: jsonInt(json['stock']),
    isNew: jsonBool(json['es_nueva']),
    onSale: jsonBool(json['en_oferta']),
    lastUnit: jsonBool(json['ultima_unidad']),
    soldOut: jsonBool(json['agotada']),
    thumbnail: _thumbnail(json),
    description: jsonStringOrNull(json['descripcion']),
    layawayAmount: jsonDecimalOrNull(json['valor_separado']),
    images: jsonMapList(json['imagenes']).map(CatalogImage.fromJson).toList(),
    photoCount: jsonInt(json['fotos']),
  );

  final int id;
  final String name;
  final String? reference;
  final String type;
  final String goldType; // NACIONAL | ITALIANO
  final double weight;
  final double? length;
  final double? width;
  final double? thickness;
  final double price;
  final double? previousPrice;
  final int stock;
  final bool isNew;
  final bool onSale;
  final bool lastUnit;
  final bool soldOut;
  final String? thumbnail;
  final String? description;
  final double? layawayAmount;
  final List<CatalogImage> images;

  /// Cuántas fotos tiene (el listado lo dice sin traerlas; 0 = no se sabe).
  final int photoCount;
}

/// Ajustes públicos: WhatsApp de Barón, datos de transferencia y valores del
/// separado y la caja. Vienen de `publico/ajustes.php`.
class CatalogSettings {
  const CatalogSettings({
    required this.whatsapp,
    required this.bank,
    required this.account,
    required this.holder,
    required this.transferNote,
    required this.layawayPercent,
    required this.monthlySurcharge,
    required this.decoratedBoxPrice,
    required this.showSoldOut,
    this.logoUrl = '',
  });

  factory CatalogSettings.fromJson(Map<String, dynamic> json) =>
      CatalogSettings(
        whatsapp: jsonString(json['whatsapp_baron']),
        bank: jsonString(json['transferencia_banco']),
        account: jsonString(json['transferencia_cuenta']),
        holder: jsonString(json['transferencia_titular']),
        transferNote: jsonString(json['transferencia_texto']),
        layawayPercent: jsonDecimal(json['porcentaje_separado'], 20),
        monthlySurcharge: jsonDecimal(json['recargo_mes_vencido']),
        decoratedBoxPrice: jsonDecimal(json['precio_caja_decorada']),
        showSoldOut: jsonBool(json['catalogo_mostrar_agotadas']),
        logoUrl: jsonString(json['logo_url']),
      );

  static const empty = CatalogSettings(
    whatsapp: '',
    bank: '',
    account: '',
    holder: '',
    transferNote: '',
    layawayPercent: 20,
    monthlySurcharge: 0,
    decoratedBoxPrice: 0,
    showSoldOut: false,
  );

  final String whatsapp;
  final String bank;
  final String account;
  final String holder;
  final String transferNote;
  final double layawayPercent;
  final double monthlySurcharge;
  final double decoratedBoxPrice;
  final bool showSoldOut;

  /// Logo de la marca que subió el dueño (ya con `?v=` para la caché). Vacío =
  /// se usa el logo empaquetado en la app.
  final String logoUrl;

  bool get hasWhatsapp => whatsapp.isNotEmpty;
  bool get hasTransferData => bank.isNotEmpty || account.isNotEmpty;
}

/// La página de resultados del listado.
class CatalogPage {
  const CatalogPage({required this.items, required this.total});

  final List<CatalogGarment> items;
  final int total;

  bool get hasMore => items.length < total;

  /// Resume lo que se ve de cada prenda: sirve para saber si el listado
  /// cambió (se vendió una, cambió un precio o el stock) sin reconstruir todo.
  String get signature => [
    total,
    for (final g in items)
      '${g.id}|${g.name}|${g.price}|${g.previousPrice}|${g.stock}|${g.thumbnail}|${g.photoCount}',
  ].join(';');
}

/// Lo que contesta `publico/solicitud.php`: solo el código del pedido.
class RequestReceipt {
  const RequestReceipt({required this.code, required this.repeated});

  factory RequestReceipt.fromJson(Map<String, dynamic> json) => RequestReceipt(
    code: jsonString(json['codigo']),
    repeated: jsonBool(json['repetida']),
  );

  final String code;
  final bool repeated;
}
