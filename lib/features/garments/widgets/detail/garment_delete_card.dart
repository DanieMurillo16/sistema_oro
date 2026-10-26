import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_visibility_provider.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/delete_garment_dialog.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Al final del detalle, dos acciones distintas y claras: «Ocultar del
/// catálogo» (reversible) y «Eliminar» (la saca de la app y del catálogo). Van
/// aparte de todo lo demás para que no se toquen por accidente.
class GarmentDeleteCard extends ConsumerWidget {
  const GarmentDeleteCard({
    super.key,
    required this.garment,
    required this.canHide,
    required this.canDelete,
  });

  final Garment garment;
  final bool canHide;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      title: 'Más acciones',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canHide) ...[
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(garmentVisibilityProvider.notifier)
                  .setVisible(garment.id, visible: !garment.active),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, DesignTokens.dialogButtonHeight),
              ),
              icon: Icon(
                garment.active
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: Text(
                garment.active
                    ? 'Ocultar del catálogo'
                    : 'Mostrar en el catálogo',
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              garment.active
                  ? 'Reversible: sigue en tu lista con la etiqueta «Oculta».'
                  : 'Hoy está oculta: no se ve en el catálogo.',
              style: textTheme.bodySmall,
            ),
          ],
          if (canHide && canDelete)
            const SizedBox(height: DesignTokens.spaceMd),
          if (canDelete) ...[
            OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => DeleteGarmentDialog(garment: garment),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: error,
                side: BorderSide(color: error.withValues(alpha: 0.9)),
                minimumSize: const Size(0, DesignTokens.dialogButtonHeight),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar prenda'),
            ),
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              'Se quita de la app y del catálogo. El historial de pedidos y '
              'pagos se conserva.',
              style: textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
