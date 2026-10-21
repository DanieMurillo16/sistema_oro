import 'package:sistema_oro/core/utils/json_helpers.dart';

enum GoldType {
  national('NACIONAL', 'Nacional'),
  italian('ITALIANO', 'Italiano');

  const GoldType(this.api, this.label);

  final String api;
  final String label;

  static GoldType fromApi(String? value) =>
      values.firstWhere((g) => g.api == value, orElse: () => national);
}

/// Una foto de la prenda: miniatura para listas y grande para el detalle.
class GarmentImage {
  const GarmentImage({
    required this.id,
    required this.order,
    required this.thumbUrl,
    required this.bigUrl,
  });

  factory GarmentImage.fromJson(Map<String, dynamic> json) => GarmentImage(
    id: jsonInt(json['id_imagen']),
    order: jsonInt(json['orden']),
    thumbUrl: jsonString(json['url_miniatura']),
    bigUrl: jsonString(json['url_grande']),
  );

  final int id;
  final int order;
  final String thumbUrl;
  final String bigUrl;
}

/// Una prenda del inventario. `purchasePrice` es PRIVADO: viene `null` si el
/// usuario no tiene `prendas.ver_costo`. Los campos del detalle (descripción e
/// imágenes) solo vienen en `prendas/obtener.php`.
class Garment {
  const Garment({
    required this.id,
    required this.name,
    required this.reference,
    required this.typeId,
    required this.typeName,
    required this.goldType,
    required this.weight,
    required this.length,
    required this.width,
    required this.thickness,
    required this.salePrice,
    required this.previousPrice,
    required this.purchasePrice,
    required this.stock,
    required this.active,
    required this.publishedAt,
    required this.pendingRequests,
    required this.thumbnail,
    this.description,
    this.images = const [],
  });

  factory Garment.fromJson(Map<String, dynamic> json) => Garment(
    id: jsonInt(json['id_prenda']),
    name: jsonString(json['nombre']),
    reference: jsonStringOrNull(json['referencia']),
    typeId: jsonInt(json['id_tipo_prenda']),
    typeName: jsonString(json['tipo']),
    goldType: GoldType.fromApi(jsonStringOrNull(json['tipo_oro'])),
    weight: jsonDecimal(json['peso_gramos']),
    length: jsonDecimalOrNull(json['largo_cm']),
    width: jsonDecimalOrNull(json['ancho_cm']),
    thickness: jsonDecimalOrNull(json['grosor_mm']),
    salePrice: jsonDecimal(json['precio_venta']),
    previousPrice: jsonDecimalOrNull(json['precio_anterior']),
    purchasePrice: jsonDecimalOrNull(json['precio_compra']),
    stock: jsonInt(json['stock']),
    active: jsonBool(json['activa']),
    publishedAt: jsonDateOrNull(json['publicada_en']),
    pendingRequests: jsonInt(json['solicitudes_pendientes']),
    // El listado trae `miniatura`; el detalle solo trae `imagenes` (sin
    // `miniatura`): se toma la primera para que la fila no pierda su foto al
    // actualizarse con el detalle.
    thumbnail:
        jsonStringOrNull(json['miniatura']) ??
        jsonMapList(json['imagenes'])
            .map(GarmentImage.fromJson)
            .map((image) => image.thumbUrl)
            .where((url) => url.isNotEmpty)
            .firstOrNull,
    description: jsonStringOrNull(json['descripcion']),
    images: jsonMapList(json['imagenes']).map(GarmentImage.fromJson).toList(),
  );

  final int id;
  final String name;
  final String? reference;
  final int typeId;
  final String typeName;
  final GoldType goldType;
  final double weight;
  final double? length;
  final double? width;
  final double? thickness;
  final double salePrice;
  final double? previousPrice;
  final double? purchasePrice;
  final int stock;
  final bool active;
  final DateTime? publishedAt;
  final int pendingRequests;
  final String? thumbnail;
  final String? description;
  final List<GarmentImage> images;

  /// La misma prenda con otro número de solicitudes pendientes (el detalle no
  /// lo trae: se conserva el de la fila del listado).
  Garment withPendingRequests(int count) => Garment(
    id: id,
    name: name,
    reference: reference,
    typeId: typeId,
    typeName: typeName,
    goldType: goldType,
    weight: weight,
    length: length,
    width: width,
    thickness: thickness,
    salePrice: salePrice,
    previousPrice: previousPrice,
    purchasePrice: purchasePrice,
    stock: stock,
    active: active,
    publishedAt: publishedAt,
    pendingRequests: count,
    thumbnail: thumbnail,
    description: description,
    images: images,
  );

  bool get onSale => previousPrice != null && previousPrice! > salePrice;
  bool get soldOut => stock <= 0;
}

/// Un tipo de prenda (categoría): catálogo que crece.
class GarmentType {
  const GarmentType({
    required this.id,
    required this.name,
    required this.order,
    required this.active,
    required this.garments,
  });

  factory GarmentType.fromJson(Map<String, dynamic> json) => GarmentType(
    id: jsonInt(json['id_tipo_prenda']),
    name: jsonString(json['nombre']),
    order: jsonInt(json['orden']),
    active: jsonBool(json['activo']),
    garments: jsonInt(json['prendas']),
  );

  final int id;
  final String name;
  final int order;
  final bool active;
  final int garments;
}
