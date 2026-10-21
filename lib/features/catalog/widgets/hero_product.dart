import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/hero_product_caption.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';
import 'package:sistema_oro/shared/widgets/app_float.dart';

/// La pieza más reciente en la portada, con un halo dorado detrás y flotando
/// despacio. Al tocarla abre su detalle.
class HeroProduct extends StatelessWidget {
  const HeroProduct({super.key, required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) {
    final gold = AppCatalogColors.goldText;
    return AppFloat(
      distance: 8,
      period: const Duration(milliseconds: 4200),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.catalogGarment(garment.id)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              DesignTokens.catalogPhotoRadius + 2,
            ),
            border: Border.all(color: gold.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: gold.withValues(alpha: 0.30), blurRadius: 80),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              DesignTokens.catalogPhotoRadius + 1,
            ),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CatalogPhoto(url: garment.thumbnail ?? '', cacheWidth: 700),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: HeroProductCaption(garment: garment),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
