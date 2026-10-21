import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/layaways/data/payments_repository.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/providers/order_sync.dart';

/// Registrar y anular abonos. Mismo contrato que `orderActionsProvider`: el
/// dato es el mensaje de éxito y la pantalla reacciona con `listenAction`.
final paymentActionsProvider =
    AsyncNotifierProvider.autoDispose<PaymentActionsNotifier, String?>(
      PaymentActionsNotifier.new,
    );

class PaymentActionsNotifier extends AsyncNotifier<String?> {
  PaymentsRepository get _repository => ref.read(paymentsRepositoryProvider);

  @override
  String? build() => null;

  Future<void> register({
    required int orderId,
    required int amount,
    required DateTime date,
    required PaymentMethod method,
    PickedImage? receipt,
  }) => _run(() async {
    final result = await _repository.register(
      orderId: orderId,
      amount: amount,
      date: date,
      method: method,
      receipt: receipt,
    );
    await syncOrder(ref, orderId);
    return result['estado'] == 'PAGADO'
        ? 'Abono registrado. El separado quedó pagado por completo.'
        : 'Abono registrado';
  });

  Future<void> voidPayment(int paymentId, String reason) => _run(() async {
    final result = await _repository.voidPayment(paymentId, reason);
    await syncOrder(ref, jsonInt(result['id_pedido']));
    return 'Pago anulado';
  });

  Future<void> _run(Future<String> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}
