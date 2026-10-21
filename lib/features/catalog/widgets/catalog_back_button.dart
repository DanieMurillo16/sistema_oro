import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Flecha «atrás» dentro de un círculo blanco con sombra suave. SIEMPRE lleva
/// al listado (limpia la pila de prendas vistas, sean las que sean) y este
/// conserva su scroll y su tipo; el atrás del navegador, en cambio, sigue el
/// historial prenda por prenda.
class CatalogBackButton extends StatelessWidget {
  const CatalogBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Volver al catálogo',
      child: Material(
        color: scheme.surface,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black38,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.go(AppRoutes.catalog),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(
              Icons.arrow_back_rounded,
              size: DesignTokens.iconSm + 4,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
