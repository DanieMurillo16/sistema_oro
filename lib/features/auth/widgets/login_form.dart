import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/utils/login_rules.dart';
import 'package:sistema_oro/features/auth/widgets/login_password_field.dart';
import 'package:sistema_oro/features/auth/widgets/login_submit_button.dart';

/// Usuario, contraseña y botón. No sabe de la red: avisa con [onSubmit].
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final void Function(String username, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading || !_formKey.currentState!.validate()) return;
    widget.onSubmit(_username.text, _password.text);
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('login_username'),
            controller: _username,
            enabled: !widget.isLoading,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            inputFormatters: [
              LengthLimitingTextInputFormatter(LoginRules.usernameMax),
            ],
            decoration: const InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: LoginRules.username,
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          LoginPasswordField(
            controller: _password,
            enabled: !widget.isLoading,
            onSubmitted: _submit,
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          LoginSubmitButton(isLoading: widget.isLoading, onPressed: _submit),
        ],
      ),
    ),
  );
}
