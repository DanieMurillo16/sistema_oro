import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/widgets/brand_logo_image.dart';

/// Vista previa del logo sobre el negro del catálogo. Mientras carga muestra un
/// hueco con un indicador (no el logo empaquetado como si fuera el actual).
class BrandLogoPreview extends StatelessWidget {
  const BrandLogoPreview({super.key, required this.url, required this.loading});

  final String url;
  final bool loading;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppCatalogColors.background,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      border: Border.all(color: AppCatalogColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: loading
          ? const SizedBox.square(
              dimension: DesignTokens.brandLogoPreviewSize,
              child: Center(child: CircularProgressIndicator()),
            )
          : BrandLogoImage(url: url, size: DesignTokens.brandLogoPreviewSize),
    ),
  );
}
