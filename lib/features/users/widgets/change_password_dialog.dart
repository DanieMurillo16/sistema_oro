import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/users/models/managed_user.dart';
import 'package:sistema_oro/features/users/providers/users_provider.dart';
import 'package:sistema_oro/features/users/utils/user_rules.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Cambiar la contraseña de un usuario: cierra sus sesiones abiertas.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key, required this.user});

  final ManagedUser user;

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(userActionsProvider.notifier)
        .changePassword(widget.user.id, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      userActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    return AppDialog(
      header: DialogHeader(
        icon: Icons.key_outlined,
        title: 'Cambiar contraseña',
        subtitle: widget.user.username,
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('new_password'),
          controller: _password,
          obscureText: true,
          maxLength: UserRules.passwordMax,
          decoration: const InputDecoration(
            labelText: 'Nueva contraseña',
            counterText: '',
          ),
          validator: UserRules.password,
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(userActionsProvider).isLoading,
        confirmLabel: 'Cambiar contraseña',
        confirmIcon: Icons.key_outlined,
      ),
    );
  }
}
