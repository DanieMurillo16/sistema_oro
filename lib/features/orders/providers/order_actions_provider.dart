import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/data/orders_repository.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/providers/order_sync.dart';

/// Las acciones de Barón sobre un pedido. El dato es el mensaje de éxito de la
/// última acción (`null` = nada en curso); la pantalla reacciona con
/// `listenAction`. Un solo envío a la vez.
final orderActionsProvider =
    AsyncNotifierProvider.autoDispose<OrderActionsNotifier, String?>(
      OrderActionsNotifier.new,
    );

class OrderActionsNotifier extends AsyncNotifier<String?> {
  OrdersRepository get _repository => ref.read(ordersRepositoryProvider);

  @override
  String? build() => null;

  Future<void> confirm(int id) => _run(id, () async {
    await _repository.confirm(id);
    return 'Solicitud confirmada';
  });

  Future<void> reject(int id, String reason) => _run(id, () async {
    final result = await _repository.reject(id, reason);
    final refund = jsonDecimal(result['monto_a_devolver']);
    return refund > 0
        ? 'Solicitud rechazada. Devuelve ${formatCop(refund)} al cliente.'
        : 'Solicitud rechazada';
  });

  Future<void> cancel(
    int id, {
    required CancelDecision decision,
    required String reason,
    int? returnedAmount,
  }) => _run(id, () async {
    await _repository.cancel(
      id,
      decision: decision,
      reason: reason,
      returnedAmount: returnedAmount == null ? null : moneyText(returnedAmount),
    );
    return 'Pedido cancelado';
  });

  Future<void> ship(int id, {String? tracking}) => _run(id, () async {
    await _repository.ship(id, tracking: tracking);
    return 'Marcado como enviado';
  });

  Future<void> deliver(int id) => _run(id, () async {
    await _repository.deliver(id);
    return 'Marcado como entregado';
  });

  Future<void> editDelivery(
    int id, {
    required DeliveryType delivery,
    String? city,
    String? address,
  }) => _run(id, () async {
    await _repository.editDelivery(
      id,
      delivery: delivery,
      city: city,
      address: address,
    );
    return 'Entrega actualizada';
  });

  Future<void> _run(int id, Future<String> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final message = await action();
      await syncOrder(ref, id);
      return message;
    });
  }
}
