import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_grid.dart';
import 'package:sistema_oro/shared/widgets/app_empty_view.dart';
import 'package:sistema_oro/shared/widgets/app_error_view.dart';
import 'package:sistema_oro/shared/widgets/app_loader.dart';

/// Los resultados del listado como sliver: cargando, error, vacío o la
/// cuadrícula. Conserva las prendas que ya se ven mientras se recarga.
class CatalogResults extends ConsumerWidget {
  const CatalogResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(catalogGarmentsProvider);
    if (page.hasError && !page.hasValue) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          message: userErrorMessage(page.error),
          onRetry: () => ref.invalidate(catalogGarmentsProvider),
        ),
      );
    }
    if (!page.hasValue) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoader(),
      );
    }
    if (page.requireValue.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyView(
          icon: Icons.diamond_outlined,
          title: 'No encontramos prendas',
          message: 'Prueba con otro tipo o con otra búsqueda.',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
      sliver: CatalogGrid(
        items: page.requireValue.items,
        // push: así la flecha «atrás» regresa con la animación inversa.
        onOpen: (garment) => context.push(AppRoutes.catalogGarment(garment.id)),
      ),
    );
  }
}
