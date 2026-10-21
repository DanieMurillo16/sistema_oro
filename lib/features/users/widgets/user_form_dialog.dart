import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/users/models/managed_user.dart';
import 'package:sistema_oro/features/users/providers/users_provider.dart';
import 'package:sistema_oro/features/users/utils/user_rules.dart';
import 'package:sistema_oro/features/users/widgets/user_credentials_fields.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_search_dropdown.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Crear un usuario (con su contraseña inicial) o editar nombre, rol y estado.
class UserFormDialog extends ConsumerStatefulWidget {
  const UserFormDialog({super.key, this.user});

  final ManagedUser? user;

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user?.name);
  final _username = TextEditingController();
  final _password = TextEditingController();
  late var _active = widget.user?.active ?? true;
  UserRole? _role;
  var _roleInitialized = false;

  bool get _isEdit => widget.user != null;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(userActionsProvider.notifier);
    if (_isEdit) {
      notifier.edit(
        widget.user!.id,
        name: _name.text.trim(),
        roleId: _role!.id,
        active: _active,
      );
    } else {
      notifier.create(
        name: _name.text.trim(),
        username: _username.text.trim(),
        password: _password.text,
        roleId: _role!.id,
      );
    }
  }

  /// Al editar, deja elegido el rol que ya tiene el usuario (una sola vez, en
  /// cuanto llegan los roles).
  void _resolveRole(List<UserRole> roles) {
    if (_roleInitialized || !_isEdit || roles.isEmpty) return;
    _role = roles.where((r) => r.id == widget.user!.roleId).firstOrNull;
    _roleInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      userActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final roles = ref.watch(rolesProvider).value ?? const <UserRole>[];
    _resolveRole(roles);
    return AppDialog(
      header: DialogHeader(
        icon: Icons.manage_accounts_outlined,
        title: _isEdit ? 'Editar usuario' : 'Nuevo usuario',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('user_name'),
              controller: _name,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                counterText: '',
              ),
              validator: UserRules.name,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            if (!_isEdit) ...[
              UserCredentialsFields(username: _username, password: _password),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            AppSearchDropdown<UserRole>(
              label: 'Rol',
              value: _role,
              items: roles,
              itemLabel: (r) => r.name.toLowerCase(),
              onChanged: (value) => setState(() => _role = value),
              validator: UserRules.role,
            ),
            if (_isEdit)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Puede ingresar'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(userActionsProvider).isLoading,
        confirmLabel: _isEdit ? 'Guardar usuario' : 'Crear usuario',
      ),
    );
  }
}
