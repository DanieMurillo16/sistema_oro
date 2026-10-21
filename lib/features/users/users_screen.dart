import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/users/providers/users_provider.dart';
import 'package:sistema_oro/features/users/widgets/change_password_dialog.dart';
import 'package:sistema_oro/features/users/widgets/user_form_dialog.dart';
import 'package:sistema_oro/features/users/widgets/user_tile.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/app_fab.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/responsive_cards.dart';

/// Usuarios de la administración. Solo el dueño entra aquí.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.more),
        ),
        title: const Text('Usuarios'),
      ),
      floatingActionButton: AppFab(
        heroTag: 'users_new',
        icon: Icons.person_add_alt_1,
        label: 'Nuevo usuario',
        compactOnPhone: true,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const UserFormDialog(),
        ),
      ),
      body: PageBody(
        child: AppAsyncView(
          state: ref.watch(usersProvider),
          isEmpty: (list) => list.isEmpty,
          onRetry: () => ref.invalidate(usersProvider),
          emptyIcon: Icons.manage_accounts_outlined,
          emptyTitle: 'Sin usuarios',
          emptyMessage: 'Crea el primer usuario.',
          builder: (users) => ResponsiveCards(
            bottomPadding: DesignTokens.listBottomSpace,
            itemCount: users.length,
            itemBuilder: (context, index) => UserTile(
              key: ValueKey(users[index].id),
              user: users[index],
              onEdit: () => showDialog<void>(
                context: context,
                builder: (_) => UserFormDialog(user: users[index]),
              ),
              onPassword: () => showDialog<void>(
                context: context,
                builder: (_) => ChangePasswordDialog(user: users[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
