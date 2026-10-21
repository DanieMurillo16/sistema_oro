import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/hero_copy.dart';
import 'package:sistema_oro/features/catalog/widgets/hero_product.dart';
import 'package:sistema_oro/shared/widgets/app_slide_in.dart';

/// Portada del catálogo: UN titular grande, una frase corta y UN botón hacia
/// las piezas; en pantalla ancha, a la derecha, la pieza más reciente con un
/// halo dorado. Todo lo que dice es cierto: oro nacional e italiano, separar
/// con el 20 % y completar en abonos.
class CatalogHero extends ConsumerWidget {
  const CatalogHero({super.key, required this.onExplore});

  /// Lleva a la cuadrícula de piezas.
  final VoidCallback onExplore;

  /// Resplandor dorado a la derecha, detrás de la pieza; el resto es el negro
  /// del logo para que su imagen no se vea como un cuadrado.
  static final _glow = RadialGradient(
    center: const Alignment(0.7, 0),
    radius: 0.9,
    colors: [
      AppCatalogColors.gold.withValues(alpha: 0.22),
      AppCatalogColors.gold.withValues(alpha: 0),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide =
        MediaQuery.sizeOf(context).width >=
        DesignTokens.catalogThreeColumnsWidth;
    final newest = ref.watch(catalogGarmentsProvider).value?.items.firstOrNull;
    // Entran de los lados, suaves y escalonados: el texto desde la izquierda y
    // la pieza desde la derecha.
    final copy = AppSlideIn(
      from: const Offset(-0.06, 0),
      delay: const Duration(milliseconds: 150),
      duration: const Duration(milliseconds: 600),
      child: HeroCopy(wide: wide, onExplore: onExplore),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceLg),
      child: AppSlideIn(
        from: Offset.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppCatalogColors.background,
            gradient: _glow,
            borderRadius: BorderRadius.circular(
              DesignTokens.catalogPhotoRadius + 6,
            ),
            border: Border.all(
              color: AppCatalogColors.gold.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(wide ? 56 : DesignTokens.spaceLg),
            child: wide && newest != null
                ? Row(
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: DesignTokens.spaceXl),
                      Expanded(
                        flex: 3,
                        child: AppSlideIn(
                          from: const Offset(0.08, 0),
                          delay: const Duration(milliseconds: 350),
                          duration: const Duration(milliseconds: 650),
                          child: Center(child: HeroProduct(garment: newest)),
                        ),
                      ),
                    ],
                  )
                : copy,
          ),
        ),
      ),
    );
  }
}
