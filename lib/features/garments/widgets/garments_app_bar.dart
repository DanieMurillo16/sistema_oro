import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_types_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';

/// La barra de «Prendas»; con permiso, el acceso a los tipos de prenda.
class GarmentsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const GarmentsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canTypes = ref.watch(canProvider(Permissions.typesManage));
    return AppBar(
      title: const Text('Prendas'),
      actions: [
        if (canTypes)
          AppActionButton(
            icon: Icons.category_outlined,
            tooltip: 'Tipos de prenda',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const GarmentTypesDialog(),
            ),
          ),
        const SizedBox(width: DesignTokens.spaceSm),
      ],
    );
  }
}
