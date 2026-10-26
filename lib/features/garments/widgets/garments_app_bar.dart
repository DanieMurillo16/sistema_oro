import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_selection_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_filter_provider.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_types_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';

/// La barra de «Prendas»; con permiso, el acceso a los tipos de prenda. Con
/// prendas marcadas pasa a ser la barra de selección (cuántas, cancelar y
/// «seleccionar todas las visibles»).
class GarmentsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const GarmentsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(garmentSelectionProvider);
    if (selection.isNotEmpty) {
      return AppBar(
        leading: IconButton(
          tooltip: 'Cancelar selección',
          icon: const Icon(Icons.close),
          onPressed: ref.read(garmentSelectionProvider.notifier).clear,
        ),
        title: Text(
          selection.length == 1
              ? '1 seleccionada'
              : '${selection.length} seleccionadas',
        ),
        actions: [
          AppActionButton(
            icon: Icons.select_all,
            tooltip: 'Seleccionar todas las visibles',
            onPressed: () => ref
                .read(garmentSelectionProvider.notifier)
                .selectAll(ref.read(filteredGarmentsProvider).map((g) => g.id)),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
        ],
      );
    }
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
