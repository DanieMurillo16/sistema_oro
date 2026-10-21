import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// El único botón principal de la portada: píldora dorada con flecha que lleva
/// a las piezas.
class HeroExploreButton extends StatelessWidget {
  const HeroExploreButton({
    super.key,
    required this.onPressed,
    this.expand = false,
  });

  final VoidCallback onPressed;

  /// En teléfono ocupa todo el ancho.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        gradient: AppCatalogColors.goldGradient,
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Ver el catálogo',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppCatalogColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppCatalogColors.ink,
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
