import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

/// Lo que se ha vendido o separado de una prenda (sin solicitudes por revisar
/// ni rechazadas o canceladas), del más reciente al más antiguo.
class GarmentSales {
  const GarmentSales({required this.orders});

  factory GarmentSales.of(Iterable<Order> all, int garmentId) {
    const counted = {
      OrderStatus.confirmed,
      OrderStatus.active,
      OrderStatus.paid,
      OrderStatus.shipped,
      OrderStatus.delivered,
    };
    final mine =
        [
          for (final o in all)
            if (o.garmentId == garmentId && counted.contains(o.status)) o,
        ]..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
    return GarmentSales(orders: mine);
  }

  final List<Order> orders;

  int get units => orders.fold(0, (sum, o) => sum + o.quantity);
}
