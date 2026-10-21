import 'package:flutter/material.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Foto de red que se ve de inmediato: mientras baja la imagen buena se
/// muestra [placeholderUrl] (la miniatura, que ya está en memoria) y la buena
/// entra con un fundido. Sin salto ni cuadro vacío.
class CatalogPhoto extends StatelessWidget {
  const CatalogPhoto({
    super.key,
    required this.url,
    this.placeholderUrl,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final String? url;
  final String? placeholderUrl;
  final BoxFit fit;

  /// Ancho al que se decodifica (ahorra memoria y tiempo en pantallas chicas).
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.diamond_outlined,
        size: DesignTokens.placeholderIconSize,
        color: scheme.onSurfaceVariant,
      ),
    );
    if (url == null) return empty;
    final base = placeholderUrl == null
        ? empty
        : Image.network(
            placeholderUrl!,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => empty,
          );
    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        Image.network(
          url!,
          fit: fit,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
          frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
            opacity: frame == null && !sync ? 0 : 1,
            duration: motionDuration(context, DesignTokens.animationNormal),
            curve: DesignTokens.curve,
            child: child,
          ),
        ),
      ],
    );
  }
}
