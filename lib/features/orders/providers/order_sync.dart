import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/orders/data/orders_repository.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/features/orders/providers/order_detail_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';

/// Tras una escritura sobre un pedido: trae su estado real, actualiza solo esa
/// fila de la lista compartida (las demás vistas se enteran) y marca como
/// viejo lo que depende de él (detalle, insignia). Si no puede traerlo, recarga
/// la lista entera.
Future<void> syncOrder(Ref ref, int id) async {
  try {
    final detail = await ref.read(ordersRepositoryProvider).getDetail(id);
    ref.read(ordersProvider.notifier).upsert(detail.order);
  } on AppException {
    ref.invalidate(ordersProvider);
  }
  ref.invalidate(orderDetailProvider(id));
  ref.invalidate(orderCountersProvider);
  // Confirmar, rechazar o cancelar cambia las unidades libres de la prenda.
  ref.invalidate(garmentsProvider);
}
