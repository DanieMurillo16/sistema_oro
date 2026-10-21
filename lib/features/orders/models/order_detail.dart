import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_payment.dart';

/// Respuesta de `pedidos/obtener.php`: el pedido, sus pagos y, si se canceló,
/// la decisión sobre lo abonado.
class OrderDetail {
  const OrderDetail({
    required this.order,
    required this.payments,
    required this.cancellation,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final cancellation = json['cancelacion'];
    return OrderDetail(
      order: Order.fromJson(jsonMap(json['pedido'])),
      payments: jsonMapList(json['pagos']).map(OrderPayment.fromJson).toList(),
      cancellation: cancellation is Map
          ? OrderCancellation.fromJson(jsonMap(cancellation))
          : null,
    );
  }

  final Order order;
  final List<OrderPayment> payments;
  final OrderCancellation? cancellation;
}

/// `pedidos/contadores.php`: lo que muestra la insignia del menú.
class OrderCounters {
  const OrderCounters({
    required this.pending,
    required this.activeLayaways,
    required this.overdueLayaways,
  });

  factory OrderCounters.fromJson(Map<String, dynamic> json) => OrderCounters(
    pending: jsonInt(json['pendientes']),
    activeLayaways: jsonInt(json['separados_activos']),
    overdueLayaways: jsonInt(json['separados_vencidos']),
  );

  static const empty = OrderCounters(
    pending: 0,
    activeLayaways: 0,
    overdueLayaways: 0,
  );

  final int pending;
  final int activeLayaways;
  final int overdueLayaways;

  String get pendingText => '$pending';
  String get activeLayawaysText => '$activeLayaways';
  String get overdueLayawaysText => '$overdueLayaways';

  @override
  bool operator ==(Object other) =>
      other is OrderCounters &&
      other.pending == pending &&
      other.activeLayaways == activeLayaways &&
      other.overdueLayaways == overdueLayaways;

  @override
  int get hashCode => Object.hash(pending, activeLayaways, overdueLayaways);
}
