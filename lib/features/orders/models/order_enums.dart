import 'package:sistema_oro/core/theme/status_colors.dart';

enum OrderType {
  purchase('COMPRA', 'Compra'),
  layaway('SEPARADO', 'Separado');

  const OrderType(this.api, this.label);

  final String api;
  final String label;

  static OrderType fromApi(String? value) =>
      values.firstWhere((t) => t.api == value, orElse: () => purchase);
}

/// Estados de un pedido (compra o separado), tal como los dice el servidor.
enum OrderStatus {
  pending('PENDIENTE', 'Por revisar', StatusTone.warning),
  confirmed('CONFIRMADO', 'Confirmado', StatusTone.info),
  active('ACTIVO', 'Activo', StatusTone.info),
  paid('PAGADO', 'Pagado', StatusTone.success),
  shipped('ENVIADO', 'Enviado', StatusTone.info),
  delivered('ENTREGADO', 'Entregado', StatusTone.success),
  rejected('RECHAZADO', 'Rechazado', StatusTone.error),
  cancelled('CANCELADO', 'Cancelado', StatusTone.error);

  const OrderStatus(this.api, this.label, this.tone);

  final String api;
  final String label;
  final StatusTone tone;

  static OrderStatus fromApi(String? value) =>
      values.firstWhere((s) => s.api == value, orElse: () => pending);
}

enum DeliveryType {
  pickup('RECOGE', 'Recoge en tienda'),
  shipping('ENVIO', 'Envío');

  const DeliveryType(this.api, this.label);

  final String api;
  final String label;

  static DeliveryType fromApi(String? value) =>
      values.firstWhere((d) => d.api == value, orElse: () => pickup);
}

/// Qué hace Barón con lo ya abonado al cancelar (decisión del dueño).
enum CancelDecision {
  keepAll('SE_QUEDA_TODO', 'Retener todo'),
  refundAll('SE_DEVUELVE_TODO', 'Devolver todo'),
  refundPart('DEVOLUCION_PARCIAL', 'Parcial');

  const CancelDecision(this.api, this.label);

  final String api;
  final String label;

  static CancelDecision fromApi(String? value) =>
      values.firstWhere((d) => d.api == value, orElse: () => keepAll);
}

enum PaymentMethod {
  transfer('TRANSFERENCIA', 'Transferencia'),
  cash('EFECTIVO', 'Efectivo'),
  other('OTRO', 'Otro');

  const PaymentMethod(this.api, this.label);

  final String api;
  final String label;

  static PaymentMethod fromApi(String? value) =>
      values.firstWhere((m) => m.api == value, orElse: () => other);
}
