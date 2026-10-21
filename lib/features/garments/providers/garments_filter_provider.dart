import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';

class GarmentsFilterNotifier extends ListFilterNotifier<GarmentsTab> {
  @override
  GarmentsTab get initialTab => GarmentsTab.all;
}

final garmentsFilterProvider =
    NotifierProvider<GarmentsFilterNotifier, ListFilter<GarmentsTab>>(
      GarmentsFilterNotifier.new,
    );

/// Las filas de la pantalla de prendas, derivadas de [garmentsProvider].
final filteredGarmentsProvider = Provider<List<Garment>>((ref) {
  final filter = ref.watch(garmentsFilterProvider);
  final all = ref.watch(garmentsProvider).value ?? const <Garment>[];
  return GarmentRules.filtered(all, filter.tab, filter.query);
});
