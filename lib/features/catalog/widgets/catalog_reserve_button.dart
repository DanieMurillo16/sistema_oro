import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// El botón «Reservar» de la tarjeta: píldora pequeña de solo contorno dorado.
class CatalogReserveButton extends StatelessWidget {
  const CatalogReserveButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 34),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      tapTargetSize: MaterialTapTargetSize.padded,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      ),
      foregroundColor: AppCatalogColors.goldText,
      side: const BorderSide(color: AppCatalogColors.gold),
      textStyle: Theme.of(context).textTheme.labelMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
    child: const Text('Reservar'),
  );
}
