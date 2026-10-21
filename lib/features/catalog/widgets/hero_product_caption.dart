import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Nombre y precio sobre la foto de la portada, con un velo oscuro para leerlos.
class HeroProductCaption extends StatelessWidget {
  const HeroProductCaption({super.key, required this.garment});

  final CatalogGarment garment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppCatalogColors.scrim,
            AppCatalogColors.scrim,
            Colors.transparent,
          ],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spaceMd,
          DesignTokens.spaceXl,
          DesignTokens.spaceMd,
          DesignTokens.spaceMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garment.nameLabel,
              style: textTheme.titleSmall?.copyWith(
                color: AppCatalogColors.onInk,
              ),
            ),
            Text(
              garment.priceLabel,
              style: textTheme.titleMedium?.copyWith(
                color: AppCatalogColors.goldText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
