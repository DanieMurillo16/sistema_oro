import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/providers/garment_detail_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';

/// Tras una escritura sobre una prenda: trae la prenda real, actualiza solo
/// esa fila de la lista compartida y marca vieja su ficha de detalle. Si no
/// puede traerla, recarga la lista.
Future<void> syncGarment(Ref ref, int id) async {
  try {
    final garment = await ref.read(garmentsRepositoryProvider).get(id);
    ref.read(garmentsProvider.notifier).upsert(garment);
  } on AppException {
    ref.invalidate(garmentsProvider);
  }
  ref.invalidate(garmentDetailProvider(id));
}
