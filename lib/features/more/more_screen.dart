import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/more/widgets/more_tile.dart';
import 'package:sistema_oro/features/more/widgets/user_card.dart';
import 'package:sistema_oro/shared/utils/confirm_destructive.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider.select((s) => s.value?.user));
    final canSettings = ref.watch(canProvider(Permissions.settingsView));
    final canUsers = ref.watch(canProvider(Permissions.usersManage));
    final canClients = ref.watch(canProvider(Permissions.clientsView));
    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: PageBody(
        child: ListView(
          padding: DesignTokens.pagePadding,
          children: [
            if (user != null) UserCard(user: user),
            const SizedBox(height: DesignTokens.spaceMd),
            if (canClients) ...[
              MoreTile(
                icon: Icons.people_outline,
                title: 'Clientes',
                onTap: () => context.go(AppRoutes.clients),
              ),
              const SizedBox(height: DesignTokens.spaceSm),
            ],
            if (canSettings) ...[
              MoreTile(
                icon: Icons.tune,
                title: 'Ajustes',
                onTap: () => context.go(AppRoutes.settings),
              ),
              const SizedBox(height: DesignTokens.spaceSm),
            ],
            if (canUsers) ...[
              MoreTile(
                icon: Icons.manage_accounts_outlined,
                title: 'Usuarios',
                onTap: () => context.go(AppRoutes.users),
              ),
              const SizedBox(height: DesignTokens.spaceSm),
            ],
            MoreTile(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              color: Theme.of(context).colorScheme.error,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que quieres salir de la administración?',
      confirmLabel: 'Cerrar sesión',
      icon: Icons.logout,
    );
    if (confirmed != null) await ref.read(sessionProvider.notifier).logout();
  }
}
