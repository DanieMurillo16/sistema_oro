import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_delete_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_selection_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Eliminar varias prendas a la vez (las marcadas en la lista). Cada una valida
/// su regla en el servidor: las que tienen solicitudes o separados pendientes
/// vuelven con el motivo («Se eliminaron N, M no se pudieron: …»).
class DeleteGarmentsDialog extends ConsumerStatefulWidget {
  const DeleteGarmentsDialog({super.key, required this.garments});

  final List<Garment> garments;

  @override
  ConsumerState<DeleteGarmentsDialog> createState() =>
      _DeleteGarmentsDialogState();
}

class _DeleteGarmentsDialogState extends ConsumerState<DeleteGarmentsDialog> {
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
    ref
        .read(garmentDeleteProvider.notifier)
        .deleteMany(widget.garments, reason: reason.isEmpty ? null : reason);
    ref.read(garmentSelectionProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  /// Los 3 primeros nombres y «y N más»: se ve QUÉ se elimina.
  String get _namesLabel {
    final names = [for (final g in widget.garments.take(3)) g.nameLabel];
    final more = widget.garments.length - names.length;
    return more > 0 ? '${names.join(', ')} y $more más' : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.garments.length;
    final textTheme = Theme.of(context).textTheme;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.delete_outline,
        title: count == 1 ? 'Eliminar 1 prenda' : 'Eliminar $count prendas',
        color: Theme.of(context).colorScheme.error,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_namesLabel, style: textTheme.titleSmall),
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            'Se quitan de la app y del catálogo. El historial de pedidos y '
            'pagos se conserva. No se puede deshacer desde la app.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            'Las que tengan solicitudes o separados pendientes no se eliminan: '
            'te diremos cuáles.',
            style: textTheme.bodySmall,
          ),
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
        confirmLabel: count == 1 ? 'Eliminar' : 'Eliminar $count',
        confirmIcon: Icons.delete_outline,
        destructive: true,
      ),
    );
  }
}
