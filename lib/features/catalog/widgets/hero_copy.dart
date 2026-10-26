import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/widgets/brand_logo.dart';
import 'package:sistema_oro/features/catalog/widgets/hero_explore_button.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';

/// El texto de la portada: etiqueta en mayúsculas, titular con una palabra en
/// dorado, una frase corta y el botón único hacia las piezas.
class HeroCopy extends StatelessWidget {
  const HeroCopy({super.key, required this.wide, required this.onExplore});

  final bool wide;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gold = AppCatalogColors.goldText;
    final gap = wide ? DesignTokens.spaceMd : DesignTokens.spaceSm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide) ...[
          const BrandLogo(size: 96),
          const SizedBox(height: DesignTokens.spaceMd),
        ],
        DotSeparatedText(
          parts: const ['PORTE DE BOSS', 'JOYERÍA EN ORO'],
          style: textTheme.labelMedium?.copyWith(
            color: gold,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: gap),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Oro que '),
              TextSpan(
                text: 'se queda contigo',
                style: TextStyle(color: gold),
              ),
            ],
          ),
          style: textTheme.headlineLarge?.copyWith(
            color: AppCatalogColors.onInk,
            fontSize: wide ? 56 : 32,
            height: 1.05,
          ),
        ),
        SizedBox(height: gap),
        Text(
          'Cadenas, pulseras y dijes. Elige tu pieza y sepárala con el 20 %: '
          'te la entregamos cuando completes el pago.',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: wide ? 18 : 15,
            height: 1.45,
            color: AppCatalogColors.onInk.withValues(alpha: 0.78),
          ),
        ),
        SizedBox(height: wide ? DesignTokens.spaceXl : DesignTokens.spaceMd),
        HeroExploreButton(onPressed: onExplore, expand: !wide),
      ],
    );
  }
}
