import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_delete_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_visibility_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Eliminar una prenda (nada se borra: sale del catálogo y del inventario, y
/// el historial de pedidos la sigue mostrando). Motivo opcional. Es optimista:
/// al confirmar se cierra y la prenda sale de la lista; si el servidor la
/// rechaza (tiene pendientes) vuelve con el aviso. Ofrece «Solo ocultar» (la edición tiene el interruptor de visible).
class DeleteGarmentDialog extends ConsumerStatefulWidget {
  const DeleteGarmentDialog({super.key, required this.garment});

  final Garment garment;

  @override
  ConsumerState<DeleteGarmentDialog> createState() =>
      _DeleteGarmentDialogState();
}

class _DeleteGarmentDialogState extends ConsumerState<DeleteGarmentDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  var _answered = false; // anti doble toque: un solo envío y un solo cierre

  void _submit() {
    if (_answered) return;
    _answered = true;
    final reason = _reason.text.trim();
    // Optimista: la prenda sale de la lista ya; el aviso (y la reversión si el
    // servidor la rechaza) los da la pantalla del inventario.
    final router = GoRouter.of(context);
    ref
        .read(garmentDeleteProvider.notifier)
        .delete(widget.garment, reason: reason.isEmpty ? null : reason);
    Navigator.of(context).pop();
    router.go(AppRoutes.garments);
  }

  /// «Ocultar» (reversible): la prenda sigue en la lista con la etiqueta
  /// «Oculta». El aviso lo da la pantalla que está debajo.
  void _hideInstead() {
    if (_answered) return;
    _answered = true;
    ref
        .read(garmentVisibilityProvider.notifier)
        .setVisible(widget.garment.id, visible: false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.delete_outline,
        title: 'Eliminar prenda',
        color: Theme.of(context).colorScheme.error,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.garment.nameLabel, style: textTheme.titleSmall),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            'Se quita de la app y del catálogo. El historial de pedidos y '
            'pagos se conserva. No se puede deshacer desde la app.',
            style: textTheme.bodyMedium,
          ),
          if (widget.garment.active) ...[
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              '¿Solo quieres que no se vea en el catálogo? Ocúltala: sigue en '
              'tu lista y puedes volver a mostrarla.',
              style: textTheme.bodySmall,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _hideInstead,
                icon: const Icon(
                  Icons.visibility_off_outlined,
                  size: DesignTokens.iconSm,
                ),
                label: const Text('Ocultar en vez de eliminar'),
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            key: const Key('delete_reason'),
            controller: _reason,
            maxLength: 200,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              counterText: '',
            ),
          ),
        ],
      ),
      actions: DialogActions(
        onConfirm: _submit,
        confirmLabel: 'Eliminar',
        confirmIcon: Icons.delete_outline,
        destructive: true,
        secondaryAction: widget.garment.active
            ? TextButton(onPressed: _hideInstead, child: const Text('Ocultar'))
            : null,
      ),
    );
  }
}
