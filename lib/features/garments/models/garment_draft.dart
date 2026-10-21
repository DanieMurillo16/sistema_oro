import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';

/// Lo que se envía al crear o editar una prenda. Dinero en pesos enteros
/// (viaja como texto con 2 decimales); medidas ya normalizadas como texto.
class GarmentDraft {
  const GarmentDraft({
    required this.typeId,
    required this.name,
    required this.goldType,
    required this.weight,
    required this.salePrice,
    this.reference,
    this.description,
    this.length,
    this.width,
    this.thickness,
    this.previousPrice,
    this.purchasePrice,
    this.stock = 1,
    this.active = true,
  });

  final int typeId;
  final String name;
  final GoldType goldType;
  final String weight;
  final int salePrice;
  final String? reference;
  final String? description;
  final String? length;
  final String? width;
  final String? thickness;
  final int? previousPrice;

  /// `null` = no se envía (sin permiso de costo, o no se toca al editar).
  final int? purchasePrice;
  final int stock;
  final bool active;

  Map<String, dynamic> _common() => {
    'id_tipo': typeId,
    'nombre': name,
    'referencia': ?reference,
    'descripcion': ?description,
    'tipo_oro': goldType.api,
    'peso_gramos': weight,
    'largo_cm': ?length,
    'ancho_cm': ?width,
    'grosor_mm': ?thickness,
    'precio_venta': moneyText(salePrice),
    // Ausente en la edición = quitar la oferta (contrato de la API).
    if (previousPrice != null) 'precio_anterior': moneyText(previousPrice!),
    if (purchasePrice != null) 'precio_compra': moneyText(purchasePrice!),
  };

  Map<String, dynamic> toCreateJson() => {..._common(), 'stock': stock};

  Map<String, dynamic> toEditJson(int id) => {
    'id': id,
    ..._common(),
    'activa': active,
  };
}
