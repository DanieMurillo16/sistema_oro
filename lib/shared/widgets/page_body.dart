import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Centra el contenido con el ancho máximo de la app: en monitores grandes no
/// se estira todo hasta los bordes.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DesignTokens.contentMaxWidth),
      child: child,
    ),
  );
}
