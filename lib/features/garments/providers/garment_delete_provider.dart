import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/summary/providers/summary_provider.dart';

/// Eliminar una o varias prendas, de forma optimista: salen de la lista AL
/// INSTANTE y el servidor confirma después, una por una (cada una valida su
/// regla). Las que rechaza (p. ej. con solicitudes o separados pendientes)
/// vuelven a su sitio y el mensaje llega a la pantalla de la lista
/// (`listenAction`). El dato es el mensaje de éxito; si alguna falla, el
/// resumen sale como error («Se eliminaron N, M no se pudieron: motivo»).
final garmentDeleteProvider =
    AsyncNotifierProvider.autoDispose<GarmentDeleteNotifier, String?>(
      GarmentDeleteNotifier.new,
    );

class GarmentDeleteNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> delete(Garment garment, {String? reason}) =>
      deleteMany([garment], reason: reason);

  Future<void> deleteMany(List<Garment> garments, {String? reason}) async {
    if (state.isLoading || garments.isEmpty) return;
    // Que no se destruya a mitad: la pantalla que lo mira puede cambiar.
    final link = ref.keepAlive();
    final list = ref.read(garmentsProvider.notifier);
    try {
      for (final garment in garments) {
        list.remove(garment.id);
      }
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(garmentsRepositoryProvider);
        final failures = <String>[];
        var done = 0;
        for (final garment in garments) {
          try {
            await repository.delete(garment.id, reason: reason);
            done++;
          } on AppException catch (error) {
            if (ref.mounted) list.upsert(garment); // vuelve a su sitio
            failures.add(error.message);
          }
        }
        if (done > 0 && ref.mounted) ref.invalidate(summaryProvider);
        if (failures.isEmpty) {
          return done == 1 ? 'Prenda eliminada' : '$done prendas eliminadas';
        }
        throw ApiException(_failureSummary(done, failures));
      });
    } finally {
      link.close();
    }
  }

  /// Una sola prenda: el mensaje del servidor tal cual.
  static String _failureSummary(int done, List<String> failures) {
    if (done == 0 && failures.length == 1) return failures.first;
    if (done == 0) return 'No se pudo eliminar ninguna: ${failures.first}';
    final failed = failures.length;
    return 'Se eliminaron $done, $failed no se '
        '${failed == 1 ? 'pudo' : 'pudieron'}: ${failures.first}';
  }
}
