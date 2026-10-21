import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';

/// Una prenda con su descripción e imágenes (la lista no las trae).
final garmentDetailProvider = FutureProvider.autoDispose.family<Garment, int>((
  ref,
  id,
) {
  ref.watch(sessionUserIdProvider);
  return ref.read(garmentsRepositoryProvider).get(id);
});
