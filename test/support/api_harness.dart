import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/services/token_storage.dart';

import 'fake_api_adapter.dart';
import 'fake_token_storage.dart';

/// Un `ApiClient` real (un solo Dio) con adaptador falso: los repositorios y las
/// vistas se prueban de punta a punta sin red, y se puede afirmar exactamente
/// qué se envió (método, ruta, token, cuerpo).
///
/// En una prueba de vista:
/// ```dart
/// final h = ApiHarness(FakeApiAdapter((o) async => switch (o.path) {
///   ApiEndpoints.movementsList => FakeApiAdapter.jsonResponse(lista, 200),
///   ApiEndpoints.movementsCreate => FakeApiAdapter.jsonResponse(creado, 200),
///   _ => FakeApiAdapter.jsonResponse({'success': false}, 404),
/// }));
/// await pumpView(tester, MiPantalla(), overrides: h.overrides);
/// ```
class ApiHarness {
  ApiHarness(this.adapter, {String? token = 'tok'})
    : tokens = FakeTokenStorage(token) {
    api = ApiClient(
      baseUrl: 'https://servidor.test/api/',
      tokenStorage: tokens,
      adapter: adapter,
      onUnauthorized: () async {
        unauthorizedCalls++;
        await tokens.clear();
      },
    );
  }

  final FakeApiAdapter adapter;
  final FakeTokenStorage tokens;
  late final ApiClient api;
  int unauthorizedCalls = 0;

  RecordedRequest get single => adapter.requests.single;

  /// Para `ProviderScope(overrides: h.overrides)`: la vista usa el `ApiClient`
  /// real y solo se corta la red.
  List<Override> get overrides => [
    apiClientProvider.overrideWithValue(api),
    tokenStorageProvider.overrideWithValue(tokens),
  ];
}
