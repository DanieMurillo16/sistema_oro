import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// El botón «Ingresar»: muestra progreso y se apaga mientras se envía.
class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, DesignTokens.buttonHeight),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: DesignTokens.progressSize,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.login_rounded),
    label: const Text('Ingresar'),
  );
}
