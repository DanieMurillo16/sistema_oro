import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment_draft.dart';
import 'package:sistema_oro/features/garments/providers/garment_sync.dart';

/// Ocultar una prenda del catálogo o volver a mostrarla (reversible: sigue en
/// la lista de administración con la etiqueta «Oculta»). Pide la prenda
/// completa al servidor antes de editarla: la fila de la lista no trae la
/// descripción y enviarla así la borraría. El dato es el mensaje de éxito.
final garmentVisibilityProvider =
    AsyncNotifierProvider.autoDispose<GarmentVisibilityNotifier, String?>(
      GarmentVisibilityNotifier.new,
    );

class GarmentVisibilityNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> setVisible(int id, {required bool visible}) async {
    if (state.isLoading) return;
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(garmentsRepositoryProvider);
        final full = await repository.get(id);
        await repository.edit(
          id,
          GarmentDraft.fromGarment(full, active: visible),
        );
        await syncGarment(ref, id);
        return visible
            ? 'Prenda visible en el catálogo'
            : 'Prenda oculta del catálogo';
      });
    } finally {
      link.close();
    }
  }
}
