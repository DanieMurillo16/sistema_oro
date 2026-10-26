import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment_draft.dart';
import 'package:sistema_oro/features/garments/providers/garment_sync.dart';
import 'package:sistema_oro/features/garments/providers/garment_uploads_provider.dart';

/// Las escrituras sobre prendas (crear, editar, ajustar stock, eliminar, imágenes). El
/// dato es el mensaje de éxito; la pantalla reacciona con `listenAction`. Tras
/// cada una trae la prenda real y actualiza solo esa fila de la lista.
final garmentActionsProvider =
    AsyncNotifierProvider.autoDispose<GarmentActionsNotifier, String?>(
      GarmentActionsNotifier.new,
    );

class GarmentActionsNotifier extends AsyncNotifier<String?> {
  GarmentsRepository get _repository => ref.read(garmentsRepositoryProvider);

  /// Id de la última prenda creada (para abrir su detalle).
  int? createdId;

  @override
  String? build() => null;

  /// Crea la prenda y la deja en la lista YA (trae la real y actualiza solo esa
  /// fila). Las [photos] no se esperan: suben en segundo plano (la primera
  /// sola, las demás en paralelo) y se ven como vista previa en su detalle.
  Future<void> create(
    GarmentDraft draft, {
    List<PickedImage> photos = const [],
  }) => _run(() async {
    final id = await _repository.create(draft);
    createdId = id;
    await syncGarment(ref, id);
    ref.read(garmentUploadsProvider.notifier).start(id, photos);
    return photos.isEmpty
        ? 'Prenda creada'
        : 'Prenda creada. Las fotos se suben en segundo plano.';
  });

  Future<void> edit(int id, GarmentDraft draft) => _run(() async {
    await _repository.edit(id, draft);
    await syncGarment(ref, id);
    return 'Prenda actualizada';
  });

  Future<void> adjustStock(
    int id, {
    required int delta,
    required String reason,
  }) => _run(() async {
    await _repository.adjustStock(id, delta: delta, reason: reason);
    await syncGarment(ref, id);
    return 'Stock actualizado';
  });

  Future<void> _run(Future<String> Function() action) async {
    if (state.isLoading) return;
    // Sin esto, si se cierra el diálogo a mitad de la subida el notifier se
    // destruye y la operación falla con «Ref used after disposed».
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(action);
    } finally {
      link.close();
    }
  }
}
