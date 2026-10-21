import 'package:flutter/material.dart';
import 'package:sistema_oro/core/config/app_config.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/widgets/brand_logo.dart';

/// La marca en la cabecera: el logo y, al lado, «BARON» y «GOLDEN BOSS» en
/// mayúsculas finas con mucho espacio entre letras.
class CatalogBrand extends StatelessWidget {
  const CatalogBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandLogo(size: 52),
        const SizedBox(width: DesignTokens.spaceSm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BARON',
                  style: textTheme.titleMedium?.copyWith(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppConfig.catalogName
                      .replaceFirst('Baron ', '')
                      .toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppCatalogColors.goldText,
                    letterSpacing: 3.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
