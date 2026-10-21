import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/providers/client_actions_provider.dart';
import 'package:sistema_oro/features/clients/utils/client_rules.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Corregir el nombre y las notas de un cliente (el WhatsApp no se cambia: es
/// lo que lo identifica).
class EditClientDialog extends ConsumerStatefulWidget {
  const EditClientDialog({super.key, required this.client});

  final Client client;

  @override
  ConsumerState<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends ConsumerState<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.client.name);
  late final _notes = TextEditingController(text: widget.client.notes);

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notes = _notes.text.trim();
    ref
        .read(clientActionsProvider.notifier)
        .edit(
          widget.client.id,
          name: _name.text.trim(),
          notes: notes.isEmpty ? null : notes,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      clientActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    return AppDialog(
      header: const DialogHeader(
        icon: Icons.person_outline,
        title: 'Editar cliente',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('client_name'),
              controller: _name,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                counterText: '',
              ),
              validator: ClientRules.name,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextFormField(
              key: const Key('client_notes'),
              controller: _notes,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(clientActionsProvider).isLoading,
        confirmLabel: 'Guardar cliente',
      ),
    );
  }
}
