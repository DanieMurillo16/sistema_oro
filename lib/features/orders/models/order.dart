import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

/// Un pedido (compra) o separado. Los campos de dinero llegan ya calculados
/// por el servidor: la app solo los muestra. Los marcados «detalle» solo vienen
/// en `pedidos/obtener.php`.
class Order {
  const Order({
    required this.id,
    required this.code,
    required this.type,
    required this.status,
    required this.quantity,
    required this.delivery,
    required this.createdAt,
    required this.clientId,
    required this.clientName,
    required this.whatsapp,
    required this.garmentId,
    required this.garmentName,
    required this.reference,
    required this.thumbnail,
    required this.total,
    required this.paid,
    required this.balance,
    required this.monthsOverdue,
    required this.deadline,
    this.lastPayment,
    this.detail,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: jsonInt(json['id_pedido']),
    code: jsonString(json['codigo']),
    type: OrderType.fromApi(jsonStringOrNull(json['tipo'])),
    status: OrderStatus.fromApi(jsonStringOrNull(json['estado'])),
    quantity: jsonInt(json['cantidad'], 1),
    delivery: DeliveryType.fromApi(jsonStringOrNull(json['entrega_tipo'])),
    createdAt: jsonDateOrNull(json['creado_en']),
    clientId: jsonInt(json['id_cliente']),
    clientName: jsonString(json['cliente']),
    whatsapp: jsonString(json['whatsapp']),
    garmentId: jsonInt(json['id_prenda']),
    garmentName: jsonString(json['prenda']),
    reference: jsonStringOrNull(json['referencia']),
    thumbnail: jsonStringOrNull(json['miniatura'] ?? json['imagen']),
    total: jsonDecimal(json['total_a_pagar']),
    paid: jsonDecimal(json['total_pagado']),
    balance: jsonDecimal(json['saldo']),
    monthsOverdue: jsonInt(json['meses_vencidos']),
    deadline: jsonDateOrNull(json['fecha_limite']),
    lastPayment: jsonDateOrNull(json['ultimo_pago']),
    detail: json.containsKey('subtotal')
        ? OrderDetailFields.fromJson(json)
        : null,
  );

  final int id;
  final String code;
  final OrderType type;
  final OrderStatus status;
  final int quantity;
  final DeliveryType delivery;
  final DateTime? createdAt;
  final int clientId;
  final String clientName;
  final String whatsapp;
  final int garmentId;
  final String garmentName;
  final String? reference;
  final String? thumbnail;
  final double total;
  final double paid;
  final double balance;
  final int monthsOverdue;
  final DateTime? deadline;

  /// Fecha del último pago vigente (pago inicial incluido); `null` si el
  /// servidor aún no la manda.
  final DateTime? lastPayment;

  /// Solo si vino de `pedidos/obtener.php`.
  final OrderDetailFields? detail;

  bool get isLayaway => type == OrderType.layaway;
}

/// Los campos que solo trae el detalle.
class OrderDetailFields {
  const OrderDetailFields({
    required this.unitPrice,
    required this.box,
    required this.boxPrice,
    required this.layawayPercent,
    required this.monthlySurcharge,
    required this.city,
    required this.address,
    required this.trackingNumber,
    required this.startedAt,
    required this.paidAt,
    required this.reviewedAt,
    required this.rejectReason,
    required this.deliveredAt,
    required this.note,
    required this.image,
    required this.subtotal,
    required this.surcharges,
    required this.minimumDeposit,
  });

  factory OrderDetailFields.fromJson(Map<String, dynamic> json) =>
      OrderDetailFields(
        unitPrice: jsonDecimal(json['precio_unitario']),
        box: jsonString(json['caja']),
        boxPrice: jsonDecimal(json['precio_caja']),
        layawayPercent: jsonDecimal(json['porcentaje_separado']),
        monthlySurcharge: jsonDecimal(json['recargo_mes']),
        city: jsonStringOrNull(json['ciudad']),
        address: jsonStringOrNull(json['direccion']),
        trackingNumber: jsonStringOrNull(json['guia_envio']),
        startedAt: jsonDateOrNull(json['plazo_desde']),
        paidAt: jsonDateOrNull(json['pagado_en']),
        reviewedAt: jsonDateOrNull(json['revisado_en']),
        rejectReason: jsonStringOrNull(json['motivo_rechazo']),
        deliveredAt: jsonDateOrNull(json['entregado_en']),
        note: jsonStringOrNull(json['nota_interna']),
        image: jsonStringOrNull(json['imagen']),
        subtotal: jsonDecimal(json['subtotal']),
        surcharges: jsonDecimal(json['recargos']),
        minimumDeposit: jsonDecimal(json['monto_separado_minimo']),
      );

  final double unitPrice;
  final String box; // GRATIS | DECORADA
  final double boxPrice;
  final double layawayPercent;
  final double monthlySurcharge;
  final String? city;
  final String? address;
  final String? trackingNumber;
  final DateTime? startedAt;
  final DateTime? paidAt;
  final DateTime? reviewedAt;
  final String? rejectReason;
  final DateTime? deliveredAt;
  final String? note;
  final String? image;
  final double subtotal;
  final double surcharges;
  final double minimumDeposit;

  bool get decoratedBox => box == 'DECORADA';
}
