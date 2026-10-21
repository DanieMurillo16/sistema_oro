import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Foto de una prenda (URL pública absoluta) con marcador si falta o falla.
/// [size] cuadrado (`double.infinity` = ocupar todo el espacio disponible); usa la miniatura en listas y la grande en el detalle.
class NetworkThumb extends StatelessWidget {
  const NetworkThumb({
    super.key,
    required this.url,
    this.size = DesignTokens.thumbSize,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.diamond_outlined,
        size: size.isFinite ? size * 0.4 : DesignTokens.placeholderIconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: fit,
                cacheWidth: size.isFinite ? (size * 2).round() : null,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}
