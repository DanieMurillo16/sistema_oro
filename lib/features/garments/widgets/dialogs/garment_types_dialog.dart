import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/providers/garment_types_provider.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/type_form_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Los tipos de prenda: lista para editar y botón para crear uno nuevo.
class GarmentTypesDialog extends ConsumerWidget {
  const GarmentTypesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(garmentTypesProvider);
    return AppDialog(
      header: const DialogHeader(
        icon: Icons.category_outlined,
        title: 'Tipos de prenda',
      ),
      scrollContent: false,
      content: SizedBox(
        height: DesignTokens.listDialogHeight,
        child: AppAsyncView(
          state: types,
          isEmpty: (list) => list.isEmpty,
          onRetry: () => ref.invalidate(garmentTypesProvider),
          emptyIcon: Icons.category_outlined,
          emptyTitle: 'Sin tipos',
          emptyMessage: 'Crea el primer tipo (pulseras, cadenas, dijes…).',
          builder: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final type = list[index];
              return ListTile(
                key: ValueKey(type.id),
                contentPadding: EdgeInsets.zero,
                title: Text(type.name),
                subtitle: Text(
                  '${type.garments == 1 ? '1 prenda' : '${type.garments} prendas'}${type.active ? '' : ' · inactivo'}',
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => TypeFormDialog(type: type),
                ),
              );
            },
          ),
        ),
      ),
      actions: DialogActions(
        onConfirm: () => showDialog<void>(
          context: context,
          builder: (_) => const TypeFormDialog(),
        ),
        confirmLabel: 'Nuevo tipo',
        confirmIcon: Icons.add,
        cancelLabel: 'Cerrar',
      ),
    );
  }
}
