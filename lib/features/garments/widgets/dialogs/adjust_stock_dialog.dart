import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_actions_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/reason_field.dart';

/// Sumar o quitar unidades (ingresos y ajustes), con su motivo.
class AdjustStockDialog extends ConsumerStatefulWidget {
  const AdjustStockDialog({super.key, required this.garment});

  final Garment garment;

  @override
  ConsumerState<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends ConsumerState<AdjustStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _delta = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _delta.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(garmentActionsProvider.notifier)
        .adjustStock(
          widget.garment.id,
          delta: int.parse(_delta.text.trim()),
          reason: _reason.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      garmentActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final garment = widget.garment;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.inventory_2_outlined,
        title: 'Ajustar stock',
        subtitle: '${garment.nameLabel} · hay ${garment.stockLabel}',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('stock_delta'),
              controller: _delta,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Cantidad (+ suma, − resta)',
                helperText: 'Ejemplo: 3 para sumar tres, -1 para quitar una.',
              ),
              validator: (text) => GarmentRules.stockDelta(text, garment.stock),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ReasonField(
              controller: _reason,
              fieldKey: const Key('stock_reason'),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(garmentActionsProvider).isLoading,
        confirmLabel: 'Guardar ajuste',
      ),
    );
  }
}
