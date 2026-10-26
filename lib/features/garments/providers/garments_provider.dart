import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_sales.dart';
import 'package:sistema_oro/features/garments/utils/garment_summary.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';

/// Todo el inventario de la sesión: el único lugar donde viven las prendas.
/// Las escrituras llaman a [upsert]; los filtros son providers derivados.
final garmentsProvider = AsyncNotifierProvider<GarmentsNotifier, List<Garment>>(
  GarmentsNotifier.new,
);

class GarmentsNotifier extends AsyncNotifier<List<Garment>> {
  @override
  Future<List<Garment>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.garmentsView))) return const [];
    return ref.read(garmentsRepositoryProvider).fetchAll();
  }

  /// Vuelve a pedir la lista sin vaciar la pantalla; si falla y ya hay datos,
  /// no los reemplaza por el error.
  Future<void> refreshQuietly() async {
    final result = await AsyncValue.guard(
      () => ref.read(garmentsRepositoryProvider).fetchAll(),
    );
    if (!ref.mounted) return;
    if (result.hasError && state.hasValue) return;
    state = result;
  }

  /// Saca la prenda de la lista (eliminada en el servidor); las tarjetas
  /// restantes se reacomodan solas.
  void remove(int id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final g in current)
        if (g.id != id) g,
    ]);
  }

  /// Reemplaza la prenda si existe, la agrega si no, y reordena (más nuevas
  /// primero).
  void upsert(Garment garment) {
    final current = state.value;
    if (current == null) return;
    // El detalle no trae las solicitudes pendientes: se conserva el número de
    // la fila anterior.
    final old = current.where((g) => g.id == garment.id).firstOrNull;
    final next = [
      old == null ? garment : garment.withPendingRequests(old.pendingRequests),
      for (final g in current)
        if (g.id != garment.id) g,
    ]..sort((a, b) => b.id - a.id);
    state = AsyncData(next);
  }
}

/// Totales de todo el inventario (se recalculan solos al cambiar las prendas).
final garmentsSummaryProvider = Provider<GarmentSummary>(
  (ref) => GarmentSummary.of(ref.watch(garmentsProvider).value ?? const []),
);

/// Ventas y separados de una prenda, derivados de la lista única de pedidos.
final garmentSalesProvider = Provider.family<GarmentSales, int>(
  (ref, garmentId) =>
      GarmentSales.of(ref.watch(ordersProvider).value ?? const [], garmentId),
);
