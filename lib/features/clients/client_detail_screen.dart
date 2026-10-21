import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/providers/clients_provider.dart';
import 'package:sistema_oro/features/clients/utils/client_labels.dart';
import 'package:sistema_oro/features/clients/widgets/client_history_card.dart';
import 'package:sistema_oro/features/clients/widgets/client_info_card.dart';
import 'package:sistema_oro/features/clients/widgets/edit_client_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';

/// La ficha de un cliente: sus datos y todos sus pedidos y separados.
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(clientDetailProvider(id));
    final canEdit = ref.watch(canProvider(Permissions.clientsEdit));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.clients),
        ),
        title: Text(detail.value?.nameLabel ?? 'Cliente'),
        actions: [
          if (canEdit && detail.value != null)
            AppActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Editar cliente',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => EditClientDialog(client: detail.value!),
              ),
            ),
          const SizedBox(width: DesignTokens.spaceSm),
        ],
      ),
      body: PageBody(
        child: AppAsyncView<Client>(
          state: detail,
          isEmpty: (_) => false,
          onRetry: () => ref.invalidate(clientDetailProvider(id)),
          builder: (client) => ListView(
            padding: DesignTokens.pagePaddingFor(
              MediaQuery.sizeOf(context).width,
            ),
            children: [
              ClientInfoCard(client: client),
              const SizedBox(height: DesignTokens.spaceMd),
              ClientHistoryCard(
                history: client.history,
                from: AppRoutes.client(id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
