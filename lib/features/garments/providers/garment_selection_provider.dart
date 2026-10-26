import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Las prendas marcadas en la lista para eliminarlas juntas. Vacío = no hay
/// selección (la lista se comporta normal).
final garmentSelectionProvider =
    NotifierProvider.autoDispose<GarmentSelectionNotifier, Set<int>>(
      GarmentSelectionNotifier.new,
    );

class GarmentSelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void toggle(int id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  void selectAll(Iterable<int> ids) => state = {...ids};

  void clear() => state = const {};
}
