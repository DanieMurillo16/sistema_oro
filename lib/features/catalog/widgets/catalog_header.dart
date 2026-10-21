import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_brand.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_header_compact.dart';

/// La cabecera fija del catálogo. Arriba del todo solo lleva la marca, centrada;
/// al bajar la lista pasa a marca a la izquierda, los tipos de prenda al centro
/// y WhatsApp a la derecha (en teléfono, los tipos en su propia fila). Siempre
/// ocupa el mismo alto: el cambio es un fundido, sin saltos.
class CatalogHeader extends ConsumerWidget {
  const CatalogHeader({super.key, this.blur = false});

  /// Fondo translúcido con desenfoque: el contenido pasa por debajo al hacer
  /// scroll (solo cuando la cabecera va fija sobre la lista).
  final bool blur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = ref.watch(catalogHeaderCompactProvider);
    final scheme = Theme.of(context).colorScheme;
    final bar = Material(
      // Negro del logo: así su imagen no se ve como un cuadrado.
      color: blur
          ? AppCatalogColors.background.withValues(alpha: 0.86)
          : AppCatalogColors.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DesignTokens.catalogMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceSm,
                ),
                child: AnimatedSwitcher(
                  duration: motionDuration(
                    context,
                    DesignTokens.animationNormal,
                  ),
                  switchInCurve: DesignTokens.curve,
                  child: compact
                      ? const CatalogHeaderCompact(key: ValueKey('compact'))
                      : const Center(
                          key: ValueKey('top'),
                          child: CatalogBrand(),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!blur) return bar;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: bar,
      ),
    );
  }
}
