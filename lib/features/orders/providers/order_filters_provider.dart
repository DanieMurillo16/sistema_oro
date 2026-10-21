import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/utils/clock.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';

/// Pestaña elegida y texto de búsqueda de una lista.
class ListFilter<T> {
  const ListFilter({required this.tab, this.query = ''});

  final T tab;
  final String query;
}

/// Base de los filtros de las listas de pedidos y de separados. La búsqueda
/// espera 250 ms a que se deje de escribir (el debounce vive aquí, no en la
/// vista).
abstract class ListFilterNotifier<T> extends Notifier<ListFilter<T>> {
  static const _debounce = Duration(milliseconds: 250);

  Timer? _timer;

  T get initialTab;

  @override
  ListFilter<T> build() {
    ref.onDispose(() => _timer?.cancel());
    return ListFilter(tab: initialTab);
  }

  void selectTab(T tab) => state = ListFilter(tab: tab, query: state.query);

  void search(String query) {
    _timer?.cancel();
    _timer = Timer(
      _debounce,
      () => state = ListFilter(tab: state.tab, query: query),
    );
  }
}

class OrdersFilterNotifier extends ListFilterNotifier<OrdersTab> {
  @override
  OrdersTab get initialTab => OrdersTab.review;
}

class LayawaysFilterNotifier extends ListFilterNotifier<LayawaysTab> {
  @override
  LayawaysTab get initialTab => LayawaysTab.active;
}

final ordersFilterProvider =
    NotifierProvider<OrdersFilterNotifier, ListFilter<OrdersTab>>(
      OrdersFilterNotifier.new,
    );

final layawaysFilterProvider =
    NotifierProvider<LayawaysFilterNotifier, ListFilter<LayawaysTab>>(
      LayawaysFilterNotifier.new,
    );

/// Lo que muestra la pantalla de pedidos: derivado de [ordersProvider]. La
/// pantalla usa `ordersProvider` para el estado (cargando, error) y esta lista
/// para las filas.
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final filter = ref.watch(ordersFilterProvider);
  final all = ref.watch(ordersProvider).value ?? const <Order>[];
  return OrderRules.forOrdersTab(all, filter.tab, filter.query);
});

/// Lo que muestra la pantalla de separados.
final filteredLayawaysProvider = Provider<List<Order>>((ref) {
  final filter = ref.watch(layawaysFilterProvider);
  final all = ref.watch(ordersProvider).value ?? const <Order>[];
  return OrderRules.forLayawaysTab(
    all,
    filter.tab,
    filter.query,
    now: ref.watch(clockProvider)(),
  );
});

/// Los pedidos de un cliente (para su ficha), derivados de la misma lista.
final clientOrdersProvider = Provider.family<List<Order>, int>((ref, clientId) {
  final all = ref.watch(ordersProvider).value ?? const <Order>[];
  return all.where((o) => o.clientId == clientId).toList();
});

/// Días que lleva un separado sin abonar (para la pestaña «Recordar»).
final layawayIdleDaysProvider = Provider.family<int, Order>(
  (ref, order) =>
      OrderRules.daysWithoutPayment(order, ref.watch(clockProvider)()),
);
