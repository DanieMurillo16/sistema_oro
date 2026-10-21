import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/catalog/data/catalog_repository.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';

/// Datos públicos que casi no cambian: se piden una vez por visita.
final catalogSettingsProvider = FutureProvider<CatalogSettings>(
  (ref) => ref.read(catalogRepositoryProvider).settings(),
);

final catalogTypesProvider = FutureProvider<List<CatalogType>>(
  (ref) => ref.read(catalogRepositoryProvider).types(),
);

/// Cada cuánto se revisa en segundo plano si el inventario cambió (una prenda
/// vendida o separada sale sola). `null` lo apaga (pruebas).
final catalogPollIntervalProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 2),
);

enum CatalogSort {
  recent('RECIENTES', 'Más recientes'),
  priceAsc('PRECIO_ASC', 'Precio: menor a mayor'),
  priceDesc('PRECIO_DESC', 'Precio: mayor a menor');

  const CatalogSort(this.api, this.label);

  final String api;
  final String label;
}

/// Tipo elegido y orden del listado.
class CatalogFilter {
  const CatalogFilter({this.typeId, this.sort = CatalogSort.recent});

  final int? typeId;
  final CatalogSort sort;

  CatalogFilter copyWith({
    int? typeId,
    bool clearType = false,
    CatalogSort? sort,
  }) => CatalogFilter(
    typeId: clearType ? null : (typeId ?? this.typeId),
    sort: sort ?? this.sort,
  );
}

final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

class CatalogFilterNotifier extends Notifier<CatalogFilter> {
  @override
  CatalogFilter build() {
    return const CatalogFilter();
  }

  void selectType(int? id) => state = id == null
      ? state.copyWith(clearType: true)
      : state.copyWith(typeId: id);

  void selectSort(CatalogSort sort) => state = state.copyWith(sort: sort);
}

/// ¿La cabecera fija va compacta? Arriba solo va el logo centrado; al bajar la lista
/// aparecen los tipos de prenda. Con histéresis para que no parpadee en el umbral.
final catalogHeaderCompactProvider =
    NotifierProvider.autoDispose<CatalogHeaderCompactNotifier, bool>(
      CatalogHeaderCompactNotifier.new,
    );

class CatalogHeaderCompactNotifier extends Notifier<bool> {
  /// Desplazamiento (px) desde el que se compacta, y desde el que se restaura.
  static const compactAt = 120.0;
  static const expandAt = 60.0;

  @override
  bool build() => false;

  /// Lo llama el controlador de scroll de la pantalla con cada movimiento.
  void scrolled(double offset) {
    if (!state && offset > compactAt) state = true;
    if (state && offset < expandAt) state = false;
  }
}

/// El listado: primera página según el filtro y «Ver más» para las siguientes.
/// Al cambiar el filtro se vuelve a pedir desde el inicio, conservando lo que
/// se ve mientras llega.
final catalogGarmentsProvider =
    AsyncNotifierProvider<CatalogGarmentsNotifier, CatalogPage>(
      CatalogGarmentsNotifier.new,
    );

class CatalogGarmentsNotifier extends AsyncNotifier<CatalogPage> {
  var _refreshing = false;

  @override
  Future<CatalogPage> build() {
    final filter = ref.watch(catalogFilterProvider);
    final interval = ref.read(catalogPollIntervalProvider);
    if (interval != null) {
      final timer = Timer.periodic(interval, (_) => _refreshQuietly());
      ref.onDispose(timer.cancel);
    }
    return ref
        .read(catalogRepositoryProvider)
        .garments(typeId: filter.typeId, sort: filter.sort.api);
  }

  /// Revisa el inventario sin cargadores ni parpadeos: conserva lo que se ve
  /// (y lo que ya se cargó con «Ver más») y solo cambia el estado si algo
  /// cambió. Si falla, no toca nada.
  Future<void> _refreshQuietly() async {
    final current = state.value;
    if (_refreshing || current == null || state.isLoading) return;
    _refreshing = true;
    try {
      final filter = ref.read(catalogFilterProvider);
      final fresh = await ref
          .read(catalogRepositoryProvider)
          .garments(
            typeId: filter.typeId,
            sort: filter.sort.api,
            limit: current.items.length.clamp(
              CatalogRepository.pageSize,
              CatalogRepository.maxPageSize,
            ),
          );
      final now = state.value;
      if (!ref.mounted || now == null || state.isLoading) return;
      if (fresh.signature != now.signature) state = AsyncData(fresh);
    } on Object {
      // Sin red o con error: se queda lo que se ve y se reintenta en 2 s.
    } finally {
      _refreshing = false;
    }
  }

  /// Trae la página siguiente y la agrega. Si falla, deja lo que ya hay.
  Future<bool> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || state.isLoading) return true;
    final filter = ref.read(catalogFilterProvider);
    final result = await AsyncValue.guard(
      () => ref
          .read(catalogRepositoryProvider)
          .garments(
            typeId: filter.typeId,
            sort: filter.sort.api,
            offset: current.items.length,
          ),
    );
    if (!ref.mounted || result.hasError) return !result.hasError;
    state = AsyncData(
      CatalogPage(
        items: [...current.items, ...result.requireValue.items],
        total: result.requireValue.total,
      ),
    );
    return true;
  }
}

/// Una prenda con todo su detalle (galería, descripción, 20 % calculado).
///
/// Mientras se mira se vuelve a pedir cada 2 s (el stock cambia si alguien
/// compra). Si la prenda ya no está (`NO_ENCONTRADO`) deja de preguntar y el
/// error llega a la vista: [isGarmentGone].
final catalogGarmentProvider = FutureProvider.autoDispose
    .family<CatalogGarment, int>((ref, id) async {
      final interval = ref.read(catalogPollIntervalProvider);
      Timer? timer;
      ref.onDispose(() => timer?.cancel());
      void schedule() {
        if (interval != null) timer = Timer(interval, ref.invalidateSelf);
      }

      try {
        final garment = await ref.read(catalogRepositoryProvider).garment(id);
        schedule();
        return garment;
      } on ApiException catch (error) {
        if (error.code != 'NO_ENCONTRADO') schedule();
        rethrow;
      } on Object {
        schedule();
        rethrow;
      }
    });

/// ¿Dejó de estar disponible la prenda (otra persona la compró o la separó)?
bool isGarmentGone(AsyncValue<CatalogGarment> state) =>
    state.error is ApiException &&
    (state.error! as ApiException).code == 'NO_ENCONTRADO';
