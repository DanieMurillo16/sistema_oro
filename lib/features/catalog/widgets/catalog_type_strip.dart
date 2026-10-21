import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_type_chip.dart';

/// Los tipos de prenda disponibles en una franja deslizable (se ve en la
/// cabecera fija al bajar la lista). «Todas» quita el filtro.
class CatalogTypeStrip extends ConsumerWidget {
  const CatalogTypeStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeId = ref.watch(catalogFilterProvider.select((f) => f.typeId));
    final types = ref.watch(catalogTypesProvider).value ?? const [];
    final notifier = ref.read(catalogFilterProvider.notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CatalogTypeChip(
            label: 'Todas',
            selected: typeId == null,
            onTap: () => notifier.selectType(null),
          ),
          for (final type in types) ...[
            const SizedBox(width: DesignTokens.spaceSm),
            CatalogTypeChip(
              label: type.name,
              selected: typeId == type.id,
              onTap: () => notifier.selectType(type.id),
            ),
          ],
        ],
      ),
    );
  }
}
