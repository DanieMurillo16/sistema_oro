import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/type_actions_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Crear o editar un tipo de prenda: nombre, orden en el catálogo y si está
/// activo.
class TypeFormDialog extends ConsumerStatefulWidget {
  const TypeFormDialog({super.key, this.type});

  final GarmentType? type;

  @override
  ConsumerState<TypeFormDialog> createState() => _TypeFormDialogState();
}

class _TypeFormDialogState extends ConsumerState<TypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.type?.name);
  late final _order = TextEditingController(text: '${widget.type?.order ?? 0}');
  late var _active = widget.type?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(typeActionsProvider.notifier)
        .save(
          id: widget.type?.id,
          name: _name.text.trim(),
          order: int.tryParse(_order.text.trim()) ?? 0,
          active: _active,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      typeActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    return AppDialog(
      header: DialogHeader(
        icon: Icons.category_outlined,
        title: widget.type == null ? 'Nuevo tipo' : 'Editar tipo',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormPair(
              minWidth: DesignTokens.formShortPairMinWidth,
              first: TextFormField(
                key: const Key('type_name'),
                controller: _name,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  counterText: '',
                ),
                validator: GarmentRules.name,
              ),
              second: TextFormField(
                key: const Key('type_order'),
                controller: _order,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Orden',
                  counterText: '',
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activo en el catálogo'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(typeActionsProvider).isLoading,
        confirmLabel: 'Guardar tipo',
      ),
    );
  }
}
