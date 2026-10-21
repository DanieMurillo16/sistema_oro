import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card.dart';
import 'package:sistema_oro/shared/widgets/app_float.dart';
import 'package:sistema_oro/shared/widgets/app_slide_in.dart';

/// «Otras piezas que te pueden gustar»: las demás prendas del catálogo en una
/// fila que se desliza de lado. Cada tarjeta flota despacio de arriba abajo y,
/// con el mouse encima, pasa por todas sus fotos. Si no hay más prendas, no se
/// muestra nada.
class RelatedGarments extends ConsumerWidget {
  const RelatedGarments({super.key, required this.currentId});

  final int currentId;

  static const double _cardWidth = 260;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = (ref.watch(catalogGarmentsProvider).value?.items ?? const [])
        .where((g) => g.id != currentId)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otras piezas que te pueden gustar',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Descúbrelas: pasa el mouse por encima para ver todas sus fotos.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        // Altura natural: la tarjeta crece con el texto (nombre largo, letra grande).
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, garment) in items.indexed) ...[
                if (index > 0) const SizedBox(width: DesignTokens.spaceMd),
                AppSlideIn(
                  key: ValueKey(garment.id),
                  from: const Offset(0.12, 0),
                  delay: Duration(milliseconds: 60 * (index % 6)),
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: _cardWidth,
                    child: AppFloat(
                      distance: 6,
                      period: Duration(milliseconds: 4200 + 500 * (index % 3)),
                      phase: (index % 4) / 4,
                      child: CatalogCard(
                        garment: garment,
                        onTap: () =>
                            context.push(AppRoutes.catalogGarment(garment.id)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
