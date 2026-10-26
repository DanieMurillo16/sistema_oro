import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_selection_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_visibility_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/delete_garment_dialog.dart';

/// Menú de una prenda al mantener pulsada su tarjeta: ver, ocultar o mostrar
/// (reversible), seleccionar varias y eliminar (esta última pide confirmación).
class GarmentActionsSheet extends ConsumerWidget {
  const GarmentActionsSheet({
    super.key,
    required this.garment,
    required this.onOpen,
    required this.parentContext,
  });

  final Garment garment;
  final VoidCallback onOpen;

  /// El contexto de la pantalla (el del menú se cierra al elegir).
  final BuildContext parentContext;

  /// Abre el menú de [garment].
  static Future<void> show(
    BuildContext context, {
    required Garment garment,
    required VoidCallback onOpen,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => GarmentActionsSheet(
      garment: garment,
      onOpen: onOpen,
      parentContext: context,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    final canEdit = ref.watch(canProvider(Permissions.garmentsEdit));
    final canDelete = ref.watch(canProvider(Permissions.garmentsDelete));
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceXs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  garment.nameLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Ver prenda'),
              onTap: () {
                Navigator.of(context).pop();
                onOpen();
              },
            ),
            if (canEdit)
              ListTile(
                leading: Icon(
                  garment.active
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                title: Text(
                  garment.active
                      ? 'Ocultar del catálogo'
                      : 'Mostrar en el catálogo',
                ),
                subtitle: Text(
                  garment.active
                      ? 'Sigue en tu lista como «Oculta»'
                      : 'Vuelve a verse en el catálogo',
                ),
                onTap: () {
                  ref
                      .read(garmentVisibilityProvider.notifier)
                      .setVisible(garment.id, visible: !garment.active);
                  Navigator.of(context).pop();
                },
              ),
            if (canDelete) ...[
              ListTile(
                leading: const Icon(Icons.checklist_rtl),
                title: const Text('Seleccionar varias'),
                subtitle: const Text('Para eliminarlas juntas'),
                onTap: () {
                  ref
                      .read(garmentSelectionProvider.notifier)
                      .toggle(garment.id);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: error),
                title: Text('Eliminar prenda', style: TextStyle(color: error)),
                subtitle: const Text('Se quita de la app y del catálogo'),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: parentContext,
                    builder: (_) => DeleteGarmentDialog(garment: garment),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
