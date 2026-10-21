import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/data/orders_repository.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';

/// Cada cuánto se revisan los pendientes con la app abierta (`null` = nunca;
/// las pruebas lo apagan para no dejar temporizadores).
final orderRefreshIntervalProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 60),
);

/// Cada cuánto se revisa mientras Barón está mirando la pantalla de Pedidos
/// (así una solicitud nueva aparece casi al instante). Con [orderRefreshIntervalProvider]
/// en `null` (pruebas) tampoco hay temporizador.
final orderFastRefreshIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 1),
);

/// `true` mientras la pantalla de Pedidos está abierta.
final ordersScreenVisibleProvider =
    NotifierProvider<OrdersScreenVisibleNotifier, bool>(
      OrdersScreenVisibleNotifier.new,
    );

class OrdersScreenVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Sin efecto si la sesión ya se cerró (la pantalla se desmonta después).
  void set(bool visible) {
    if (ref.mounted) state = visible;
  }
}

/// Pendientes por revisar y separados vencidos: la insignia del menú. Si los
/// números cambian, la lista de pedidos se refresca sola, sin vaciarse.
final orderCountersProvider =
    AsyncNotifierProvider<OrderCountersNotifier, OrderCounters>(
      OrderCountersNotifier.new,
    );

class OrderCountersNotifier extends AsyncNotifier<OrderCounters> {
  @override
  Future<OrderCounters> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.ordersView))) {
      return OrderCounters.empty;
    }
    final base = ref.read(orderRefreshIntervalProvider);
    final interval = base == null
        ? null
        : ref.watch(ordersScreenVisibleProvider)
        ? ref.read(orderFastRefreshIntervalProvider)
        : base;
    if (interval != null) {
      final timer = Timer.periodic(interval, (_) => _refreshQuietly());
      ref.onDispose(timer.cancel);
    }
    return ref.read(ordersRepositoryProvider).counters();
  }

  Future<void> _refreshQuietly() async {
    try {
      final next = await ref.read(ordersRepositoryProvider).counters();
      if (!ref.mounted) return;
      final changed = state.value != next;
      state = AsyncData(next);
      if (changed) {
        unawaited(ref.read(ordersProvider.notifier).refresh(silent: true));
      }
    } on AppException {
      // Sin red un momento: se conserva lo que ya se ve.
    }
  }
}
