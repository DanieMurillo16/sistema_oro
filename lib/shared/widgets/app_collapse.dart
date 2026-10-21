import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';

/// Muestra u oculta un bloque **creciendo/encogiéndose con fundido** (paneles
/// plegables, detalles, avisos en línea), en vez de que el resto de la pantalla
/// salte.
class AppCollapse extends StatelessWidget {
  const AppCollapse({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, DesignTokens.animationNormal);
    return AnimatedSize(
      duration: duration,
      curve: DesignTokens.curve,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1 : 0,
        child: visible ? child : const SizedBox(width: double.infinity),
      ),
    );
  }
}
