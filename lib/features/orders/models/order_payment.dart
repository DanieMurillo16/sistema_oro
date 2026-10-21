import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

/// Un pago de un pedido (el inicial del cliente o un abono). Nunca se borra:
/// solo se anula.
class OrderPayment {
  const OrderPayment({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    required this.receipt,
    required this.bank,
    required this.isInitial,
    required this.fromClient,
    required this.voided,
    required this.registeredBy,
    required this.voidReason,
    required this.voidedAt,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) => OrderPayment(
    id: jsonInt(json['id_pago']),
    amount: jsonDecimal(json['monto']),
    date: jsonDateOrNull(json['fecha_pago']),
    method: PaymentMethod.fromApi(jsonStringOrNull(json['medio'])),
    receipt: jsonStringOrNull(json['comprobante']),
    bank: jsonStringOrNull(json['banco']),
    isInitial: jsonBool(json['es_inicial']),
    fromClient: json['origen'] == 'CLIENTE',
    voided: json['estado'] == 'ANULADO',
    registeredBy: jsonStringOrNull(json['registrado_por']),
    voidReason: jsonStringOrNull(json['motivo_anulacion']),
    voidedAt: jsonDateOrNull(json['anulado_en']),
  );

  final int id;
  final double amount;
  final DateTime? date;
  final PaymentMethod method;

  /// Nombre de archivo del comprobante (se descarga con el Bearer).
  final String? receipt;

  /// Banco o medio desde el que transfirió el cliente (opcional).
  final String? bank;
  final bool isInitial;
  final bool fromClient;
  final bool voided;
  final String? registeredBy;
  final String? voidReason;
  final DateTime? voidedAt;
}

/// La decisión al cancelar un pedido con pagos (historial inmutable).
class OrderCancellation {
  const OrderCancellation({
    required this.decision,
    required this.paid,
    required this.retained,
    required this.returned,
    required this.reason,
    required this.cancelledBy,
    required this.cancelledAt,
  });

  factory OrderCancellation.fromJson(Map<String, dynamic> json) =>
      OrderCancellation(
        decision: CancelDecision.fromApi(jsonStringOrNull(json['decision'])),
        paid: jsonDecimal(json['monto_pagado']),
        retained: jsonDecimal(json['monto_retenido']),
        returned: jsonDecimal(json['monto_devuelto']),
        reason: jsonString(json['motivo']),
        cancelledBy: jsonString(json['cancelado_por']),
        cancelledAt: jsonDateOrNull(json['cancelado_en']),
      );

  final CancelDecision decision;
  final double paid;
  final double retained;
  final double returned;
  final String reason;
  final String cancelledBy;
  final DateTime? cancelledAt;
}
