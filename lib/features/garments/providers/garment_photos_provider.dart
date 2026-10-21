import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/providers/garment_sync.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

/// Agregar y quitar las fotos de una prenda (hasta 3). Aparte de las demás
/// escrituras para que su aviso lo dé la tarjeta de fotos y no un diálogo.
final garmentPhotosProvider =
    AsyncNotifierProvider.autoDispose<GarmentPhotosNotifier, String?>(
      GarmentPhotosNotifier.new,
    );

class GarmentPhotosNotifier extends AsyncNotifier<String?> {
  GarmentsRepository get _repository => ref.read(garmentsRepositoryProvider);

  @override
  String? build() => null;

  Future<void> add(int id, {required int order, required PickedImage image}) =>
      _run(() async {
        await _repository.addImage(id, order: order, image: image);
        await syncGarment(ref, id);
        return 'Foto agregada';
      });

  Future<void> remove(int garmentId, int imageId) => _run(() async {
    await _repository.removeImage(imageId);
    await syncGarment(ref, garmentId);
    return 'Foto eliminada';
  });

  Future<void> _run(Future<String> Function() action) async {
    if (state.isLoading) return;
    // Que no se destruya a mitad de la subida si nadie lo está mirando.
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(action);
    } finally {
      link.close();
    }
  }

  /// Primer lugar libre entre 1 y 3 para la próxima foto (`null` si ya están
  /// las tres).
  static int? nextOrder(Iterable<int> used) {
    for (var order = 1; order <= GarmentRules.maxImages; order++) {
      if (!used.contains(order)) return order;
    }
    return null;
  }
}
