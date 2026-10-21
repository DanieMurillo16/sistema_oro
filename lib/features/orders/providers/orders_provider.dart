import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/data/orders_repository.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';

/// Todos los pedidos de la sesión: el único lugar donde viven. Las vistas
/// filtran con providers derivados y las escrituras llaman a [upsert].
/// Sin `autoDispose` a propósito: navegar entre módulos no repite la consulta.
final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.ordersView))) return const [];
    return ref.read(ordersRepositoryProvider).fetchAll();
  }

  /// Reemplaza el pedido si existe, lo agrega si no, y reordena.
  void upsert(Order order) {
    final current = state.value;
    if (current == null) return;
    final next = [
      for (final o in current)
        if (o.id != order.id) o,
      order,
    ];
    state = AsyncData(OrderRules.sorted(next));
  }

  void remove(int id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final o in current)
        if (o.id != id) o,
    ]);
  }

  /// Vuelve a pedir la lista. Con [silent] conserva lo que se ve y, si falla,
  /// no lo reemplaza por el error.
  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      ref.invalidateSelf(); // recarga mostrando lo que ya hay
      return;
    }
    final result = await AsyncValue.guard(
      () => ref.read(ordersRepositoryProvider).fetchAll(),
    );
    if (!ref.mounted) return;
    if (result.hasError && state.hasValue) return;
    state = result;
  }
}
