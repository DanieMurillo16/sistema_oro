import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment_draft.dart';
import 'package:sistema_oro/features/garments/providers/garment_sync.dart';

/// Las escrituras sobre prendas (crear, editar, ajustar stock, imágenes). El
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

  /// Crea la prenda y, ya con su id, sube las [photos] elegidas EN LA MISMA
  /// operación (el botón del diálogo sigue cargando hasta que termina todo).
  /// Si una foto falla la prenda ya existe: se avisa cuántas faltan y se
  /// agregan desde el detalle.
  Future<void> create(
    GarmentDraft draft, {
    List<PickedImage> photos = const [],
  }) => _run(() async {
    final id = await _repository.create(draft);
    createdId = id;
    var failed = 0;
    for (var i = 0; i < photos.length; i++) {
      try {
        await _repository.addImage(id, order: i + 1, image: photos[i]);
      } on AppException {
        failed++;
      }
    }
    await syncGarment(ref, id);
    return failed == 0
        ? 'Prenda creada'
        : 'Prenda creada, pero $failed '
              '${failed == 1 ? 'foto no se pudo subir' : 'fotos no se pudieron subir'}. '
              'Agrégalas desde el detalle.';
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
