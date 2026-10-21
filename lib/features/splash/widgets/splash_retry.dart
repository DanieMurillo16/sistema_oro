import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Mensaje y botón cuando no se pudo recuperar la sesión (p. ej. sin red).
class SplashRetry extends StatelessWidget {
  const SplashRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: DesignTokens.spaceMd),
      FilledButton.tonal(
        onPressed: onRetry,
        child: const Text('Intentar nuevamente'),
      ),
    ],
  );
}
