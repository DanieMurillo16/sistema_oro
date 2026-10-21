import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/features/users/utils/user_rules.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';

/// Usuario y contraseña inicial de un usuario nuevo, en pareja.
class UserCredentialsFields extends StatelessWidget {
  const UserCredentialsFields({
    super.key,
    required this.username,
    required this.password,
  });

  final TextEditingController username;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) => AppFormPair(
    first: TextFormField(
      key: const Key('user_username'),
      controller: username,
      maxLength: 50,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: const InputDecoration(labelText: 'Usuario', counterText: ''),
      validator: UserRules.username,
    ),
    second: TextFormField(
      key: const Key('user_password'),
      controller: password,
      obscureText: true,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.newPassword],
      maxLength: UserRules.passwordMax,
      decoration: const InputDecoration(
        labelText: 'Contraseña',
        counterText: '',
      ),
      validator: UserRules.password,
    ),
  );
}
