import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Título de la sección, cuántos resultados hay y el orden. Los tipos de prenda
/// viven en la cabecera fija (`CatalogTypeStrip`).
class CatalogFilters extends ConsumerWidget {
  const CatalogFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogFilterProvider);
    final page = ref.watch(catalogGarmentsProvider).value;
    final notifier = ref.read(catalogFilterProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nuestras piezas', style: textTheme.headlineSmall),
                Text(page?.countLabel ?? '', style: textTheme.bodySmall),
              ],
            );
            final sort = _SortMenu(
              sort: filter.sort,
              onSelected: notifier.selectSort,
            );
            // En teléfono el orden va debajo: título y contador no se parten.
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, sort],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: title),
                const SizedBox(width: DesignTokens.spaceSm),
                sort,
              ],
            );
          },
        ),
        const SizedBox(height: DesignTokens.spaceMd),
      ],
    );
  }
}

/// «Ordenar: Más recientes ▾»: un menú discreto en lugar de un campo grande.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.sort, required this.onSelected});

  final CatalogSort sort;
  final ValueChanged<CatalogSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const primary = AppCatalogColors.goldText;
    return PopupMenuButton<CatalogSort>(
      tooltip: 'Ordenar',
      initialValue: sort,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final option in CatalogSort.values)
          PopupMenuItem(value: option, child: Text(option.label)),
      ],
      child: Padding(
        // Alto de toque de 44.
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
        // Si no cabe, todo el menú se encoge junto (nunca se parte ni se corta).
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ordenar: ', style: textTheme.bodySmall),
              Text(
                sort.label,
                style: textTheme.labelLarge?.copyWith(color: primary),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
