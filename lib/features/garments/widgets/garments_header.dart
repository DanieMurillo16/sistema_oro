import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/garments/providers/garment_selection_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_filter_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/garments/widgets/garments_summary.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/list_filter_bar.dart';

/// Búsqueda y pestañas de la pantalla de prendas.
class GarmentsHeader extends ConsumerWidget {
  const GarmentsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(garmentsFilterProvider);
    final showSummary = MediaQuery.viewInsetsOf(context).bottom == 0;
    final bar = ListFilterBar<GarmentsTab>(
      hint: 'Buscar por nombre, referencia o tipo',
      selected: filter.tab,
      options: [
        for (final tab in GarmentsTab.values)
          AppToggleOption(value: tab, label: tab.label),
      ],
      // Cambiar de pestaña o buscar descarta la selección: no se elimina algo
      // que ya no se ve.
      onSelected: (tab) {
        ref.read(garmentSelectionProvider.notifier).clear();
        ref.read(garmentsFilterProvider.notifier).selectTab(tab);
      },
      onSearch: (query) {
        ref.read(garmentSelectionProvider.notifier).clear();
        ref.read(garmentsFilterProvider.notifier).search(query);
      },
    );
    if (!showSummary) return bar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GarmentsSummary(),
        const SizedBox(height: DesignTokens.spaceMd),
        bar,
      ],
    );
  }
}
