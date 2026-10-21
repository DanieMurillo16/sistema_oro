import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/features/auth/utils/login_rules.dart';

/// Campo de contraseña con el ojo para mostrarla u ocultarla.
class LoginPasswordField extends StatefulWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  var _obscure = true; // estado efímero y visual

  @override
  Widget build(BuildContext context) => TextFormField(
    key: const Key('login_password'),
    controller: widget.controller,
    enabled: widget.enabled,
    obscureText: _obscure,
    autofillHints: const [AutofillHints.password],
    textInputAction: TextInputAction.done,
    onFieldSubmitted: (_) => widget.onSubmitted(),
    inputFormatters: [LengthLimitingTextInputFormatter(LoginRules.passwordMax)],
    decoration: InputDecoration(
      labelText: 'Contraseña',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    ),
    validator: LoginRules.password,
  );
}
