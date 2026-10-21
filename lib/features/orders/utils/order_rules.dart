import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/models/order_payment.dart';
import 'package:sistema_oro/shared/utils/search_options.dart';
import 'package:sistema_oro/shared/utils/validators.dart';

/// Pestañas de la lista de pedidos.
enum OrdersTab {
  review('Por revisar'),
  purchases('Compras'),
  all('Todos');

  const OrdersTab(this.label);

  final String label;
}

/// Pestañas de la lista de separados.
enum LayawaysTab {
  active('Activos'),
  remind('Recordar'),
  overdue('Vencidos'),
  all('Todos');

  const LayawaysTab(this.label);

  final String label;
}

/// Acciones que Barón puede hacer sobre un pedido.
enum OrderAction { confirm, reject, registerPayment, ship, deliver, cancel }

/// Reglas puras de pedidos: qué acciones aplican a cada estado (el servidor
/// igual las valida) y cómo se ordena y filtra la lista.
abstract final class OrderRules {
  static bool canConfirm(Order o) => o.status == OrderStatus.pending;

  static bool canReject(Order o) => o.status == OrderStatus.pending;

  static bool canCancel(Order o) =>
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.active ||
      o.status == OrderStatus.paid;

  /// Se marca enviado solo si es envío y el pedido está listo para salir.
  static bool canShip(Order o) {
    if (o.delivery != DeliveryType.shipping) return false;
    return o.isLayaway
        ? o.status == OrderStatus.paid
        : o.status == OrderStatus.confirmed;
  }

  static bool canDeliver(Order o) {
    if (o.status == OrderStatus.shipped) return true;
    if (o.delivery != DeliveryType.pickup) return false;
    return o.isLayaway
        ? o.status == OrderStatus.paid
        : o.status == OrderStatus.confirmed;
  }

  /// Los abonos solo existen en un separado activo.
  static bool canRegisterPayment(Order o) =>
      o.isLayaway && o.status == OrderStatus.active;

  static bool canEditDelivery(Order o) =>
      o.status == OrderStatus.pending ||
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.active ||
      o.status == OrderStatus.paid;

  /// Un pago (también el inicial) se anula solo en un separado activo o ya
  /// pagado: nada se borra, el saldo se recalcula y, si estaba pagado, vuelve a
  /// «Activo». En compras, enviados, entregados, cancelados o rechazados no.
  static bool canVoidPayment(Order o, OrderPayment p) =>
      !p.voided &&
      o.isLayaway &&
      (o.status == OrderStatus.active || o.status == OrderStatus.paid);

  /// Las acciones que corresponden al estado del pedido y a los permisos de
  /// quien mira ([can] dice si tiene un permiso).
  static List<OrderAction> actionsFor(Order o, bool Function(String) can) => [
    if (canConfirm(o) && can('pedidos.revisar')) OrderAction.confirm,
    if (canReject(o) && can('pedidos.revisar')) OrderAction.reject,
    if (canRegisterPayment(o) && can('pagos.registrar'))
      OrderAction.registerPayment,
    if (canShip(o) && can('pedidos.entregar')) OrderAction.ship,
    if (canDeliver(o) && can('pedidos.entregar')) OrderAction.deliver,
    if (canCancel(o) && can('pedidos.cancelar')) OrderAction.cancel,
  ];

  static bool isOverdue(Order o) =>
      o.isLayaway && o.status == OrderStatus.active && o.monthsOverdue > 0;

  /// Por revisar primero y luego lo más reciente (igual que el servidor).
  static List<Order> sorted(List<Order> orders) {
    final copy = [...orders];
    copy.sort((a, b) {
      final aPending = a.status == OrderStatus.pending ? 0 : 1;
      final bPending = b.status == OrderStatus.pending ? 0 : 1;
      if (aPending != bPending) return aPending - bPending;
      final byDate = (b.createdAt ?? DateTime(0)).compareTo(
        a.createdAt ?? DateTime(0),
      );
      return byDate != 0 ? byDate : b.id - a.id;
    });
    return copy;
  }

  static List<Order> forOrdersTab(
    List<Order> all,
    OrdersTab tab,
    String query,
  ) {
    final byTab = switch (tab) {
      OrdersTab.review => _inArrivalOrder(
        all.where((o) => o.status == OrderStatus.pending),
      ),
      OrdersTab.purchases => all.where((o) => !o.isLayaway),
      OrdersTab.all => all,
    };
    return _search(byTab, query);
  }

  /// Por revisar: el primero que llegó va primero.
  static List<Order> _inArrivalOrder(Iterable<Order> orders) {
    final copy = [...orders];
    copy.sort((a, b) {
      final byDate = (a.createdAt ?? DateTime(0)).compareTo(
        b.createdAt ?? DateTime(0),
      );
      return byDate != 0 ? byDate : a.id - b.id;
    });
    return copy;
  }

  /// Días desde el último abono (o, si no hay fecha, desde que se pidió).
  static int daysWithoutPayment(Order o, DateTime now) {
    final since = o.lastPayment ?? o.createdAt;
    if (since == null) return 0;
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(since.year, since.month, since.day);
    final days = today.difference(day).inDays;
    return days < 0 ? 0 : days;
  }

  /// Separados activos, el que lleva más días sin abonar primero.
  static List<Order> _toRemind(Iterable<Order> layaways, DateTime now) {
    final active = layaways.where((o) => o.status == OrderStatus.active);
    final copy = [...active];
    copy.sort((a, b) {
      final byDays = daysWithoutPayment(
        b,
        now,
      ).compareTo(daysWithoutPayment(a, now));
      return byDays != 0 ? byDays : b.balance.compareTo(a.balance);
    });
    return copy;
  }

  static List<Order> forLayawaysTab(
    List<Order> all,
    LayawaysTab tab,
    String query, {
    DateTime? now,
  }) {
    final layaways = all.where((o) => o.isLayaway);
    final byTab = switch (tab) {
      LayawaysTab.active => layaways.where(
        (o) => o.status == OrderStatus.active,
      ),
      LayawaysTab.remind => _toRemind(layaways, now ?? DateTime.now()),
      LayawaysTab.overdue => layaways.where(isOverdue),
      LayawaysTab.all => layaways,
    };
    return _search(byTab, query);
  }

  static List<Order> _search(Iterable<Order> orders, String query) {
    final text = normalizeSearch(query);
    if (text.isEmpty) return orders.toList();
    return orders.where((o) {
      final haystack = normalizeSearch(
        '${o.clientName} ${o.whatsapp} ${o.code} ${o.garmentName} ${o.reference ?? ''}',
      );
      return haystack.contains(text);
    }).toList();
  }

  // --- Validaciones de los formularios (mensajes ya listos en español) ---

  static String? motive(String? value, {int min = 3}) =>
      Validators.reason(value, min: min);

  /// Devolución parcial: mayor que 0 y menor que lo pagado.
  static String? partialRefund(double? amount, double paid) {
    if (amount == null || amount <= 0) return 'Escribe cuánto se devuelve.';
    if (amount >= paid) {
      return 'Debe ser menor a lo pagado. Si es todo, elige «Devolver todo».';
    }
    return null;
  }

  static String? city(String? value, DeliveryType delivery) =>
      delivery == DeliveryType.shipping && (value ?? '').trim().isEmpty
      ? 'Escribe la ciudad.'
      : null;

  static String? address(String? value, DeliveryType delivery) =>
      delivery == DeliveryType.shipping && (value ?? '').trim().isEmpty
      ? 'Escribe la dirección.'
      : null;
}
