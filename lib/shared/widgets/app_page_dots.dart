import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';

/// Indicadores de página: el activo alargado en color de acento, los demás
/// puntos tenues.
class AppPageDots extends StatelessWidget {
  const AppPageDots({super.key, required this.count, this.current = 0});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Decorativo: no es un paginador real.
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < count; index++)
            Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : DesignTokens.spaceXs,
              ),
              child: AnimatedContainer(
                duration: motionDuration(context, DesignTokens.animationNormal),
                curve: DesignTokens.curve,
                width: index == current
                    ? DesignTokens.pageDotActiveWidth
                    : DesignTokens.pageDotSize,
                height: DesignTokens.pageDotSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  color: index == current
                      ? scheme.secondary
                      : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
