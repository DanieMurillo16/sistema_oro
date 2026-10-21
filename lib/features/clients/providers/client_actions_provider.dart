import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/clients/data/clients_repository.dart';
import 'package:sistema_oro/features/clients/providers/clients_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';

/// Corregir el nombre y las notas de un cliente.
final clientActionsProvider =
    AsyncNotifierProvider.autoDispose<ClientActionsNotifier, String?>(
      ClientActionsNotifier.new,
    );

class ClientActionsNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> edit(int id, {required String name, String? notes}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(clientsRepositoryProvider);
      await repository.edit(id, name: name, notes: notes);
      try {
        ref.read(clientsProvider.notifier).upsert(await repository.get(id));
      } on AppException {
        ref.invalidate(clientsProvider);
      }
      ref.invalidate(clientDetailProvider(id));
      // El nombre del cliente se ve en cada pedido suyo.
      ref.invalidate(ordersProvider);
      return 'Cliente actualizado';
    });
  }
}
