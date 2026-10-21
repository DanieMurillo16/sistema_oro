import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/providers/garment_types_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';

/// Crear o editar un tipo de prenda. Mismo contrato que las demás acciones.
final typeActionsProvider =
    AsyncNotifierProvider.autoDispose<TypeActionsNotifier, String?>(
      TypeActionsNotifier.new,
    );

class TypeActionsNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> save({
    int? id,
    required String name,
    required int order,
    required bool active,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final type = await ref
          .read(garmentsRepositoryProvider)
          .saveType(id: id, name: name, order: order, active: active);
      ref.read(garmentTypesProvider.notifier).upsert(type);
      // El nombre del tipo se ve en cada prenda: se recarga la lista.
      ref.invalidate(garmentsProvider);
      return id == null ? 'Tipo creado' : 'Tipo actualizado';
    });
  }
}
