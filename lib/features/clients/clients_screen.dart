import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/clients/providers/clients_provider.dart';
import 'package:sistema_oro/features/clients/widgets/client_tile.dart';
import 'package:sistema_oro/features/clients/widgets/clients_header.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/list_header_padding.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/responsive_cards.dart';

/// Los clientes: se crean solos cuando alguien compra o separa desde el
/// catálogo; aquí se ven sus pedidos y lo que deben.
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(filteredClientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: PageBody(
        child: Column(
          children: [
            const ListHeaderPadding(child: ClientsHeader()),
            Expanded(
              child: AppAsyncView(
                state: ref.watch(clientsProvider),
                isEmpty: (_) => clients.isEmpty,
                onRetry: () => ref.invalidate(clientsProvider),
                emptyIcon: Icons.people_outline,
                emptyTitle: 'Sin clientes',
                emptyMessage: 'Aún no hay clientes que coincidan.',
                builder: (_) => ResponsiveCards(
                  itemCount: clients.length,
                  itemBuilder: (context, index) => ClientTile(
                    key: ValueKey(clients[index].id),
                    client: clients[index],
                    onTap: () =>
                        context.go(AppRoutes.client(clients[index].id)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
