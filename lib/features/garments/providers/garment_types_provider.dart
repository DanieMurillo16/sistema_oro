import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';

/// Los tipos de prenda (pulseras, cadenas, dijes…): un catálogo que crece.
final garmentTypesProvider =
    AsyncNotifierProvider<GarmentTypesNotifier, List<GarmentType>>(
      GarmentTypesNotifier.new,
    );

class GarmentTypesNotifier extends AsyncNotifier<List<GarmentType>> {
  @override
  Future<List<GarmentType>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.garmentsView))) return const [];
    return ref.read(garmentsRepositoryProvider).types();
  }

  void upsert(GarmentType type) {
    final current = state.value;
    if (current == null) return;
    final next =
        [
          for (final t in current)
            if (t.id != type.id) t,
          type,
        ]..sort((a, b) {
          final byOrder = a.order - b.order;
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });
    state = AsyncData(next);
  }
}
