import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/clients/data/clients_repository.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/utils/client_rules.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';

/// Todos los clientes de la sesión (único lugar donde viven). Las pantallas
/// filtran con [filteredClientsProvider].
final clientsProvider = AsyncNotifierProvider<ClientsNotifier, List<Client>>(
  ClientsNotifier.new,
);

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.clientsView))) return const [];
    return ref.read(clientsRepositoryProvider).fetchAll();
  }

  /// Vuelve a pedir la lista sin vaciar la pantalla; si falla y ya hay datos,
  /// no los reemplaza por el error.
  Future<void> refreshQuietly() async {
    final result = await AsyncValue.guard(
      () => ref.read(clientsRepositoryProvider).fetchAll(),
    );
    if (!ref.mounted) return;
    if (result.hasError && state.hasValue) return;
    state = result;
  }

  void upsert(Client client) {
    final current = state.value;
    if (current == null) return;
    final next = [
      for (final c in current)
        if (c.id != client.id) c,
      client,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    state = AsyncData(next);
  }
}

class ClientsFilterNotifier extends ListFilterNotifier<ClientsTab> {
  @override
  ClientsTab get initialTab => ClientsTab.all;
}

final clientsFilterProvider =
    NotifierProvider<ClientsFilterNotifier, ListFilter<ClientsTab>>(
      ClientsFilterNotifier.new,
    );

final filteredClientsProvider = Provider<List<Client>>((ref) {
  final filter = ref.watch(clientsFilterProvider);
  final all = ref.watch(clientsProvider).value ?? const <Client>[];
  return ClientRules.filtered(all, filter.tab, filter.query);
});

/// La ficha de un cliente con sus pedidos y separados.
final clientDetailProvider = FutureProvider.autoDispose.family<Client, int>((
  ref,
  id,
) {
  ref.watch(sessionUserIdProvider);
  return ref.read(clientsRepositoryProvider).get(id);
});
